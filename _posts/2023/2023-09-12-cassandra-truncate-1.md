---
layout: post
title:  "[Cassandra] Truncate 작업하기"
date:   2023-09-12 09:00:00 +0900
categories:
- database
tags:
- cassandra

---

- `Table` 에 대해서 데이터를 비우는 처리할 겸 `truncate` 작업에 대한 기록
- https://docs.datastax.com/en/cql-oss/3.x/cql/cql_reference/cqlTruncate.html

## 테스트용 테이블

```sql
CREATE TABLE temp_test (
id text, 
value text, 
PRIMARY KEY (id)
);
```

## 테스트 데이터 추가
- 아래 데이터를 추가하더라도 바로 SSTable 로 내려가지 않으므로 하나 더 추가가 필요함.

```sql
INSERT INTO temp_ttl_test (id,value) VALUES ('1', 'a');
INSERT INTO temp_ttl_test (id,value) VALUES ('2', 'b');
INSERT INTO temp_ttl_test (id,value) VALUES ('3', 'b');
INSERT INTO temp_ttl_test (id,value) VALUES ('4', 'b');
INSERT INTO temp_ttl_test (id,value) VALUES ('5', 'b');
```

- (실제 운영할 때는 필요없을 듯) flush
  - memtable 데이터를 SSTable 로 내릴 수 있도록 함. 그래야 `tablestats` 로 데이터 확인 가능

> nodetool flush

## tablestats 정보 확인하기

```
# nodetool tablestats truncate_test.temp_test
Total number of tables: 48
----------------
Keyspace : truncate_test
        Read Count: 0
        Read Latency: NaN ms
        Write Count: 7
        Write Latency: 0.26357142857142857 ms
        Pending Flushes: 0
                Table: temp_test
                SSTable count: 1
                Old SSTable count: 0
                Space used (live): 5048 //참고
                Space used (total): 5048 //참고
                Space used by snapshots (total): 0 //참고
                Off heap memory used (total): 37
                SSTable Compression Ratio: 0.5905511811023622
                Number of partitions (estimate): 5
                Memtable cell count: 0
                Memtable data size: 0
                Memtable off heap memory used: 0
                Memtable switch count: 1
                Local read count: 0
                Local read latency: NaN ms
                Local write count: 5
                Local write latency: 0.035 ms
                Pending flushes: 0
                Percent repaired: 0.0
                Bytes repaired: 0.000KiB
                Bytes unrepaired: 0.124KiB
                Bytes pending repair: 0.000KiB
                Bloom filter false positives: 0
                Bloom filter false ratio: 0.00000
                Bloom filter space used: 24
                Bloom filter off heap memory used: 16
                Index summary off heap memory used: 13
                Compression metadata off heap memory used: 8
                Compacted partition minimum bytes: 21
                Compacted partition maximum bytes: 29
                Compacted partition mean bytes: 28
                Average live cells per slice (last five minutes): NaN
                Maximum live cells per slice (last five minutes): 0
                Average tombstones per slice (last five minutes): NaN
                Maximum tombstones per slice (last five minutes): 0
                Dropped Mutations: 0
                Droppable tombstone ratio: 0.00000
```

## cql 에서 truncate 처리하기

> cqlsh 로 접근

- 만약 데이터 양이 많을 경우 `cqlsh` 가 timeout 이 기본 10s 이므로 추가 설정 필요

> cqlsh --request-timeout=3600

- 단, 이렇게 처리한다고 해서 바로 서버의 disk 사용량이 줄어들지 않는다.
  - 해당 데이터도 같이 날려줘야함.

- tablestats 를 통해서 확인해보면 다음과 같이 되어있음을 알 수 있다.
  - snapshot 데이터 제거처리 필요
```
Space used (live): 0
Space used (total): 0
Space used by snapshots (total): 5048
```

## snapshot 제거하기
- 전체 제거하기

> nodetool clearsnapshot --all

- 이후 다시 tablestats 를 입력하게 되면 아래처럼 데이터 제거 됨을 확인할 수 있고, disk 사용량도 줄어든걸 확인 할 수 있다.

```
Space used (live): 0
Space used (total): 0
Space used by snapshots (total): 0
```