---
layout: post
title:  "HashMap Key에 Object를 잘~ 사용하고 싶다."
date:   2019-10-17 09:00:00 +0900
categories:
 - java
tags: 
 - java
---

## HashMap Key에 Object를 사용하고 싶을 때!

- 일단 테스트를 위해 model 하나를 만들어보자!

```java
@Getter
@NoArgsConstructor
private static class KeyObj {
    private String id;
    private String name;


    @Builder
    public KeyObj(String id, String name) {
        this.id = id;
        this.name = name;
    }

    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
```

- 해당 모델을 사용해서 HashMap을 사용해보자!
- 일단 기본적으로 `put` 를 해보고 `containsKey` 결과를 보자!

```java
Map<KeyObj, String> testMap = new HashMap<>();

KeyObj key1 = KeyObj.builder()
    .id("test1")
    .name("name_1")
    .build();

testMap.put(key1, "1");

Assert.assertTrue(testMap.containsKey(key1)); //true
```

- 그럼 `KeyObj` 를 `key1`의 id, name과 동일한 값으로 `key2`를 만들어서 `containsKey` 해보자

```java
String key1Id = "test1";
String key1Name = "name_1";

Map<KeyObj, String> testMap = new HashMap<>();

KeyObj key1 = KeyObj.builder()
    .id(key1Id)
    .name(key1Name)
    .build();

KeyObj key2 = KeyObj.builder()
    .id(key1Id)
    .name(key1Name)
    .build();

testMap.put(key1, "1");

Assert.assertTrue(testMap.containsKey(key2)); //false
```

- 위 코드는 `false`가 나온다.

- HashMap 의 Key로 사용하기 위해서는 `equals` 와 `hashCode` 를 override 해야한다.
    - 위에서 만든 Model 에 두개 메소드를 재정의 해보자
    
```java
@Getter
@NoArgsConstructor
private static class KeyObj {
    private String id;
    private String name;


    @Builder
    public KeyObj(String id, String name) {
        this.id = id;
        this.name = name;
    }

    @Override
    public String toString() {
        return org.apache.commons.lang3.builder.ToStringBuilder.reflectionToString(this);
    }

    @Override
    public boolean equals(Object obj) {
        return org.apache.commons.lang3.builder.EqualsBuilder.reflectionEquals(this, obj);
    }

    @Override
    public int hashCode() {
        return org.apache.commons.lang3.builder.HashCodeBuilder.reflectionHashCode(this);
    }
}
```

- 편하게 사용하기 위해서 commons 라이브러리를 사용했다.

```xml
<dependency>
   <groupId>org.apache.commons</groupId>
   <artifactId>commons-lang3</artifactId>
   <version>3.9</version>
</dependency> 
```

- 두개의 메소드를 추가 한 후로 다시 동작시켜보면, 결과가 `ture` 로 나올 것이다.

```java
Assert.assertTrue(testMap.containsKey(key2)); //true
```
