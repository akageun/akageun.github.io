---
layout: post
title:  "Java Kafka Client 사용하기(Producer, Consumer)"
date:   2020-05-02 09:00:00 +0900
categories:
 - java
tags: 
 - kafka
 - java
---

- java에서 Kafka client 를 사용하여 producer와 consumer 를 간단하게 구현해보자.

## pom.xml
- kafka 버전과 라이브러리 버전을 맞추는 것이 좋다.

```xml
<!-- https://mvnrepository.com/artifact/org.apache.kafka/kafka-clients -->
<dependency>
    <groupId>org.apache.kafka</groupId>
    <artifactId>kafka-clients</artifactId>
    <version>2.5.0</version>
</dependency>
```

## producer basic usage
#### properties
```java
Properties props = new Properties();
props.put(ProducerConfig.CLIENT_ID_CONFIG, "client_id");
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092,localhost:9093");
props.put(ProducerConfig.ACKS_CONFIG, "all");
```

#### Asynchronous writes
```java
final ProducerRecord<String, String> record = new ProducerRecord<>(topic, value);
producer.send(record, (metadata, e) -> {
	if (e != null) {
		System.out.println("Record sent to partition " + metadata.partition() + " with offset " + metadata.offset() + " - toString() : " + metadata.toString());
	}
});
```

#### Synchronous writes
```java
Future<RecordMetadata> future = producer.send(record);
try {
	RecordMetadata metadata = future.get();
	System.out.println("Record sent to partition " + metadata.partition() + " with offset " + metadata.offset() + " - toString() : " + metadata.toString());
} catch (InterruptedException e) {
	e.printStackTrace();
} catch (ExecutionException e) {
	e.printStackTrace();
}
```

#### full source
```java
Properties props = new Properties();
props.put(ProducerConfig.CLIENT_ID_CONFIG, "client_id");
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092,localhost:9093");
props.put(ProducerConfig.ACKS_CONFIG, "all");

String topic = "topic_name";
String value = "produce test value";

try (KafkaProducer<String, String> producer = new KafkaProducer<>(props);) {
	//Asynchronous writes
	final ProducerRecord<String, String> record = new ProducerRecord<>(topic, value);
	producer.send(record, (metadata, e) -> {
		if (e != null) {
			System.out.println("Record sent to partition " + metadata.partition() + " with offset " + metadata.offset() + " - toString() : " + metadata.toString());
		}
	});

	//Synchronous writes
	Future<RecordMetadata> future = producer.send(record);
	try {
		RecordMetadata metadata = future.get();
		System.out.println("Record sent to partition " + metadata.partition() + " with offset " + metadata.offset() + " - toString() : " + metadata.toString());
	} catch (InterruptedException e) {
		e.printStackTrace();
	} catch (ExecutionException e) {
		e.printStackTrace();
	}
}
```

## consumer basic usage
#### properties
```java
Properties props = new Properties();
props.put(ConsumerConfig.CLIENT_ID_CONFIG, "client_id_1");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "group_id");
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092,localhost:9093");

```

#### consume
- `subscribe` 형태
- partition 별 consume 등은 따로 다룰 예정

```java
try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);) {
	consumer.subscribe(Collections.singletonList("topic_name"));

	while (true) {  // 계속 loop를 돌면서 producer의 message를 띄운다.
		ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

		for (ConsumerRecord<String, String> record : records) {
			System.out.println("topic : " + record.topic() + " partition : " + record.partition() + "offset : " + record.offset() + " key : " + record.key() + " value : " + record.value());
		}

		consumer.commitSync();
	}
}
```

#### full source
```java 
Properties props = new Properties();
props.put(ConsumerConfig.CLIENT_ID_CONFIG, "client_id_1");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "group_id");
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092,localhost:9093");

try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);) {
	consumer.subscribe(Collections.singletonList("topic_name"));

	while (true) {  // 계속 loop를 돌면서 producer의 message를 띄운다.
		ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

		for (ConsumerRecord<String, String> record : records) {
			System.out.println("topic : " + record.topic() + " partition : " + record.partition() + "offset : " + record.offset() + " key : " + record.key() + " value : " + record.value());
		}

		consumer.commitSync();
	}
}
```

---
## 참고링크
- https://docs.confluent.io/current/clients/java.html
