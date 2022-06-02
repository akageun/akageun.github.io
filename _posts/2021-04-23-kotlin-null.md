---
layout: post
title: "[Kotlin 맛보기] 2. Null 에 대해서..."
date: 2021-04-23 09:00:00 +0900
categories:
- kotlin 
tags:
- kotlin
---

- kotlin 은 기본 값이 null이 아닌 not null 이다.
- nullable 하게 사용하기 위해서는 `?`를 선언해야한다.

# null 허용하기
> ?

- `str : String` 은 java 에서 `@Notnull String str` 과 같음.
- `str : String?` 은 java 에서 `@Nullable String str` 과 같음.

# null 안정성
## 엘비스 연산자
> ?:

- null 대신 결과를 반환시켜줌. 디폴트 값을 선언할 때 편리함.
  - 특정 값을 리턴할 수 있음.

```kotlin
var value: String? = null

val resultValue: String = value ?: "EMPTY STRING"
val resultValue: String = value ?: throw NullPointerException()
val resultValue: String = value ?: return
```

## 안전한 호출 연산자
> ?.

- null 이 아닐경우에만 실행시키고, null 일 경우에는 그냥 null 을 리턴한다.

```kotlin
str?.toUpperCase()
```

```java
if (str != null) { 
    str.toUpperCase() 
} else { 
    null 
}

```

- 앨비스 연산자를 잘 섞어 사용하면 좋음
  - str 이 null 이 아니면 `UpperCase` 를 하고, null 일 경우에는 `EMPTY STRING` 을 리턴한다.
  
```kotlin
str?.toUpperCase() ?: "EMPTY STRING"
```

## null 값이 아님을 보장해주는 연산자
> !!

- 단, null 이 들어오면 오류가 발생함.(NPE 발생)

```kotlin
fun nonNull() {
    val str: String = "Not null String"

    val str2: String = str!! // str 은 null이 아니라는 보증함.
}
```

# 코틀린에서 안전한 null 처리하기.


---
- https://namget.tistory.com/entry/Kotlin-%EC%BD%94%ED%8B%80%EB%A6%B0-%EB%84%90-%EC%95%88%EC%A0%95%EC%84%B1%EC%97%98%EB%B9%84%EC%8A%A4-as-lateinit
- https://jeongupark-study-house.tistory.com/156
- https://thdev.tech/kotlin/2016/08/04/Kotlin-Null-Safety/
