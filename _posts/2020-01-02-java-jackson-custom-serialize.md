---
layout: post
title:  "[Jackson]Custom Serializer, Deserializer 를 만들어 사용하기!"
date:   2020-01-02 09:00:00 +0900
categories:
 - java
tags: 
 - jackson
 - spring
---

# Custom Serializer, Deserializer 를 만들어 사용하기!
- 작업 중이 enum <-> string 또는 Date <-> string 등의 서비스에 맞춰서 변환작업이 필요할 경우가 있다. 그럴 경우 간단하게 작업해서 사용할 수 있다.

## 구현해야할 객체
- Serializer : `com.fasterxml.jackson.databind.JsonSerializer`
- Deserializer : `com.fasterxml.jackson.databind.JsonDeserializer`

## 설정
#### `ObjectMapper`에 module 등록하기
```java
SimpleModule simpleModule = new SimpleModule();
simpleModule.addSerializer(TestEnum.class, new TestEnumSerializer()); //TestEnumSerializer 구현할 객체
simpleModule.addDeserializer(TestEnum.class, new TestEnumDeserializer()); //TestEnumDeserializer 구현할 객체

ObjectMapper OM = new ObjectMapper();
OM.registerModules(simpleModule);
```

#### `Annotation` 을 만들어서 사용하기.
```java
public class Model {
	private int num;

	@JsonSerialize(using = TestEnumSerializer.class) //TestEnumSerializer 구현할 객체
	@JsonDeserialize(using = TestEnumDeserializer.class) //TestEnumDeserializer 구현할 객체
	private TestEnum test;
}
```

## 각 객체들을 구현해보자!
#### 구현전에 필요한 Class 들 
- 기본적으로 `lombok`을 사용하고 있습니다.

###### 샘플로 사용할 Enum

```java
@Getter
private enum TestEnum {
	TEST_1("tmpTestValue1"),
	TEST_2("tmpTestValue2"),
	;
	private String value;
	TestEnum(String value) {
	this.value = value;
	}
}
```

###### 샘플로 사용할 객체

```java
@ToString
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
private static class Model {
	private int num;
	@JsonSerialize(using = TestEnumSerializer.class)
	@JsonDeserialize(using = TestEnumDeserializer.class)
	private TestEnum test;
}
```

#### Serializer
- serialize(직렬화) : java 객체를 json 객체로 변환하는 작업!!

```java
private static class TestEnumSerializer extends JsonSerializer<TestEnum> {
	@Override
	public void serialize(TestEnum value, JsonGenerator gen, SerializerProvider serializers) throws IOException {
		gen.writeString(value.getValue());
	}
}
```

#### Deserializer
- deserialize(역직렬화) : json 객체를 java 객체로 변환하는 작업!!

```java
private static class TestEnumDeserializer extends JsonDeserializer<TestEnum> {

	@Override
	public TestEnum deserialize(JsonParser p, DeserializationContext ctxt) throws IOException, JsonProcessingException {
		for (TestEnum value : TestEnum.values()) {
			if (value.getValue().equals(p.getText())) {
				return value;
			}
		}

		return null;
	}
}
```

## 위 샘플들을 동작시켜보자.
#### Serializer
- `@JsonSerialize` 를 사용했습니다.

```java
@Test
public void serializerTest() throws IOException {
	Model model = new Model(1, TestEnum.TEST_1);
	Assert.assertEquals("{\"num\":1,\"test\":\"tmpTestValue1\"}", new ObjectMapper().writeValueAsString(model));
}
```
#### Deserializer
- `@JsonDeserialize` 를 사용했습니다.

```java
@Test
public void deserializerTest() throws IOException {
	String json = "{\"num\":1, \"test\":\"tmpTestValue1\"}";

	Model model = new ObjectMapper().readValue(json, Model.class);

	Assert.assertEquals(1, model.getNum());
	Assert.assertEquals(TestEnum.TEST_1, model.getTest());
}
```

---
