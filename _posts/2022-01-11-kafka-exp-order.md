---
layout: post
title:  "[Kafka 경험기] 데이터 순서 보장하기"
date:   2022-01-11 09:00:00 +0900
categories:
- kafka
tags:
- kafka
- spring kafka
- experience
---
## 데이터 순서 보장하기
- 카프카 Topic 은 순서를 보장하지 않지만, Partition 내에서는 순서가 보장된다.
  - Topic 의 Partition 을 1개, 컨슈머를 1개로 설정하면 순서는 보장 될 것이다.
  - 이렇게 쓸거면... Kafka 를 쓸 이유가... 없을 것 같다.
- 그럼 어떻게 설정하면 순서보장할 수 있을까?

### 순서를 보장하여 프로듀싱하기
- 순서보장이 필요한 `key` 를 지정합니다.
  - 아래는 유저 단위로 순서를 보장하여 처리 할 수 있도록 설정한 값 입니다.

```java
String key = "user-id";
kafkaTemplate.send("test-topic", key, data);
```

### 어떻게 동작할까?
- 지정한 key 값을 hashing(murmur2) 하여 partition 수로 나누어 처리할 파티션 숫자를 결정함.
  - 같은 key 값이면 같은 파티션으로 프로듀싱됨.
  - `org.apache.kafka.clients.producer.internals.DefaultPartitioner` 를 참고하시면 됩니다.

![image](https://user-images.githubusercontent.com/13219787/159281260-6c0683aa-f129-4166-bf04-62b2846b7d22.png)

### 다른 Partitioner 를 사용하는 방법은?
- `org.apache.kafka.clients.producer.Partitioner` 를 구현하여 producer config 에 설정해주면 됩니다.

> configs.put(ProducerConfig.PARTITIONER_CLASS_CONFIG, CustomKafkaPartitioner.class);


