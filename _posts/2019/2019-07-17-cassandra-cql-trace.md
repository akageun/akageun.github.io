---
layout: post
title:  "Cassandra CQL 추적하기"
date:   2019-07-17 09:00:00 +0900
categories:
 - database
tags: 
 - cassandra
---

# Cassandra CQL 추적하기
- 카산드라 전체에서 읽고 쓰는 과정을 추적할 수 있게 해줌.

```
cqlsh> tracing on;
Now tracing requests.
cqlsh> use [KEYSPACE];
```
#### system_traces.sessions
- 최대 24시간 동안 보관 됩니다.(TTL에 따라 다를 수 있음)

```cql
select * from system_traces.sessions;
```

#### system_traces.events
- trace event 관련해서 내용이 보관됩니다.
- sessions 테이블에서 session_id를 가지고 와서 events 테이블에서 검색하게되면 해당 내용을 조회 할 수 있음.

```cql
select * from system_traces.events where session_id = ${session_id};
```

- `activity` : 처리과정
- `source_elapsed` : 경과시간

---
## 참고링크
- https://docs.datastax.com/en/archived/cql/3.3/cql/cql_reference/cqlshTracing.html

