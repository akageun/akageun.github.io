---
layout: post
title:  "[Spring-Kafka 경험기] Spring-Kafka JsonDeserializer 사용할 때 주의해야할 점"
date:   2022-03-15 09:00:00 +0900
categories:
- kafka
tags:
- kafka
- spring kafka
- experience
---
- spring-kafka 를 사용해서 consumer 를 구축할 때, 아래와 같이 원하는 객체(TestV1DTO)로 바로를 사용하기 위해 `JsonDeserializer` 를 선언할 경우 리팩토링할 때 주의해야할 점이 있습니다.

## 1. Config
#### 1-1. ConsumerFactory Config
- 아래와 같이 설정하여 @Bean 을 만들어 사용.

```java
Map<String, Object> consumerConfigs = new HashMap<>();
//.... 설정값
return new DefaultKafkaConsumerFactory<>(
	consumerConfigs,
	new StringDeserializer(),
	new JsonDeserializer<>(TestV1DTO.class, new ObjectMapper()) //요부분!!!!
);
```
#### 1-2. Consumer listener
- `@KafkaListener`
  - 아래와 같이 받아서 손쉽게 사용 가능!
```java
@Payload TestV1DTO data 
```

## 2. Class 리네임...
- 리팩토링을 위해 `TestV1DTO` 를 `TestV2DTO` 로 변경 했습니다.

## 3. 변경 후 테스트!
#### 3-1. 로컬에서 테스트
- 리팩토링한 부분에 대해서 테스트 하기 위해서 **Producer 와 Consumer 를 띄운 다음**, 데이터를 보내고 잘 받는걸 확인 했습니다!

#### 3-2. 개발환경 배포...
- 단순 리팩토링이라 딱히 순서에 상관이 없을거라 생각하고 아무거나(Producer) 먼저 배포 했습니다.
- 갑자기 Consumer 에서 에러가 발생!!!!!!!

```
Caused by: org.springframework.messaging.converter.MessageConversionException: failed to resolve class name. Class not found [com.test.kafka.TestV2DTO]; nested exception is java.lang.ClassNotFoundException: com.test.kafka.TestV2DTO
  at org.springframework.kafka.support.converter.DefaultJackson2JavaTypeMapper.getClassIdType(DefaultJackson2JavaTypeMapper.java:138)
  at org.springframework.kafka.support.converter.DefaultJackson2JavaTypeMapper.toJavaType(DefaultJackson2JavaTypeMapper.java:99)
  at org.springframework.kafka.support.serializer.JsonDeserializer.deserialize(JsonDeserializer.java:342)
  at org.apache.kafka.clients.consumer.internals.Fetcher.parseRecord(Fetcher.java:1030)
  at org.apache.kafka.clients.consumer.internals.Fetcher.access$3300(Fetcher.java:110)
  at org.apache.kafka.clients.consumer.internals.Fetcher$PartitionRecords.fetchRecords(Fetcher.java:1250)
  at org.apache.kafka.clients.consumer.internals.Fetcher$PartitionRecords.access$1400(Fetcher.java:1099)
  at org.apache.kafka.clients.consumer.internals.Fetcher.fetchRecords(Fetcher.java:545)
  at org.apache.kafka.clients.consumer.internals.Fetcher.fetchedRecords(Fetcher.java:506)
  at org.apache.kafka.clients.consumer.KafkaConsumer.pollForFetches(KafkaConsumer.java:1269)
  at org.apache.kafka.clients.consumer.KafkaConsumer.poll(KafkaConsumer.java:1200)
  at org.apache.kafka.clients.consumer.KafkaConsumer.poll(KafkaConsumer.java:1176)
  at org.springframework.kafka.listener.KafkaMessageListenerContainer$ListenerConsumer.pollAndInvoke(KafkaMessageListenerContainer.java:741)
  at org.springframework.kafka.listener.KafkaMessageListenerContainer$ListenerConsumer.run(KafkaMessageListenerContainer.java:698)
  at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
  at java.util.concurrent.FutureTask.run(FutureTask.java:266)
  at java.lang.Thread.run(Thread.java:748)
```

- Consumer 는 아직 배포하지 않았는데, `TestV2DTO` 를 못찾..? 뭔가 이상하다....
  - Consumer 를 먼저 띄우게 된다면... `TestV1DTO` 를 못 찾는다고 나옴.

- 혹시 Header 에 관련 Class 값이 들어가 있는지 확인해 보았지만 없었다.
  - 컨슈머에서 아래와 같이 messageHeaders 를 꺼내서 확인

```java 
@Headers MessageHeaders messageHeaders 

for (Entry<String, Object> entry : messageHeaders.entrySet()) {
	log.info("key : {}, value : {}", entry.getKey(), entry.getValue());
}
```

## 4. 분석
- 에러로그를 하나씩 따라가 보자.......


#### 4-1. JsonDeserializer 의 deserialize() 부터 확인해보자
- header 에서 값을 꺼내서 Class 를 찾는걸 볼 수 있다.
- spring-kafka 2.2.5
```java
if (this.typeMapper.getTypePrecedence().equals(TypePrecedence.TYPE_ID)) {
	JavaType javaType = this.typeMapper.toJavaType(headers);
	if (javaType != null) {
		deserReader = this.objectMapper.readerFor(javaType);
	}
}
```

- spring-kafka 2.8.3
```java
if (javaType == null && this.typeMapper.getTypePrecedence().equals(TypePrecedence.TYPE_ID)) {
	javaType = this.typeMapper.toJavaType(headers);
}
```

#### 4-2. org.springframework.kafka.support.converter.DefaultJackson2JavaTypeMapper
```java 
String typeIdHeader = retrieveHeaderAsString(headers, getClassIdFieldName()); // getClassIdFieldName() 는 `__TypeId__` 
```

- 해당 로직에 debug 로 보면...
  - 분명 Message Header 를 확인했을 때는 없던 값이 있다.
  - value 를 확인해보니 Class 가 들어있다. (value : `com.test.kafka.TestV2DTO`)
    <img width="743" alt="image" src="https://user-images.githubusercontent.com/13219787/158513475-1794a720-d01a-4fa5-be22-1b1d795bd2cd.png">

- `typeIdHeader`  값이 없으면 null, 있으면 Class 를 찾는다.
  - 여기서 리팩토링으로 해당 Class 는 없어졌으니... `ClassNotFoundException` 발생

#### 4-3. Header 에 있는 ` `__TypeId__` 값은 어디서 온걸까?
- JsonSerializer 의 `serialize()` 를 확인해보자.
- spring-kafka 2.2.5
```java
if (this.addTypeInfo && headers != null) {
	this.typeMapper.fromJavaType(this.objectMapper.constructType(data.getClass()), headers);
}
```

- spring-kafka 2.8.3
```java
if (this.addTypeInfo && headers != null) {
	this.typeMapper.fromJavaType(this.objectMapper.constructType(data.getClass()), headers);
}
```

- `this.typeMapper` 로 선언된 `DefaultJackson2JavaTypeMapper` 의 `fromJavaType()` 를 찾아보면 여기서 해당 Header 값을 세팅하는걸 볼 수 있다... (왜 Message Header 에서 안보였는지는 좀 더 아래에 작성 했습니다.)
```java
String classIdFieldName = getClassIdFieldName();
addHeader(headers, classIdFieldName, javaType.getRawClass()); //classIdFieldName 는 `__TypeId__` 
```

## 5. 해결방안
- a. 리팩토링으로 리네임하기 전 클래스를 남겨놓는다...
  - `TestV2DTO` 를 사용할 예정이므로... `TestV1DTO` 를 기존 패키지에 동일하게 남겨놓는다...
  - 배포하고 난 뒤 또 지워야한다. 귀찮다...
- b. JsonDeserializer 로 사용하던 부분을 `StringDeserializer` 로 변경
  - JsonDeserializer 를 잘 쓰고 있었으므로 변경 필요성을 못느껴서 좀 더 다른 방안을 찾아보기로함.
- c. `this.typeMapper.getTypePrecedence().equals(TypePrecedence.TYPE_ID)` 를 `false` 로 바꾸게 되면 발생 안할 것 같음!
  - 이 부분에 대해서 좀 더 확인해보자!

#### 5-1. c 에 대한 세부확인
- 아래 영역에 대해서 어디서 값을 세팅하는지 확인해보자.
```java
this.typeMapper.getTypePrecedence()
```

- 생성자에서 세팅하는걸 확인할 수 있다.
  - spring-kafka 2.2.5, 2.8.3 같음.
```
this.typeMapper.setTypePrecedence(useHeadersIfPresent ? TypePrecedence.TYPE_ID : TypePrecedence.INFERRED);
```

- `boolean useHeadersIfPresent` : true to use headers if present and fall back to target type if not.
  - 기본값은 `true`...
  - 해당 값을 `false` 로 변경하게 되면 `TypePrecedence.INFERRED` 로 동작하게 되고, JsonDeserializer 에 선언한 class(TestV2DTO.class) 를 사용하게 됩니다.

```java
JsonDeserializer<TestV2DTO> jsonDeserializer = new JsonDeserializer<>(TestV2DTO.class, KafkaStaticOptions.OBJECT_MAPPER, false);
```

#### 5-2. 테스트
- 해당 값을 변경하고 우선순위에 상관없이 잘 동작하는걸 확인 할 수 있었음!!

## 6. 추가 확인....
- 분명 `__TypeId__` 라는 Header 값이 있는데, 왜 컨슘하는 listener 에서는 해당 데이터를 확인 할 수 없었을까?
- `JsonDeserializer` 의 `deserialize()` 메소드를 확인해보면 아래와 같은 부분이 있다.
  - `removeTypeHeaders` 의 기본값은 `true`.
```java
if (this.removeTypeHeaders) {
	this.typeMapper.removeHeaders(headers);
}
```

- JsonDeserializer 에 해당 값을 false 로 세팅하게 되면 header 들을 제거하지 않음.
```java
jsonDeserializer.setRemoveTypeHeaders(false);
```

- 아래와 같이 선언하여 확인해보면 Header 값들을 확인 할 수 있다.

```java
@Header(AbstractJavaTypeMapper.DEFAULT_CLASSID_FIELD_NAME) String typedId,
@Header(AbstractJavaTypeMapper.DEFAULT_CONTENT_CLASSID_FIELD_NAME) Object contentFieldName,
@Header(AbstractJavaTypeMapper.DEFAULT_KEY_CLASSID_FIELD_NAME) Object keyFieldName,
```

