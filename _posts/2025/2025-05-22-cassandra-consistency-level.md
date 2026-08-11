---
layout: post
title:  "[Cassandra] Consistency Level 이해하기"
date:   2025-05-22 19:54:00 +0900
categories:
- database
tags:
- cassandra
- consistency-level
- distributed-system
---

- Cassandra를 사용하다 보면 같은 Query인데도 `ONE`, `QUORUM`, `LOCAL_QUORUM` 같은 Consistency Level을 지정해야 한다.
- Consistency Level은 데이터의 복제 개수를 정하는 설정이 아니다.
- Client의 Read 또는 Write 요청을 성공으로 반환하기 위해 몇 개의 Replica 응답을 기다릴지 정하는 값이다.
- 이 글에서는 Consistency Level의 동작과 비동기 후처리, Multi Datacenter 환경에서 주의할 점을 정리한다.

# Consistency Level 이란?

- Cassandra는 하나의 Partition을 Replication Factor에 따라 여러 Replica에 저장한다.
- 예를 들어 `RF=3`이면 같은 Partition의 Replica가 세 개 존재한다.
- Client가 요청을 보내면 요청을 받은 Coordinator Node가 대상 Replica를 찾고, Consistency Level에 필요한 응답 수를 계산한다.

```text
Client
  -> Coordinator
      -> Replica A
      -> Replica B
      -> Replica C
```

- Write는 Consistency Level과 관계없이 모든 대상 Replica로 전달된다.
- Consistency Level은 Coordinator가 Client에게 성공을 반환하기 전에 몇 개의 ACK를 기다릴지 결정한다.
- Read는 일반적으로 Consistency Level을 만족하는 데 필요한 수의 Replica에 요청한다.

> Consistency Level이 낮다고 Replica 하나에만 데이터를 저장하는 것은 아니다.

# 주요 Consistency Level

| Level | 필요한 응답 | 특징 |
| --- | --- | --- |
| `ANY` | Replica ACK 또는 Coordinator의 Hint 하나 | Write 전용, 가장 높은 Write 가용성 |
| `ONE` | Replica 하나 | 낮은 Latency, 높은 가용성 |
| `TWO` | Replica 두 개 | 두 Replica 응답 필요 |
| `THREE` | Replica 세 개 | 세 Replica 응답 필요 |
| `QUORUM` | 전체 Replica의 과반수 | 모든 Datacenter의 RF를 기준으로 계산 |
| `LOCAL_ONE` | Local Datacenter의 Replica 하나 | 요청을 Local DC 안에서 처리 |
| `LOCAL_QUORUM` | Local Datacenter Replica의 과반수 | Local DC 안에서 Quorum 보장 |
| `EACH_QUORUM` | 각 Datacenter별 과반수 | 모든 DC의 Quorum 필요, Write에 사용 |
| `ALL` | 모든 Replica | 가장 강한 응답 조건, 낮은 가용성 |

- `QUORUM`의 계산은 아래와 같다.

```text
QUORUM = floor(RF / 2) + 1
```

- `RF=3`이면 Quorum은 2개다.
- `RF=5`이면 Quorum은 3개다.

# Consistency 와 Availability의 Trade-off

- 낮은 Consistency Level은 적은 Replica 응답만 기다리므로 일반적으로 Latency와 Availability에 유리하다.
- 높은 Consistency Level은 더 많은 Replica 응답을 기다리므로 최신 Write를 읽을 가능성과 보장은 강해지지만 장애를 허용할 수 있는 Replica 수가 줄어든다.

## RF=3 예제

| Consistency Level | 필요한 Replica | 허용 가능한 Replica 장애 수 |
| --- | ---: | ---: |
| `ONE` | 1 | 2 |
| `QUORUM` | 2 | 1 |
| `ALL` | 3 | 0 |

- 여기서 장애 허용 수는 요청 성공 조건만 단순화한 값이다.
- 실제 Availability는 NetworkTopologyStrategy, Datacenter, Rack, Coordinator 위치와 장애 범위의 영향을 받는다.

# Read-after-write 를 보장하는 조건

- Cassandra의 Tunable Consistency는 Read 응답 수 `R`, Write ACK 수 `W`, Replication Factor `RF`의 관계로 이해할 수 있다.

```text
W + R > RF
```

- 이 조건을 만족하면 Write에 응답한 Replica 집합과 Read에 참여한 Replica 집합이 최소 하나 이상 겹친다.
- 예를 들어 `RF=3`에서 Write와 Read를 모두 `QUORUM`으로 설정하면 아래와 같다.

```text
W = 2
R = 2
RF = 3

2 + 2 > 3
```

- 따라서 성공한 Write는 이후 Quorum Read에서 확인할 수 있다.

## 조합별 비교

| Write CL | Read CL | RF=3에서 교집합 보장 | Read-after-write 보장 |
| --- | --- | --- | --- |
| `ONE` | `ONE` | `1 + 1 > 3` 불만족 | 보장하지 않음 |
| `QUORUM` | `ONE` | `2 + 1 > 3` 불만족 | 보장하지 않음 |
| `ONE` | `QUORUM` | `1 + 2 > 3` 불만족 | 보장하지 않음 |
| `QUORUM` | `QUORUM` | `2 + 2 > 3` 만족 | 보장 |
| `ALL` | `ONE` | `3 + 1 > 3` 만족 | 보장 |

- `Write QUORUM + Read ONE`은 Write ACK를 더 많이 받기 때문에 `ONE + ONE`보다 최신 데이터를 읽을 가능성은 높아질 수 있다.
- 하지만 Read가 Write에 응답하지 않은 Replica 하나를 선택할 수 있으므로 강한 Read-after-write를 보장하지는 않는다.

# ONE 으로 쓰고 바로 읽을 때 발생하는 문제

- 성능과 가용성을 위해 Read와 Write를 모두 `ONE`으로 사용하는 경우가 있다.
- 이 선택은 최신 데이터보다 짧은 Latency와 높은 Availability가 중요한 Workload에는 적합할 수 있다.
- 하지만 Write 직후 다른 Process가 데이터를 다시 읽어야 하는 구조에서는 주의해야 한다.

```text
API
  1. Cassandra Write CL=ONE
  2. Kafka Event Produce

Consumer
  3. Event Consume
  4. Cassandra Read CL=ONE
```

- API가 Write 성공 응답을 받았다는 것은 하나 이상의 Replica가 ACK했다는 의미다.
- Consumer의 Read가 아직 최신 Write를 받지 못한 다른 Replica로 전달되면 이전 값 또는 없는 값을 읽을 수 있다.
- MySQL Primary에 쓴 직후 Replication Lag이 있는 Replica에서 조회할 때 발생하는 문제와 현상은 비슷하지만, Cassandra는 Multi-primary Replica Model이라는 차이가 있다.

# 해결 방법 1. Consistency Level 조정하기

- 같은 Datacenter 안에서 Read-after-write가 반드시 필요하다면 Read와 Write를 모두 `LOCAL_QUORUM`으로 설정하는 방식을 먼저 검토할 수 있다.

```text
Write: LOCAL_QUORUM
Read : LOCAL_QUORUM
```

- Local RF가 3이라면 각각 두 Replica 응답이 필요하고, 두 Replica 집합은 최소 하나가 겹친다.
- Single Datacenter라면 `QUORUM + QUORUM`도 같은 원리로 동작한다.

- 장점
  - 성공한 Write를 후속 Quorum Read에서 확인할 수 있다.
  - Application Logic이 단순해진다.
- 단점
  - 더 많은 Replica 응답을 기다려야 한다.
  - Latency가 증가할 수 있다.
  - 장애 시 성공 가능한 요청 범위가 줄어든다.

- 모든 Query의 Consistency Level을 일괄적으로 높이기보다 Read-after-write가 필요한 Use Case에만 별도의 실행 Profile을 적용하는 것이 좋다.

# 해결 방법 2. Consumer 에 Retry 넣기

- Eventual Consistency를 허용할 수 있다면 Consumer가 데이터 없음 또는 예상 Version 불일치를 만났을 때 Retry할 수 있다.

```text
1차 조회 실패
  -> 짧은 Backoff
      -> 2차 조회
          -> Backoff 증가
              -> 제한 횟수 초과 시 DLQ
```

- 단순히 1~2초를 고정해서 기다리는 것보다 아래 항목을 함께 설계해야 한다.
  - Exponential Backoff와 Jitter
  - 최대 Retry 횟수와 전체 제한 시간
  - Consumer의 Idempotency
  - Retry 중복 처리 방지
  - 실패 Event를 보관할 DLQ
  - 알림과 수동 재처리 절차

- Retry는 Consistency를 보장하는 방법이 아니다.
- 일시적으로 늦게 보이는 데이터를 기다리는 운영 대응이며, 제한 시간 안에 최신 데이터가 보인다는 보장은 없다.

# 해결 방법 3. Event 에 필요한 정보를 포함하기

- Consumer가 후처리에 필요한 데이터를 Produce 시점의 Event에 함께 담으면 Cassandra를 다시 조회하지 않아도 된다.

```json
{
  "eventId": "event-123",
  "eventType": "USER_UPDATED",
  "userId": "user-1",
  "version": 42,
  "occurredAt": "2025-05-22T10:54:00Z",
  "payload": {
    "status": "ACTIVE"
  }
}
```

- 장점
  - Consumer의 Cassandra Read를 제거할 수 있다.
  - Write 직후 Stale Read 문제를 피할 수 있다.
  - Consumer가 Event 발생 시점의 Snapshot을 기준으로 처리할 수 있다.
- 고려할 점
  - Event Schema Version 관리
  - 개인정보와 민감 데이터 최소화
  - Event 크기
  - 중복 Event 처리
  - 같은 Entity Event의 순서와 Version 비교

- Consumer가 최신 전체 상태가 아니라 Event 발생 당시의 변경 내용을 처리하면 되는 구조라면 이 방법이 가장 단순할 수 있다.

# 해결 방법 4. Transactional Outbox 검토하기

- Cassandra Write와 Kafka Produce는 서로 다른 시스템의 작업이다.
- 아래처럼 순차 호출하면 중간 실패에 따라 상태가 달라질 수 있다.

```text
Cassandra Write 성공 -> Kafka Produce 실패
Cassandra Write 실패 -> Kafka Produce 성공
```

- Consistency Level은 Cassandra Replica 사이의 응답 조건만 다룬다.
- Cassandra Write와 Kafka Produce를 하나의 원자적 Transaction으로 만들어주지는 않는다.
- 데이터와 발행할 Event를 함께 기록한 뒤 별도의 Publisher가 Event를 전달하는 Outbox 계열 Pattern을 요구사항에 맞게 검토할 수 있다.
- Cassandra에서 적용할 때는 Partition 설계, CDC 사용 여부, 중복 발행과 Idempotency를 함께 고려해야 한다.

# Write Timeout 재시도 시 주의할 점

- Cassandra에서 Write Timeout을 받았다고 Write가 모든 Replica에서 실패한 것은 아니다.
- 일부 Replica에는 반영됐지만 Consistency Level을 만족할 만큼 ACK가 돌아오지 않았을 수 있다.
- 따라서 Client는 결과를 `반드시 실패`로 단정할 수 없다.

- Retry할 Write는 Idempotent하게 설계해야 한다.
  - 같은 Primary Key와 값으로 다시 쓰기
  - Event ID로 중복 처리 방지
  - Counter와 List Append처럼 Retry 결과가 달라질 수 있는 연산 주의
  - Driver의 Idempotence 설정과 Retry Policy 확인

# Hinted Handoff 와 Repair

- Coordinator가 Replica에 Mutation을 전달하지 못하면 Hint를 저장했다가 Replica가 복구된 뒤 재전달할 수 있다.
- Hinted Handoff는 Replica 불일치가 지속되는 시간을 줄여주지만 Best-effort 기능이다.
- Hint만으로 영구적인 일관성을 보장할 수 없으므로 정기적인 Repair 운영이 필요하다.

- Read Repair와 Anti-entropy Repair도 Replica 간 불일치를 줄이는 역할을 한다.
- 다만 이런 기능이 있다는 이유로 Application의 Read-after-write 요구사항을 `ONE + ONE`으로 보장할 수 있는 것은 아니다.

# Multi Datacenter 에서 LOCAL 계열 사용하기

- 여러 Datacenter에 Replica가 있을 때 `ONE`은 어느 Datacenter의 Replica든 하나가 응답하면 성공할 수 있다.
- `LOCAL_ONE`은 Coordinator가 위치한 Local Datacenter의 Replica 하나가 응답해야 한다.
- `LOCAL_QUORUM`은 Local Datacenter의 RF만을 기준으로 과반수 응답을 기다린다.

```text
DC1 RF=3
  - Replica A
  - Replica B
  - Replica C

DC2 RF=3
  - Replica D
  - Replica E
  - Replica F
```

- 위 구성에서 DC1의 `LOCAL_QUORUM`은 DC1 Replica 중 두 개의 응답이 필요하다.
- Global `QUORUM`은 전체 RF 6을 기준으로 네 개의 응답이 필요하므로 Datacenter 간 Network 상태의 영향을 받을 수 있다.

- Application이 각 Datacenter에 배치되어 Local Traffic을 처리한다면 보통 LOCAL 계열을 우선 검토한다.
  - 낮은 Cross-DC Latency
  - Remote DC 장애로부터 Local 요청 격리
  - Datacenter별 장애 범위가 명확함

# 신규 Datacenter 추가와 이관 시 주의할 점

- 새 Datacenter를 추가할 때 Consistency Level만 변경한다고 데이터 이관이 완료되는 것은 아니다.
- 아래 작업을 함께 계획해야 한다.
  - NetworkTopologyStrategy의 DC별 RF 설정
  - Node Bootstrap과 Streaming 완료 확인
  - 기존 데이터 Repair 또는 Rebuild
  - Driver의 Local Datacenter 설정
  - Load Balancing Policy 확인
  - LOCAL Consistency Level 적용
  - Read 및 Write 검증 후 Traffic 전환

- 검증 Traffic이 새 Datacenter의 Replica만 사용해야 한다면 `LOCAL_ONE` 또는 `LOCAL_QUORUM`을 사용해 Remote Replica 응답으로 성공이 가려지지 않게 할 수 있다.
- 단, `LOCAL_ONE`은 Local Replica 하나만 확인하므로 Local Datacenter 전체 Replica의 데이터 준비 상태를 검증하는 방법으로는 부족하다.
- 이관 완료 여부는 Streaming, Repair 상태와 Replica별 데이터 검증을 별도로 확인해야 한다.

# cqlsh 에서 확인하기

- 현재 Consistency Level을 확인한다.

```cql
CONSISTENCY;
```

- 이후 Query에 사용할 Consistency Level을 지정한다.

```cql
CONSISTENCY LOCAL_QUORUM;
```

- cqlsh에서 설정한 값은 해당 Session의 이후 작업에 적용된다.
- Application에서는 사용하는 Driver의 Statement 또는 Execution Profile별로 Consistency Level을 설정해야 한다.

# Consistency Level 선택 기준

- 모든 서비스에 동일한 정답은 없다.
- 아래 질문을 기준으로 선택하는 것이 좋다.

## 데이터 요구사항

- Write 직후 최신 데이터를 반드시 읽어야 하는가?
- Stale Read를 얼마나 오래 허용할 수 있는가?
- 데이터가 잠시 보이지 않는 것과 요청 실패 중 무엇이 더 큰 문제인가?

## 장애 요구사항

- Replica 또는 Datacenter 장애 중에도 요청을 받아야 하는가?
- 허용 가능한 Latency는 얼마인가?
- Cross-DC Network 장애가 Local 요청에 영향을 줘도 되는가?

## Application 구조

- Write 직후 다른 Process가 다시 조회하는가?
- Event에 필요한 정보를 포함해 조회를 제거할 수 있는가?
- Retry와 Idempotency가 준비되어 있는가?

# 정리

- Consistency Level은 데이터 복제 개수가 아니라 요청 성공을 위해 기다릴 Replica 응답 수를 결정한다.
- Write는 Consistency Level과 관계없이 모든 대상 Replica로 전달된다.
- `ONE + ONE`은 Latency와 Availability에는 유리하지만 Read-after-write를 보장하지 않는다.
- `RF=3`에서 `Write QUORUM + Read ONE`도 `W + R > RF`를 만족하지 않으므로 강한 일관성을 보장하지 않는다.
- 같은 Datacenter에서 최신 Write를 읽어야 한다면 `LOCAL_QUORUM + LOCAL_QUORUM`을 검토할 수 있다.
- 비동기 Consumer는 Retry만 의존하기보다 Event에 필요한 Snapshot을 포함해 재조회를 제거하는 방법을 우선 고려한다.
- Multi Datacenter에서는 Driver의 Local DC 설정과 LOCAL 계열 Consistency Level을 함께 설계해야 한다.
- Consistency Level은 Cassandra와 Kafka 사이의 원자성을 해결하지 않으므로 Event 발행 실패와 중복 처리도 별도로 설계해야 한다.

# 참고자료

- [Apache Cassandra - Dynamo](https://cassandra.apache.org/doc/latest/cassandra/architecture/dynamo.html)
- [Apache Cassandra - Hints](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/hints.html)
- [Apache Cassandra - Read repair](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/read_repair.html)
- [Apache Cassandra - cqlsh](https://cassandra.apache.org/doc/latest/cassandra/managing/tools/cqlsh.html)
- [Apache Cassandra - Repair](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/repair.html)
