---
layout: post
title:  "[Cassandra] Counter Column 에 대해서"
date:   2022-04-04 09:00:00 +0900
categories:
- database
tags:
- cassandra
---
# Cassandra Counter Column 에 대해서
- Counter Type 에 대해서 : https://docs.datastax.com/en/cql-oss/3.3/cql/cql_reference/counter_type.html
  - 그외 참고 링크
    - https://docs.datastax.com/en/cql-oss/3.3/cql/cql_using/useCountersConcept.html
    - https://www.datastax.com/blog/whats-new-cassandra-21-better-implementation-counters
    - https://docs.datastax.com/en/archived/cql/3.1/cql/cql_using/use_counter_t.html

- 조회수 기능을 구현한다는 가정을 하고 '조회 방식', '조회수 올리기' 등을 테스트 해봄.

- 테스트 하기위해서 테이블을 만들어보자
  - 공식문서에서 권장하는 것처럼 Conter Column 만 있는 테이블을 따로 분리하여 생성
    - 권장하는 이유는 아마도 commit log 기반으로해서 `델타` 값만 올리는 형태로 동작하기 때문인듯... (이 조건때문에 아래 몇가지 제약사항들이 생기는 것 같다.)

- 테스트용 테이블
  - service_id : partitionKey
  - content_id, episode_id : clusteringKey
  
```sql
CREATE TABLE cass_counter_test (
  service_id text,
  content_id text,
  episode_id text,
  view_count counter,
  PRIMARY KEY (service_id, content_id, episode_id)
)
WITH CLUSTERING ORDER BY (content_id DESC, episode_id DESC)
```

- insert 할 필요 없이 PK 로 지정하여 `update` 를 사용하면 된다.
  - or `view_count = view_count - ?`
    
```sql
update cass_counter_test set 
view_count = view_count + ? 
where service_id = ? 
and content_id = ? 
and episode_id = ?
```

#### 제약사항
- TTL 이나 timestamp 등 적용이 안된다.

> Define a counter in a dedicated table only and use the [counter data type](https://docs.datastax.com/en/archived/cql/3.1/cql/cql_reference/counter_type.html). You cannot index, delete, or re-add a counter column. All non-counter columns in the table must be defined as part of the primary key. To load data into a counter column, or to increase or decrease the value of the counter, use the UPDATE command. Cassandra rejects USING TIMESTAMP or USING TTL in the command to update a counter column.

- insert 를 할 수 없다.

> INSERT statements are not allowed on counter tables, use UPDATE instead

- update 시에 `set` 형태로 사용할 수 없다.

> Cannot set the value of counter column reaction_count (counters can only be incremented/decremented, not set)

```sql
update cass_counter_test set 
view_count = ? 
where service_id = ? 
and content_id = ? 
and episode_id = ?
```

- Random Bulk Get
  - 만약 multi-column 으로 조회할 경우에는 제약사항이 있으니 참고!
  - Multi-column relations can only be applied to clustering columns but was applied to: partition_key
  
```sql
SELECT * FROM cass_counter_test
WHERE service_id= ?
and (content_id, episode_id) IN ((?), (?))
```

- aggregation

```sql
SELECT service_id, content_id, sum(view_count) as total FROM cass_counter_test
WHERE service_id= ?
and (content_id, episode_id) IN ((?), (?))
GROUP BY service_id, content_id, episode_id
```

