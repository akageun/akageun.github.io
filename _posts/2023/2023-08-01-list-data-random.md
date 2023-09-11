---
layout: post
title:  "목록 데이터에 대한 랜덤 처리"
date:   2023-08-01 09:00:00 +0900
categories:
- program
tags:
- java
- cache

---

- 아래 정리한 내용에 대해서 좀 더 리소스를 절감하여 운영할 수 있는 방법이 없을까 고민하며 작성한 글이다.
- 목록 데이터가 있고, 해당 데이터들에 대한 변경은 정말 가끔 있고, 서버간 싱크도 한동안 안맞아도 되는 스팩이였다.
- 단, 랜덤으로 n 개를 뽑아서 보여줘야 했다.

## 1. 환경
- 작은 Mysql DB 와 메모리가 조금 큰 WAS 를 구축할 수 있었던 상황.

## 2. 내가 원하는 방향!
- DB 에 접근을 줄여보자!
- 효율적으로 랜덤 처리를 해보자!
- 고가용성!!!

## 3. 목록 관리
- DB 에 직접 insert 하여 metadata 를 관리하였다.
- 단순하게 SELECT * FROM ${TABLE_NAME} 을 하게 되면 충분히 데이터를 가져올 수 있는 상황.
  - 전체 데이터가 적은 상황.

## 4. 개발시작.(with 검토)
### 4-1. RDB(mysql) 을 이용해보자. (x)
- 아래와 같은 쿼리로 동작시킬 수 있다.

> SELECT * FROM ${TABLE_NAME} `ORDER BY RAND()`

- 1개만 가져올 경우는 LIMIT ${SIZE} 를 추가하여 사용 가능

> SELECT * FROM ${TABLE_NAME} ORDER BY RAND() `LIMIT 1` 

- `단점`으로 메모리에 데이터를 올려서 랜덤처리 하므로, 비용이 많이 발생됨.
  - 트래픽이 몰리면 DB 가 아파함.
  - WAS 에 대해서 오토스케일링 등으로 대비하기가 어려움. 

### 4-2. JAVA 에서 랜덤처리를 해보자.
- 목록이 있고, shuffle 메소드를 이용해서 첫번째 요소를 꺼내서 확인해보자.

```java

List<String> metaList = new ArrayList<>();

metaList.add("a");
metaList.add("b");
metaList.add("c");
metaList.add("d");
metaList.add("e");
metaList.add("f");
metaList.add("g");

Collections.shuffle(metaList);

log.info("selected item : {}, list : {}", metaList.get(0), metaList);

```

- 위에 로직을 DB 에 연결 시킨다면 다음과 같을 것이다.

```java
List<String> metaList = repository.findAll();

Collections.shuffle(metaList);

String selectItem = metaList.get(0); //랜덤한 아이템

log.info("selected item : {}, list : {}", selectItem, metaList);
```

#### 4-3-1. DB 조회를 줄여보자. (shuffle and localCache)
- findAll 로 외부 인프라 조회에 대해서 `cache` 를 추가
- `Redis` 를 사용하지 않으므로, `GlobalCache` 는 적용하지 않고, `LocalCache` 목적으로 `ehcache`나 `caffeineCache` 를 도입할 예정

> 해당 내용에서는 Local Cache 설정에 대해서는 정리하지 않았습니다.

```java
@Cacheable(cacheNames = "testCache")
public List<String> getList() {
    return repository.findAll();
    //해당 데이터는 다음과 같이 mock 으로 처리함
    /**
     metaList.add("a");
     metaList.add("b");
     metaList.add("c");
     metaList.add("d");
     metaList.add("e");
     metaList.add("f");
     metaList.add("g");
    */    

}
```

- presentation layer level 에서 shuffle 처리

```java
List<String> cachedList = testService.getList();

log.info("before Shuffle :{}",cachedList );
Collections.shuffle(cachedList);
log.info("select item : {}", cachedList.get(0));
log.info("after Shuffle :{}", cachedList);
```

- 결과
  - localCache 한 내용물 자체를 shuffle 하기 때문에 두번째 호출부터는 의도한 결과값이 아니다.
    - 일관된 목록에 일관된 랜덤으로 제공이 목적이므로 해당 로직은 잘못됨.
  - DeepCopy 를 통하여 처리할 수 있지만, 불필요해 보임.
    - 매번 DeepCopy 하여 사용할 경우, 예제에는 String 으로 되어있지만, Object 이고 내부 필드가 여러번 하위로 내려갈 경우 비용이 많이 쌔다.

```
before Shuffle :[a, b, c, d, e, f, g] //첫번째 호출
select item : e
after Shuffle :[e, f, b, g, a, c, d] //첫번째 호출
----
before Shuffle :[e, f, b, g, a, c, d] //두번째 호출
select item : f
after Shuffle :[f, g, a, e, c, b, d] //두번째 호출
```

#### 4-3-2. DB 조회를 줄여보자 (random and localCache)
- 일단 findAll 하여 localCache 추가한 부분까지는 동일하다.
- 단, shuffle 이 아닌 다른 방식으로 랜덤처리를 하려고 한다.

- presentation layer level 에서 random 처리

> 해당 내용에서는 `Java Random Class` 에 대한 Seed 값으로 인한 이슈 등은 다루지 않습니다.

```java
List<String> cachedList = testService.getList();

log.info("before Shuffle :{}", cachedList);

int randomIndex = new Random().nextInt(0, cachedList.size() - 1);

log.info("select item : {}", cachedList.get(randomIndex));
log.info("after Shuffle :{}", cachedList);
```

- 결과
  - 원본 목록도 수정되지 않고, 랜덤도 잘 진행되었다. 

```
before Shuffle :[a, b, c, d, e, f, g] //첫번째 호출
select item : d
after Shuffle :[a, b, c, d, e, f, g]  //첫번째 호출

------

before Shuffle :[a, b, c, d, e, f, g] //두번째 호출
select item : f
after Shuffle :[a, b, c, d, e, f, g] //두번째 호출
```

## 5. 결론
- 간단한 작업이였지만, localCache 및 random 함수 등을 잘 사용하여 서비스를 좀 더 안정적으로 운영할 수 있게 되었다.
  - 간단한 고민과 함께~
- 작업하면서 조금만 더 신경쓰면 훨씬 좋은 퀄리티와 편안한 퇴근시간을 만들어주는 코드를 생산할 수 있다.
- (역시 이런 작업하면서 개발하는게 꿀잼...)