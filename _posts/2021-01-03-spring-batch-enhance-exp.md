---
layout: post
title:  "[Spring Batch] spring batch 성능 개선하기(경험 공유)"
date:   2021-01-03 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - spring-batch
 - enhance
---
- 단순 Select 후 값을 변환하여 Insert 하는 Batch Job 개선하기
  - A 테이블에서 B 테이블로 Snapshot 데이터를 저장하는 배치 입니다.

## 초기에 개발되어 있던 형태
### Spring Batch Code
#### ItemReader
- 전체 데이터를 select해서 `ListItemReader` 에 추가해서 사용

```java
@Bean
@StepScope
public ItemReader<ContentData1> reader() {
    return new ListItemReader<>(contentData1Repo.findAll());
}
```

- 사용된 쿼리

```sql
SELECT * FROM content_data_1
```

#### ItemProcessor
- 가져온 데이터를 가공함.
  - `totalPoint`에 모든 count 들을 더하여 저장.

```java
@Bean
@StepScope
public ItemProcessor<ContentData1, ContentData2> processor() {
    return new ItemProcessor<ContentData1, ContentData2>() {
        @Override
        public ContentData2 process(ContentData1 contentData1) throws Exception {
            return ContentData2.builder()
                .id(contentData1.getId())
                .snapshotDate(LocalDateTime.now())
                .bookName(contentData1.getBookName())
                .favoriteCount(contentData1.getFavoriteCount())
                .likeCount(contentData1.getLikeCount())
                .viewerCount(contentData1.getViewerCount())
                .totalPoint(contentData1.getFavoriteCount() + contentData1.getLikeCount() + contentData1.getViewerCount()) //가공하는 영역
                .createdDate(LocalDateTime.now())
                .build();
        }
    };
}
```

#### ItemWriter
- 한건씩 Insert 함
  - chunk 단위로 넘어온 데이터를 for loop 으로 insert 함.

```java
@Bean
@StepScope
public ItemWriter<ContentData2> writer() {
    return new ItemWriter<ContentData2>() {
        @Override
        public void write(List<? extends ContentData2> list) throws Exception {
            for (ContentData2 contentData2 : list) {
                contentData2Repo.save(contentData2);
            }

        }
    };
}
```

- 실행된 쿼리

```sql
insert into content_data_2 (aaaa, bbbb, cccc) values (?, ?, ?)
```

## 1차 개선
- insert query를 묶어서 처리하도록 변경.
  - 쿼리를 많이 호출할 수록 성능은 느려짐.
    - 호출마다 오고가는 네트워크 비용... 대량일 경우 생각보다 크다.

### Spring Batch Code
#### ItemWriter

```java
@Bean
@StepScope
public ItemWriter<ContentData2> writer() {
    return new ItemWriter<ContentData2>() {
        @Override
        public void write(List<? extends ContentData2> list) throws Exception {
            contentData2Repo.saveAllCustom(list); // for loop 을 제거하고 bulk 형태로 저장할 수 있도록 변경
        }
    };
}
```

- 변경된 쿼리

```sql
insert into content_data_2 (aaaa, bbbb, cccc) values (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?) ...
```

### 1차 개선시 주의사항
- mysql 사용시에 설정값 확인 필요. : [공식문서](https://dev.mysql.com/doc/refman/8.0/en/packet-too-large.html)
  - mysql client에서 server로 요청을 보낼 때 사이즈 제한이 있음 : `max_allowed_packet`
  - 설정값 확인 : 기본값 1048576 bytes (1MB)

``` 
show variables like ‘max_allowed_packet’; 
```

- 설정값 수정 (해당 설정은 mysql 재시작시에 다시 기본값으로 돌아감)
``` set global max_allowed_packet=1073741824 ```

- 만약 pk 나 유니크 인덱스와 같이 `기존 값이 있을 경우...` 를 고려해야한다면, `INSERT ... ON DUPLICATE KEY UPDATE Statement` 를 고려해볼 수 있다.
  - https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html

```sql
insert into content_data_2 (aaaa, bbbb, cccc) values (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?) ... 
ON DUPLICATE KEY UPDATE
    aaaa = 'test'; // 중복된 값에는 전부 test 가 들어가게됨.

//만약 insert 문 값으로 업데이트를 원한다면
insert into content_data_2 (aaaa, bbbb, cccc) values (?, ?, ?), (?, ?, ?), (?, ?, ?), (?, ?, ?) ... 
ON DUPLICATE KEY UPDATE
    aaaa = VALUES(aaaa)
```

## 2차 개선
- Spring Batch 에서 제공하는 partition 을 사용하여 `병렬` 처리하도록 수정

### Spring Batch Code
#### Partitioner
- 전체 카운트를 조회해서 그걸 gridSize 만큼 나눈다.
  - gridSize 만큼 범위가 나옴.
  - 그걸로 범위를 설정하여 조회함.

```java
    @Bean(name = BASIC_PARTITIONER)
    public Partitioner partitioner() {
        return new Partitioner() {
            private Integer max = ;


            @Override
            public Map<String, ExecutionContext> partition(int gridSize) {
                int targetSize = contentData1Repo.count() / gridSize + 1;

                Map<String, ExecutionContext> result = new HashMap<>();

                int number = 0;
                int start = 0;
                int end = start + targetSize - 1;

                while (start <= max) {
                    if (end >= max) {
                        end = max;
                    }

                    ExecutionContext value = new ExecutionContext();
                    value.putInt("minValue", start);
                    value.putInt("maxValue", end);
                    result.put("partition" + number, value);

                    start += targetSize;
                    end += targetSize;

                    number++;

                }

                return result;

            }
        };
    }
```

#### Step변경
- Master 역할을 해줄 Step 선언
  - `@Autowired @Qualifier(PARTITIONER_SLAVE_STEP) Step step` 의 경우 실제 Reader 와 Writer 가 선언된 step 을 사용하면 됨.

```java
    @Bean
    public Step masterStep(
        @Autowired @Qualifier(BASIC_PARTITIONER) Partitioner partitioner,
        @Autowired @Qualifier(PARTITIONER_SLAVE_STEP) Step step
    ) {
        return stepBuilderFactory
            .get(PARTITIONER_MASTER_STEP)
            .partitioner(PARTITIONER_SLAVE_STEP, partitioner)
            .step(step)
            .build();
    }
```

#### ItemReader
- 범위를 선택하여 드라이빙 할 데이터 양을 줄여서, 검색속도를 빠르게 함.

```java
@Bean
@StepScope
public ItemReader<ContentData1> reader(
        @Value("#{stepExecutionContext[minValue]}") String minValue,
        @Value("#{stepExecutionContext[maxValue]}") String maxValue
) {
    return new ListItemReader<>(contentData1Repo.findAll(minValue, maxValue));
}
```
- 사용된 쿼리
```sql
SELECT * FROM content_data_1 WHERE id >= #{minValue} and id < #{maxValue} order by id desc;
```

### 2차 개선시 주의사항
-`partition` 값 중 `grid` 값이 너무 클 경우 DB에 부하가 갈 수 있다.
- 병렬로 많은 select 와 insert 가 발생

- 기존에 사용하고 있던 `ListItemReader`를 제거함.
  - 해당 Reader를 사용하게되면 데이터가 메모리 설정값보다 커질 경우 문제가 될 수 있으므로, 한번에 처리하는 양은 조절 가능한 형태로 만들어 놓는게 좋다.

```sql
SELECT * FROM content_data_1 WHERE id >= #{minValue} and id < #{maxValue} order by id desc LIMIT 500 OFFSET 0;
```

## 결론
- spring batch 를 개발할 때는 chunk 단위도 중요하지만, Job 이 동작하고 한번에 처리할 데이터양도 신경쓰는게 좋다.
  - 한번에 너무 많은 데이터를 읽어서 메모리에 올려놓고 처리하는건... 언제 터질지 모르는 폭탄을 안고 있는 것과 같다.
- 그리고 병렬처리가 가능한 구조라면, DB 나 기존 서비스에 무리가 가지않는 범위 내에서 병렬처리를 하여 성능을 개선할 수 있다.
- partition 이 과하다 싶으면 `PagingItemReader` 를 검토 해보는 것도 좋다.

---
## 참고링크
- https://marobiana.tistory.com/131
