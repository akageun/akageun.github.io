---
layout: post
title:  "[Kafka 경험기] 데이터 저장 기간"
date:   2022-01-11 09:00:00 +0900
categories:
- kafka
tags:
- kafka
- spring-kafka
- experience
---
# 데이터 저장 일시
- Kafka 는 데이터를 디스크에 저장하고 보관기간을 설정 합니다.
- 보관기간을 설정할 때 사용할 데이터 사이즈도 고려해야할 대상이지만 아래와 같은 경우도 고려하면 좋다.
  - 최대 복구 가능 일시
  - 최대 디버깅 가능 일시.... (3일로 설정했을 때 명절 등 연휴기간에 장애 발생... 3일 후 출근해서 디버깅 해야지!! 어? 데이터 없.... 어.... 어.... )

## 설정값 변경
- Broker
  - [log.retention.ms](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#brokerconfigs_log.retention.ms) : ms 단위로 데이터보관
- Topic
  - [retention.ms](https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html#topicconfigs_retention.ms) : ms 단위로 데이터 보관
  - topic 설정 변경하기

```
//토픽 생성시 옵션 주기
bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create--topic \
    --topic ${topicName}
    --config retention.ms=86400000 

//기존 생성된 토픽 옵션 변경
bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --alter \
    --topic ${topicName}
    --config retention.ms=86400000
```