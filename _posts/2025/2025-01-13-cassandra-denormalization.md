---
layout: post
title:  "[Cassandra] denormalization 그리고 주의할 점"
date:   2025-01-13 09:00:00 +0900
categories:
- database
tags:
- cassandra

---
- Cassnadra 의 Denormalization 에 대해서 알아보고, 실무에서 사용시에 주의할 점에 대해서 알아보자.

# Denormalization 은?
- Cassandra 공식 홈페이지에 정리된 내용은 아래와 같다.
  - https://cassandra.apache.org/_/glossary.html#denormalization
- `중복 데이터를 복제(추가)하여 읽기 성능을 최적화하는 프로세스`와 같은걸 말한다.

## 왜? Cassandra 에서는 이런 개념이 필요할까?
- Cassandra 에서 Select 를 할 때, Where 조건에는 `Partition Key` 와 `Cluster Key` 밖에 사용하지 못함.
  - 물론 Secondary Index 를 걸면 사용 가능하다, 성능상 비효율적인 부분이 있으므로 사용을 지양한다.
- `Query-Driven` 형태로 개발이 진행되다보면, 역방향(Regular Column의 값으로 조회)에 대한 기능이 필요할 수 있다.
  - `Partition Key` 와 `Cluster Key`를 다르게 지정하여 중복 저장해서 해당 니즈들을 해결할 수 있다.
  - Cassandra 에서는 어떻게 대응할 수 있을까?

### `Secondary Index 에 대해서(With Cassandra)
- 물리적으로 테이블을 정렬하지 않고, Data table 과 별개로 정렬된 인덱스를 생성하고 관리함.
  - 비 클러스터형 인덱스나 보조 인덱스라고도 불린다.
- Cassandra Secondary Index 생성 및 사용 법
  - https://cassandra.apache.org/doc/5.0/cassandra/developing/cql/indexing/2i/2i-working-with.html#create-a-secondary-index-2i

-  그럼 왜 실무에서 `Secondary Index` 를 사용하지 않고, 위와 같이 데이터 복제를 통해 사용하는 형태가 더 좋은 것일까?

## 예제 데이터 보기
- 샘플 데이터

```cql
CREATE TABLE IF NOT EXIST sec_index_test(
    id BIGINT,
    title TEXT NOT NULL,
    view_count BIGINT,
    creator TEXT,
    PRIMARY KEY (id)
)

INSERT INTO sec_index_test(id, title, view_count, creator) VALUES(1, 'title1', 100, 'creator1')
INSERT INTO sec_index_test(id, title, view_count, creator) VALUES(2, 'title2', 200, 'creator2')
INSERT INTO sec_index_test(id, title, view_count, creator) VALUES(3, 'title3', 300, 'creator3')
INSERT INTO sec_index_test(id, title, view_count, creator) VALUES(4, 'title4', 400, 'creator4')
INSERT INTO sec_index_test(id, title, view_count, creator) VALUES(5, 'title5', 500, 'creator4')

//위 테이블에 대한 조회 방법

SELECT * FROM sec_index_test WHERE id = '1';
```

- 만약 `creator` 로 조회하고 싶다면?

```cql
CREATE INDEX IF NOT EXIST IDX_CREATOR ON sec_index_test(creator); //secondary index 생성

SELECT * FROM sec_index_test WHERE creator = 'creator4';
```

- 위와 같은 데이터를 생성한다면 어떻게 동작할까?
  - Secondary Index 용으로 테이블을 따로 저장한다.
    - `creator` 값은 key 가 되고, 나머지 값들은 value 로 설정되어 저장됨.
  - 조회할 때는?
    - 조회에 필요한 Key 를 가져온다. 그 값으로 실제 데이터를 `In` 쿼리와 같은 형태로 조회함.
      - 파티션이 달라질 경우 n 번 발생 등...
  - 저장위치 및 조회 요청...
    - Secondary Index 테이블에 대한 데이터는 실제 데이터와 같은 노드에 저장됨.
      - partition key 는 해싱한 값으로나 다른 방식으로 저장 위치를 알 수 있지만, Secondary Index 로 지정한 regular column 의 값은 저장 위치를 알 수 없다.
    - 그렇기 때문에 코디네이터가 조회 요청을 받게 되면, 어느 노드로 가야할지 모르는 상황이므로 모든 노드에 요청을 보냄.
    - 모든 노드에 요청을 보내야하므로 요청시간도 길어지고 응답에 대한 보장도 없어지기 때문에 해당 기능을 지양하는 것이다.

## Denormalization 하는 방법
### 설명하기 전 예제 쿼리
```cq
//sec_index_test 에 대한 역방향에 대한 테이블

CREATE TABLE IF NOT EXIST sec_index_test_creator(
    creator TEXT,
    id BIGINT,
    title TEXT NOT NULL,
    view_count BIGINT,
    PRIMARY KEY (creator, id) //PartitionKey : creator, ClusterKey : id
)
```

```
// 위 예제 데이터를 `sec_index_test_creator` 에 저장한다면 아래와 같음.

- key : creator1
  - value : 1, 'title1', 100
- key : creator2
  - value : 2, 'title2', 200
- key : creator3
  - value : 3, 'title3', 300
- key : creator4
  - value : 4, 'title4', 400
  - value : 5, 'title5', 500
```

### 저장하기
- https://docs.datastax.com/en/cql-oss/3.x/cql/cql_reference/cqlBatch.html
- 해당 쿼리로 처리한다면 원자성이 보장됨. (고립성은 보장 안함, 동시에 여러 요청을 보낼 경우 배치 내부 쿼리 순서가 지켜지지 않을 수 있음.  필요할 경우, Timestamp 기능일 이용하여 처리할 수는 있다.)
- `Cassandra` 의 경우, 쓰기 성능이 좋기 때문에 아래와 같이 사용해도 크게 문제는 되지 않는다.
  - 단, `Multi-Partition`에 대한 이슈가 있다.

```
BEGIN BATCH
INSERT INTO sec_index_test(id, title, view_count, creator) VALUES(1, 'title1', 100, 'creator1')
INSERT INTO sec_index_test_creator(creator, id, title, view_count) VALUES('creator1', 1, 'title1', 100)
APPLY BATCH;
```

## 고려해야하는 Multi-Partition 이슈는?
- Cassandra.yml 설정을 보면, 아래와 같은 두 설정이 있음.
- `batch_size_warn_threshold`, `batch_size_fail_threshold` 를 볼 수 있다. [바로가기](https://cassandra.apache.org/doc/stable/cassandra/configuration/cass_yaml_file.html#batch_size_warn_threshold)
- fail 설정을 보면 warn 사이즈의 10대로 세팅되는데, 50kb 로 되어 있으므로, 만약 BATCH 로 insert 등 처리할 때 내용이 크게 되면 실패가 날 수 있다.
- 예를 들어, 게시글의 `content` 와 같은 `사용자가 작성한 내용`을 저장할 경우 50kb 를 넘어갈 수 있다.
- 특별한 이유가 없다면 위 두 설정값은 변경하지 않는 것이 좋다.
  - 큰 사이즈의 데이터를 하나의 코디네이터가 받게 될 것이고 처리하는데 부담이 될 것이다. 추가로 commit log 등에 대한 부하도 예상 됩니다.
    - 단, 스킬라는 좀 더 큰 사이즈로 설정되어있어서 어떤 점이 다른지는 확인이 필요해 보인다.
    - https://github.com/scylladb/scylladb/blob/master/conf/scylla.yaml
  - 그럼 어떻게 하는게 좋을까?

# 결론
- 여러 기능을 커버해야할 경우, Denormalization 와 같이 여러 테이블에 넣어서 처리하면 된다.
  - Secondary Index 는 성능상 이슈가 있을 수 있으므로 지양하는 것이 좋다.
- 여러 테이블에 넣을 때, 데이터 사이즈가 클 경우 Multi-Partition 이슈를 대비하는 것이 좋다.
  - 데이터 사이즈가 큰 걸 넣어야할 경우, 단일 파티션으로 처리 할 수 있도록 설계하는 것이 좋다.

# 참고자료
- RDBMS 와 Cassandra 의 설계 차이점
  - https://cassandra.apache.org/doc/5.0/cassandra/developing/data-modeling/data-modeling_rdbms.html

