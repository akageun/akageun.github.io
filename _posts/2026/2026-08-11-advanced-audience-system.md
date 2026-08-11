---
layout: post
title:  "공통 Audience System 을 설계하며 고민한 것들"
date:   2026-08-11 09:00:00 +0900
categories:
- architecture
tags:
- audience
- cassandra
- redis
- cache
- system-design
---

- 여러 서비스에서 공통으로 사용할 수 있는 `Audience System` 을 구축한 경험을 정리해보려고 한다.
- 처음 요구사항은 단순했다.

> 대상자를 전달받아 저장하고, 필요한 시스템에서 사용할 수 있게 해주세요.

- 하지만 실제로 설계를 시작하니 단순히 데이터를 저장하는 것만으로는 부족했다.
  - 수천만 명의 사용자가 포함된 집단을 어떻게 빠르게 저장할 것인가?
  - 특정 사용자가 집단에 포함되는지 어떻게 빠르게 판단할 것인가?
  - 한 요청에서 여러 집단을 확인해야 할 때 조회 횟수를 어떻게 줄일 것인가?
  - 같은 데이터에 트래픽이 몰렸을 때 저장소와 캐시를 어떻게 보호할 것인가?

# Audience System 이란?

- 이 글에서 `Audience` 는 특정 조건이나 목적에 따라 구성한 사용자 집단을 의미한다.
- 예를 들면 아래와 같다.
  - 최근 30일 이내 구매한 사용자
  - 특정 지역에 거주하는 사용자
  - 신규 기능 실험 대상자
  - 특정 프로모션을 노출할 사용자
- 배너, 프로모션, A/B Test 같은 시스템은 사용자 요청이 들어올 때 Audience 포함 여부를 조회한다.

```text
User Request
    -> Audience API
        -> 이 사용자가 audience-a 에 포함되는가?
```

- Audience 를 만드는 작업은 대량의 쓰기가 중심이고, 실제 서비스에 제공하는 과정은 짧은 응답 시간이 중요한 읽기 작업이다.
- 두 작업은 트래픽의 성격이 다르기 때문에 생성과 조회 경로를 분리해서 생각했다.

# 요구사항 정리

## Audience 생성

- 외부 시스템에서 `audience_id` 와 사용자 목록을 전달한다.
- 한 Audience 에 수백만~수천만 명이 포함될 수 있다.
- 데이터 전체를 한 번에 메모리에 올리지 않고 나눠서 저장할 수 있어야 한다.
- 저장 중 일부가 실패했을 때 재처리할 수 있어야 한다.

## Audience 조회 : Server

- `user_id` 와 `audience_id` 를 기준으로 포함 여부를 빠르게 확인해야 한다.
- 하나의 사용자 요청에서 여러 Audience 를 동시에 확인할 수 있어야 한다.
- 특정 배너나 프로모션에 요청이 몰려도 저장소까지 트래픽이 그대로 전달되면 안 된다.
- Audience 변경이 조회 경로에 반영되는 시점과 캐시 TTL 사이의 일관성 기준이 필요하다.

## Audience 설정 : 운영 관리자

- 배너나 프로모션 등에서 Audience 를 설정을 한다.
- 내부 관리도구에서 이 기능과 관련한 비슷한 기능 개발 비용을 낮추고 싶다.

# 데이터베이스 선정과정

## 검토한 내용

## RDB 를 사용하지 않은 이유

# 어떻게 사용하게 할 것인가?

## 관리도구

## System -> Audience System




# Cassandra 를 선택한 이유

- Audience 생성은 많은 사용자를 순차적으로 추가하는 Write 중심의 작업이다.
- Cassandra 는 LSM Tree 계열의 Storage Engine 을 사용한다.
  - Write 는 Commit Log 에 append 된다.
  - Memtable 에 기록된다.
  - 이후 Immutable SSTable 로 flush 된다.
- 기존 디스크 페이지를 매번 찾아 수정하는 구조보다 대량 INSERT 형태의 Workload 에 잘 맞았다.

- 다만 `Cassandra 는 쓰기가 빠르다`는 이유만으로 선택한 것은 아니다.
- Serving 에 필요한 Query 를 Partition Key 기반으로 제한할 수 있었고, 조회 방향에 맞춰 데이터를 미리 만들어 둘 수 있었기 때문이다.

# Query Driven Modeling

- RDBMS 를 사용하면 정규화된 데이터를 저장하고 JOIN 또는 Index 로 필요한 결과를 조회하는 방식을 먼저 생각하기 쉽다.
- Cassandra 의 데이터 모델링은 반대 방향에서 시작한다.

> 어떤 데이터를 저장할 것인가보다 어떤 Query 를 제공할 것인가를 먼저 정한다.

- Cassandra 에서는 하나의 Query 가 접근하는 Partition 수를 줄이는 것이 중요하다.
- 필요한 조회 패턴마다 테이블을 만들고, 같은 데이터를 여러 테이블에 중복 저장하는 Denormalization 이 자연스럽다.

## Audience 중심 테이블

- Audience 를 만들고 관리하는 관점에서는 아래 구조가 자연스럽다.

```cql
CREATE TABLE audience_members_by_audience (
    audience_id text,
    user_id text,
    created_at timestamp,
    PRIMARY KEY (audience_id, user_id)
);
```

- `audience_id` 가 Partition Key 이므로 특정 Audience 에 속한 사용자를 조회하기 좋다.

```cql
SELECT user_id
FROM audience_members_by_audience
WHERE audience_id = ?;
```

- 하지만 실제 Online Serving 에서 자주 필요한 질문은 반대였다.

> 이 Audience 의 사용자는 누구인가?

- 보다는

> 이 사용자는 어떤 Audience 에 속해 있는가?

- 를 더 자주 조회했다.

# 여러 Audience 를 한 번에 조회할 때의 문제

- 하나의 페이지에 여러 배너와 프로모션이 있다고 가정해보자.
- 사용자 한 명에 대해 다음 Audience 를 모두 확인해야 할 수 있다.

```text
new-user
paid-user
event-a
event-b
recommendation-target
```

- 데이터가 Audience 중심으로만 저장되어 있다면 Audience 수만큼 서로 다른 Partition 을 조회해야 한다.

```text
user-1 + audience-a -> Partition Read
user-1 + audience-b -> Partition Read
user-1 + audience-c -> Partition Read
user-1 + audience-d -> Partition Read
```

- 조회할 Audience 가 늘어나면 Network Round Trip 과 Cassandra Partition Read 도 함께 증가한다.
- 그래서 Serving Query 의 방향에 맞는 데이터를 하나 더 만들었다.

# User 중심의 Feed 구조

- 기존의 `Audience -> User` 구조를 뒤집어 `User -> Audience` 테이블을 추가했다.
- 사용자별 Audience Feed 라고 생각할 수 있다.

```cql
CREATE TABLE audiences_by_user (
    user_id text,
    audience_id text,
    created_at timestamp,
    PRIMARY KEY (user_id, audience_id)
);
```

```text
user-1
  - audience-a
  - audience-c
  - audience-e

user-2
  - audience-b
  - audience-d
```

- `user_id` 가 Partition Key 이므로 한 번의 Partition Read 로 사용자가 속한 Audience 목록을 가져올 수 있다.

```cql
SELECT audience_id
FROM audiences_by_user
WHERE user_id = ?;
```

- API 가 확인해야 하는 Audience 목록과 조회 결과의 교집합은 Application 에서 계산한다.

```text
requested = [audience-a, audience-b, audience-c]
joined    = [audience-a, audience-c, audience-e]
result    = [audience-a, audience-c]
```

- 결과적으로 여러 번의 원격 조회를 하나의 Partition Read 로 바꿀 수 있었다.
- 동일한 membership 정보를 아래 두 방향으로 저장하는 셈이다.
  - `Audience -> User`: 생성, 관리, Export 용도
  - `User -> Audience`: Online Serving 용도

## Partition 크기는 반드시 확인해야 한다

- User 중심의 구조도 항상 정답은 아니다.
- 한 사용자가 포함될 수 있는 Audience 수에 현실적인 상한이 있다면 User 단위 Partition 이 잘 맞는다.
- 반대로 한 사용자가 매우 많은 Audience 에 포함될 수 있다면 Partition 이 지나치게 커질 수 있다.
- 이 경우 아래처럼 Bucket 을 추가하는 방법을 고려할 수 있다.

```cql
PRIMARY KEY ((user_id, bucket), audience_id)
```

- 하지만 Bucket 수가 늘면 다시 여러 Partition 을 조회해야 한다.
- 결국 `Partition 크기`와 `한 요청에서 읽어야 하는 Partition 수` 사이의 균형이 중요하다.

# Cache Layer

- Online Serving 에서 매번 Cassandra 를 직접 조회하지 않도록 Redis 를 Cache Layer 로 사용했다.

```text
Application -> Redis -> Cassandra
```

- Redis 는 반복 조회를 빠르게 처리하고 Cassandra 로 전달되는 요청을 줄여준다.
- 하지만 Redis 를 추가한 것만으로 문제가 모두 해결되는 것은 아니었다.
- 한 번의 사용자 요청이 여러 Audience 조회로 증폭되거나 특정 Key 에 트래픽이 집중되면 Redis 가 새로운 중앙 병목이 될 수 있다.

## Redis 가 순간적으로 느려지는 이유

- Redis 는 네트워크 I/O 등 일부 작업에 Thread 를 사용하지만, Command 실행 경로는 주로 하나의 Thread 에서 순차적으로 처리한다.
- 일반적인 `GET`, `SET` 같은 짧은 Command 에서는 이 구조가 문제가 되지 않는다.
- 하지만 오래 걸리는 Command, 큰 Value, Hot Key 또는 순간적인 요청 증가가 발생하면 뒤의 요청이 대기한다.

- 이때 Application 에서는 흔히 아래와 같이 표현한다.

> Redis 때문에 Node 가 얼었다.

- 실제로 프로세스가 멈춘 것이라기보다 Redis 응답을 기다리는 요청이 쌓이면서 Event Loop 와 Connection Pool 주변의 대기 시간이 길어지고, Tail Latency 가 급격히 증가한 상태에 가깝다.
- 따라서 Redis 의 평균 응답 시간만 보는 것으로는 부족하다.
  - p95, p99 응답 시간
  - Slow Log
  - Command 별 시간 복잡도
  - Connection Pool 대기 시간
  - Hot Key 와 큰 Value
- 등을 같이 확인해야 한다.

# Redis 앞에 Local Cache 추가하기

- Redis 에 집중되는 짧은 순간의 반복 요청을 흡수하기 위해 Application 내부에 Local Cache 를 추가했다.

```text
Request
  -> Local Cache (L1)
      -> Redis (L2)
          -> Cassandra
```

- Local Cache 의 첫 번째 목적은 Cassandra 가 아니라 Redis 를 보호하는 것이다.
- 같은 데이터가 짧은 시간 동안 반복 조회된다면 매번 Network 를 타고 Redis 까지 갈 필요가 없다.

```text
첫 번째 요청  -> Local Cache Miss -> Redis 조회
이후 요청     -> Local Cache Hit  -> 즉시 반환
```

- Local Cache 는 전체 데이터를 담는 저장소가 아니다.
- `User x Audience` 조합으로 만들 수 있는 Key Space 는 매우 크므로 모든 데이터를 담으려 하면 Application 메모리가 먼저 문제가 된다.
- 아래처럼 역할을 제한했다.
  - 작은 최대 크기
  - 짧은 TTL
  - LRU 또는 사용 빈도 기반 Eviction
  - 반복되는 Hot Request 를 잠깐 흡수하는 완충 계층

## Cache Stampede 방어

- Local Cache 를 사용해도 같은 Key 가 만료되는 순간 요청이 동시에 들어오면 모두 Redis 를 조회할 수 있다.
- 동일한 Key 에 대한 진행 중인 조회를 하나로 합치는 `Request Coalescing` 또는 `Singleflight` 방식을 적용할 수 있다.

```text
request-1 --+
request-2 --+--> 하나의 Redis 조회 --> 같은 결과 공유
request-3 --+
```

- TTL 에 작은 Jitter 를 추가하면 많은 Key 가 같은 시점에 만료되는 현상도 줄일 수 있다.
- Negative Cache 를 사용할 때는 존재하지 않는 결과가 변경을 늦게 반영하지 않도록 더 짧은 TTL 을 사용해야 한다.

## Cache Key 선택

- `user_id + audience_id` 를 Key 로 사용하면 단건 포함 여부 조회는 단순하다.
- 하지만 한 요청에서 여러 Audience 를 확인하면 Redis 요청 수도 함께 증가할 수 있다.
- User 중심 Feed 를 Cache Value 로 사용하면 한 번의 조회로 여러 Audience 를 판단할 수 있다.

```text
key   : audiences:user-1
value : [audience-a, audience-c, audience-e]
```

- 데이터 크기, 갱신 빈도, 한 번에 확인하는 Audience 수에 따라 두 방식을 선택하거나 함께 사용할 수 있다.
- 중요한 것은 Cache 자료구조도 저장 편의가 아니라 실제 조회 패턴을 기준으로 정하는 것이다.

# Cassandra 의 Read Path

- `Cassandra 는 쓰기는 빠르지만 읽기는 느리다`고 단순하게 말하는 것은 정확하지 않다.
- 임의 검색이나 여러 Partition Scan 을 사용하면 비용이 커질 수 있지만, Partition Key 를 알고 있는 단순 조회는 Cassandra 가 잘 처리할 수 있는 패턴이다.

- Read Path 를 단순화하면 아래와 같다.

```text
Partition Read
  -> Memtable 확인
  -> Bloom Filter 로 확인할 SSTable 선별
  -> SSTable Index 로 데이터 위치 탐색
  -> OS Page Cache 또는 Disk 에서 데이터 읽기
  -> 여러 Version 을 reconcile
```

## Memtable

- 최근에 기록된 데이터는 아직 Memtable 에 존재할 수 있다.
- 필요한 경우 Memtable 과 여러 SSTable 에서 읽은 데이터를 합쳐 최종 결과를 만든다.

## Bloom Filter

- 각 SSTable 의 Bloom Filter 는 요청한 Partition 이 해당 SSTable 에 있을 가능성을 판단한다.
  - 없다고 판단하면 실제로 없다.
  - 있다고 판단하면 있을 수도 있으므로 확인이 필요하다.
- False Positive 는 가능하지만 False Negative 는 발생하지 않는다.
- 이를 통해 Partition 이 없는 SSTable 의 불필요한 Disk 접근을 줄일 수 있다.

## SSTable Index

- 확인이 필요한 SSTable 에서는 Index 정보를 이용해 Partition 의 위치를 찾는다.
- 전체 SSTable 을 처음부터 순차 탐색하지 않고 필요한 위치로 접근한다.

## OS Page Cache

- Cassandra 는 모든 데이터를 JVM Heap 에 캐싱하지 않는다.
- 반복해서 읽는 Disk Page 는 운영체제의 Page Cache 에 남을 수 있다.
- Working Set 이 메모리에 잘 유지되면 실제 Disk I/O 없이 데이터를 읽을 수 있다.

## Read Amplification

- LSM Tree 가 읽기에서도 항상 유리한 것은 아니다.
- 같은 Partition 의 여러 Version 이 많은 SSTable 에 흩어져 있다면 여러 파일을 확인해야 한다.
- Tombstone 이 많거나 Partition 이 너무 큰 경우에도 읽기 비용이 증가할 수 있다.
- 따라서 아래 항목을 같이 관리해야 한다.
  - Compaction 전략
  - SSTable 개수
  - Partition 크기
  - Tombstone
  - Bloom Filter False Positive 비율

# 최종 Serving 구조

```text
Client
  -> Audience API
      -> Local Cache
          -> Redis
              -> Cassandra: audiences_by_user
```

- 각 Layer 의 역할은 명확하게 나눴다.
  - Local Cache 는 Redis 에 전달되는 순간적인 반복 요청을 줄인다.
  - Redis 는 Cassandra 에 대한 반복 조회를 줄인다.
  - Cassandra 는 User 중심 Feed 를 한 Partition 에서 조회한다.

- 이 구조를 만들면서 가장 크게 바뀐 생각은 아래와 같다.

> Cache 를 얼마나 빠르게 만들 것인가보다 Cache 뒤의 조회를 얼마나 적게 만들 것인가가 더 중요하다.

- Redis 하나를 Cassandra 앞에 추가하는 것으로 끝내면 Redis 가 새로운 병목이 될 수 있다.
- 반면 조회 패턴 자체를 변경하면 여러 번의 Cassandra Read 를 한 번의 Partition Read 로 바꿀 수 있다.
- 그 앞에 Local Cache 와 Redis 를 배치하면 각 Layer 가 다음 Layer 로 전달되는 요청량을 줄이는 구조를 만들 수 있다.

# 정리

- Audience 생성은 대량 Write 중심이므로 Cassandra 의 Write Path 와 잘 맞았다.
- Online Serving 은 Partition Key 기반 Query 만 허용하도록 설계했다.
- `Audience -> User`, `User -> Audience` 두 View 를 유지해 관리와 Serving 의 조회 방향을 각각 만족시켰다.
- 여러 Audience 조회는 User 중심 Feed 와 Application 교집합 계산으로 하나의 Partition Read 로 줄였다.
- Redis 는 Cassandra 를 보호하고, 작은 Local Cache 는 Redis 를 보호한다.
- Cassandra Read 성능은 저장소 자체가 무조건 빠르기 때문이 아니라 Query Driven Modeling 으로 잘 읽을 수 있는 형태를 만든 결과다.

# 참고자료

- [Redis - Diagnosing latency issues](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/)
- [Redis - Latency monitoring](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency-monitor/)
- [Apache Cassandra - Data modeling introduction](https://cassandra.apache.org/doc/stable/cassandra/developing/data-modeling/intro.html)
- [Apache Cassandra - Storage engine](https://cassandra.apache.org/doc/stable/cassandra/architecture/storage-engine.html)
- [Apache Cassandra - Data definition](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/ddl.html)
- [Apache Cassandra - Bloom filters](https://cassandra.apache.org/doc/3.11/cassandra/operating/bloom_filters.html)
