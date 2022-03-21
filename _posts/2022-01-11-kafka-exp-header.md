---
layout: post
title:  "[Kafka 경험기] Header 사용하기"
date:   2022-01-11 09:00:00 +0900
categories:
- kafka
tags:
- kafka
- spring kafka
- experience
---
## Header 사용하기
- https://kafka.apache.org/documentation/#record
- https://issues.apache.org/jira/browse/Kafka-Header%20%5Bb%5D
- payload 에 담기에는 애매한 데이터들을 추가할 때 사용하기 좋습니다.
  - http header 와 같이!
  - 예시) 2개의 Producer 에서 1개 Consumer 로 데이터를 보낼 때 구분하기 위한 용도??
- 0.11 버전 이후로 지원합니다!

### 기본적으로 추가되어 있는 header
- 2.2.0 기준
```
consumer.Consumer - key : kafka_offset, value : 18
consumer.Consumer - key : kafka_consumer, value : org.apache.kafka.clients.consumer.KafkaConsumer@4a8f7caf
consumer.Consumer - key : kafka_timestampType, value : CREATE_TIME
consumer.Consumer - key : kafka_receivedMessageKey, value : null
consumer.Consumer - key : kafka_receivedPartitionId, value : 2
consumer.Consumer - key : kafka_receivedTopic, value : local-test-topic
consumer.Consumer - key : kafka_receivedTimestamp, value : 1644899735962
``` 

### Producer
```
ProducerRecord<String, Object> record = new ProducerRecord<>("local-test-topic", "Test String");
record.headers().add(new RecordHeader("test", "test".getBytes(StandardCharsets.UTF_8)));
kafkaTemplate.send(record);
```

### Consumer 에서 header 가지고 오기
> @org.springframework.messaging.handler.annotation.Headers org.springframework.messaging.MessageHeaders messageHeaders

```java
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.handler.annotation.Headers;
import org.springframework.messaging.handler.annotation.Payload;

@KafkaListener(topics = "local-test-topic")
public void test(
	@Headers MessageHeaders messageHeaders, //헤더들을 한번에 가져올 수 있다.
	@Payload String data
) {
	
}
```

```java
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;

@KafkaListener(topics = "local-test-topic")
public void test(
	@Header(value = KafkaHeaders.RECEIVED_PARTITION_ID, required = false) int partition,
	@Header(value = "test", required = false) String testHeader,
	@Payload String data
) {
	
}
```