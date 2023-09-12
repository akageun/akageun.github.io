---
layout: post
title:  "[Cassandra] 기존 table 에 TTL 을 추가하면 어떻게 될까?"
date:   2023-09-01 09:00:00 +0900
categories:
- database
tags:
- cassandra

---

- 기존에 운영 중이던 테이블에 ttl 을 추가할 경우 어떻게 동작하는지 확인하기
  - 운영을 하다가 정책 변경 등으로 인해 테이블 변경이 있을 예정이라, 검증 겸 정리해봄 

- 테스트용 테이블
```sql
CREATE TABLE temp_ttl_test (
    id text,
    value text,
    PRIMARY KEY (id)
) 
```


- ttl 추가 전 데이터 추가

```sql

INSERT INTO temp_ttl_test (id,value) VALUES ('1', 'a');
INSERT INTO temp_ttl_test (id,value) VALUES ('2', 'b');

```

- ttl 추가(gc_grace_seconds 도 같이 변경)
  - 1분 뒤 tombstone 이 추가되고, 2분 뒤 tombstone 데이터 제거처리

```sql
alter table temp_ttl_test with gc_grace_seconds = 120 and default_time_to_live = 60;
```


- ttl 추가 후 데이터 insert
```sql
INSERT INTO temp_ttl_test (id,value) VALUES ('3', 'c');
```

- 데이터 조회쿼리

```sql
select * from temp_ttl_test;
```


- ttl 도달 전 데이터 조회
```
 id | value
----+-------
  3 |     c
  2 |     b
  1 |     a
```

- ttl 도달 후 데이터 조회

```
 id | value
----+-------
  2 |     b
  1 |     a
```

- ttl 값 조회
```sql
select ttl(value) from temp_ttl_test
```

```
 ttl(value)
------------
         45
       null
       null
```