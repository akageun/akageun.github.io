---
layout: post
title:  "[Kafka 경험기] Data 가 1MB 초과 했을 때"
date:   2022-01-11 09:00:00 +0900
categories:
- kafka
tags:
- kafka
- spring-kafka
- experience
---

## Data 가 1MB 초과 했을 때
- 프로듀싱할 데이터 사이즈가 1MB 를 초과할 경우 아래와 같은 에러가 발생.

> org.apache.kafka.common.errors.RecordTooLargeException: The message is 1048694 bytes when serialized which is larger than the maximum request size you have configured with the max.request.size configuration.

### 에러 발생 확인...
- 1MB 를 직접 produce 하여 에러 확인하기

```java
char[] chars = new char[1 * 1024 * 1024]; 1MB
Arrays.fill(chars, 'a');
String data = new String(chars);
kafkaTemplate.send("test-topic", data);
```

### 관련 설정값 : max.request.size
- Kafka 브로커로 요청 당 보낼 수 있는 최대 크기, 기본값 `1MB`
- https://docs.confluent.io/platform/current/installation/configuration/producer-configs.html#producerconfigs_max.request.size

### 설정값 변경
- 되도록 1MB 아래로 데이터 전송하는 것이 좋고, 사이즈를 올려서 전송을 해야할 경우 아래 옵션들도 함께 고려하여 올려야함.
  - 연관된 옵션 일부만 추가했습니다. 더 연관된 것들이 있을 수 있습니다!
- Broker
  - [message.max.bytes](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#brokerconfigs_message.max.bytes) : 단일 요청 최대 크기, 기본값 `1MB` (데이터 사이즈가 커지면 처리 시간도 영향을 주기 때문)
    - 해당값은 토픽단위로도  설정 변경 가능 : [max.message.bytes](https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html#topicconfigs_max.message.bytes)
- Producer
  - [request.timeout.ms](https://docs.confluent.io/platform/current/installation/configuration/producer-configs.html#producerconfigs_request.timeout.ms) : 요청 후 응답을 대기하는 최대 시간(데이터 사이즈가 커지면 처리 시간도 영향을 주기 때문)
- Consumer
  - [max.partition.fetch.bytes](https://docs.confluent.io/platform/current/installation/configuration/consumer-configs.html#consumerconfigs_max.partition.fetch.bytes) : 각 파티션 별로 최대로 반환할 수 있는 바이트 수, 기본값 `1MB`
  - [request.timeout.ms](https://docs.confluent.io/platform/current/installation/configuration/consumer-configs.html#consumerconfigs_request.timeout.ms) : 요청 후 응답을 대기하는 최대시간, 기본값 `30초`(데이터 사이즈가 커지면 처리 시간도 영향을 주기 때문)
  - [max.poll.interval.ms](https://docs.confluent.io/platform/current/installation/configuration/consumer-configs.html#consumerconfigs_max.poll.interval.ms) : 컨슈머 poll() 대기시간, 해당시간동안 poll() 이 일어나지 않을 경우 리밸런싱이 일어남.
    