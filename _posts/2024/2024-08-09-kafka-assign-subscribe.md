---
layout: post
title:  "Kafka Subscribe/Assign Semantics"
date:   2024-08-09 09:00:00 +0900
categories:
- kafka
tags:
- kafka
---
- Kafka Consumer 를 이용할 때 2가지 방식이 있다.
- `Subscribe` vs `Assign`
- 두가지 방식에 대해서 어떤 차이점이 있는지 알아보자.

# `Subscribe`
- 구독 방식은 `group.id` 를 이용함.
- Kafka 의 Cordinator 로부터 자동으로 처리해야할 파티션이나 offset 등을 분배 받음.
- 새로운 GroupId 가 할당될 경우, 리밸런싱 등이 일어나게 됨.
    - OnPartitionsAssigned, OnPartitionsRevoked 등의 이벤트를 수신할 수 있음.
- 데이터 처리시에 commit() 이 필요하다.

> public void subscribe(Collection<String> topics) {}

## 예제코드

```java
Properties properties = new Properties();
properties.setProperty(ConsumerConfig.CLIENT_ID_CONFIG, "test");
properties.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
properties.setProperty(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
properties.setProperty(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
properties.setProperty(ConsumerConfig.GROUP_ID_CONFIG, "group_id"); //필수

try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(properties);) {
	consumer.subscribe(List.of(topic));

	while (true) {
		ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

		for (ConsumerRecord<String, String> record : records) {
			log.info("Partition: {}, Offset : {}, Key: {}, value : {}", record.partition(), record.offset(), record.key(), record.value());
		}

		consumer.commitSync();
	}
}
```

# `Assign`
- Topic, Partition, Offset 을 직접 할당하여 데이터를 소비합니다.
    - offset 의 경우, 맨처음, 맨마지막 등을 설정 할 수 있게 됩니다.

> public void assign(Collection<TopicPartition> partitions) {}

```java

try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(properties);) {
	TopicPartition partitionToReadFrom = new TopicPartition(topic, 0);
	consumer.assign(List.of(partitionToReadFrom)); 	// assign


	consumer.position(partitionToReadFrom); 	// seek

	int numberOfMessagesToRead = 1000;
	boolean keepOnReading = true;
	int numberOfMessagesReadSoFar = 0;


	// poll for new data
	while (keepOnReading) {
		ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
		for (ConsumerRecord<String, String> record : records) {
			numberOfMessagesReadSoFar += 1;

			log.info("Key: {}, value : {}", record.key(), record.value());
			log.info("Partition: {}, Offset : {}", record.partition(), record.offset());
			
			if (numberOfMessagesReadSoFar >= numberOfMessagesToRead) {
				keepOnReading = false; // to exit the while loop
				break; // to exit the for loop
			}
		}
	}
}
```
