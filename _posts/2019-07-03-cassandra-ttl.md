---
layout: post
title:  "cassandra ttl 설정하기"
date:   2019-07-03 00:00:00 +0900
categories:
 - database
tags: 
 - cassandra
 - spring
---
# cassandra ttl 걸기

#### table 생성
```cql
CREATE TABLE example (
    key text PRIMARY KEY,
    value int,
);
```

#### 테스트 데이터 추가
```cql
INSERT INTO example (key, value) VALUES ('test', 1);
INSERT INTO example (key, value) VALUES ('test', 2) USING TTL 10;
```

#### 확인
- 10초 내에
```cql
SELECT * FROM example;
```

- 총 2건 검색 됨.
- 10초 이후에는 `value가 2`인 row는 제거됨.

## Spring 에서 사용하기
```java
@Autowired
private CassandraOperations cassandraOperations;

@Test
public void test() {
	InsertOptions writeOptions = InsertOptions.builder()
		.ttl(10)
		.build();
	
	cassandraOperations.insert(TmpEntity.builder().build(), writeOptions);
}
```

---
## 참고자료
- https://stackoverflow.com/questions/40730510/just-set-the-ttl-on-a-row
