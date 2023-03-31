---
layout: post
title:  "[Kafka] Kafka Producer Ack"
date: 2022-10-13 09:00:00 +0900
categories:
- kafka
tags:
- kafka
---

# Produce Ack 설정에 대하여
- Broker 에 Message 가 잘 전달되었는지 확인하는 작업을 뜻함.

## acks = 0
- 메시지를 보낸 후에 `정상적으로 처리되었는지 확인하지 않음`
- 처리 속도는 다른 옵션들이 비해 빠르지만
- `유실 가능성`이 있다.

## acks = 1
- 메시지를 보낸 후에 `leader` 에게 메시지가 잘 전달되었는지 확인함.
  - `leader`는 로그 파일에 추가하고 `다른 follower`에게 복제를 기다리지 않고 응답함
- leader 가 메시지를 받은 것을 보장하지만, leader 가 메시지를 받고 follower 들에게 복제가 되기 전에 해당 브로커에 장애가 발생한다면 `유실 가능성`이 있다.
- 옵션들 중에서는 처리시간/처리량/안정성 면에서 가장 중간 설정 값 이다.

## acks = all(-1)
- `leader`와 `ISR Follower`들이 메시지를 모두 전달 받았는지 확인함.
  - min.insync.replicas 수만큼 응답이 와야함. leader + follower
- 복제여부를 확인 후에 응답함.
- 처리 시간 등은 오래걸리고 성능이 제일 느리지만 유실 가능성이 적고, 월등한 안정성을 제공함.
- kafka 3.0 이상에서는 acks=all 이 default 로 설정된다.

## 요약
- 처리속도 : `acks=0`  > `acks=1` > `acks=all(-1)`
- 안정성 : `acks=all(-1)` > `acks=1` > `acks=0`

# `min.insync.replicas` 에 대해서
- Producer 가 `acks=all` 로 설정하였을 때, produce 성공하기 위한 최소 복제본 수
- 최소 복제수만큼 처리가 되지 않은 데이터는 consume 도 되지 않음
  - 아예 이벤트 자체가 발생하지 않음.
- 브로커 옵션(Topic 에서 덮어쓰기가 가능)
- config/server.properties 파일에서 변경할 수 있음.
- `default=1`

## 상황별 예시
### `Broker=2`, `Replication Factor=2`, `min.insync.replicas=1`
- 해당 Topic Partition 에는 leader 1개와 follower 1개가 있음.
- 복제를 기다릴 때 min.insync.replicas 값이 `1` 이므로 follower 에게 복제가 이뤄지지 않아도 됨.
- Broker 한대가 다운되더라도 프로듀싱에는 실패하지 않음.

### `Broker=2`, `Replication Factor=2`, `min.insync.replicas=2`
- 해당 Topic Partition 에는 leader 1개와 follower 1개가 있음.
- 복제를 기다릴 때 min.insync.replicas 값이 `2` 이므로 follower 에게까지 복제처리 응답을 받아야함.
- Broker 한대가 내려가서 follower 에게 응답을 못받을 경우 `NotEnoughReplicasException` Exception 발생
- 이런 경우 최소 복제 수를 2로 설정하려면 `min.insync.replicas` 값을 `1` 로 설정하는 것이 좋다.

### `Broker=3`, `Replication Factor=3`, `min.insync.replicas=1`
- 해당 Topic Partition 에는 leader 1개와 follower 2개가 있음.
- 모든 follower 들이 실패하더라도 leader 만 성공한다면 produce 는 성공으로 처리됨.
- Broker 2대가 다운되더라도 정상처리가 됨.

### `Broker=3`, `Replication Factor=3`, `min.insync.replicas=2`
- 해당 Topic Partition 에는 leader 1개와 follower 2개가 있음.
- follower 중 한대만 성공으로 처리된다면 produce 는 성공으로 ack 를 받게됨
- Broker 한대가 다운되더라도 안정적으로 처리 될 수 있음.

### `Broker=4`, `Replication Factor=3`, `min.insync.replicas=2`
- 해당 Topic Partition 에는 leader 1개와 follower 2개가 있음.
- follower 중 한대만 성공으로 처리된다면 produce 는 성공으로 ack 를 받게됨
- Broker 두대가 다운되더라도 안정적으로 처리될 수 있음.

## 요약
- Replication Factor 는 저장된 데이터의 총 복사본 수를 정하는 것
- min.insync.replicas 는 데이터의 최소 복사본 수

# 재시도 처리

## Produce Config
### retries
- 메시지 발송이 실패할 경우 재시도 하는 수, default Integer.MAX
- 위 수만큼 재시도하는게 아닌 `delivery.timeout.ms` 값 안에서 만큼만 재시도가 이뤄진다.
- 해당 설정값을 수정하는게 아닌 `delivery.timeout.ms`을 조절한다.

---
## Reference
- https://www.conduktor.io/kafka/kafka-topic-configuration-min-insync-replicas
- https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-producer-acks/
- https://huisam.tistory.com/entry/kafka-producer