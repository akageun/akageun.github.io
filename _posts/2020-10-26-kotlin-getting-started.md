---
layout: post
title:  "[Kotlin 맛보기] 1. 기본문법"
date:   2020-10-26 09:00:00 +0900
categories:
 - kotlin
tags: 
 - kotlin
---

- [코틀린 공식 홈페이지](https://kotlinlang.org/), [문서](https://kotlinlang.org/docs/reference/)
- [코틀린 연습해보기](https://try.kotlinlang.org/#/Examples/Hello,%20world!/Simplest%20version/Simplest%20version.kt)
- 코틀린을 처음 배우면서 작성한 글 입니다.

## entry point
- 메인메소드

```kotlin
fun main() {
    println("Hello world!")
}
```

or 

```kotlin
fun main(args: Array<String>) {
    println("Hello, world!")
}
```

## 타입
- 숫자(정수) : `Long`, `Int`, `Short`
- 숫자(실수) : `Double`, `Float`
- `Byte`
- 문자 : `Char`
- 문자열 : `String`

## 변수
- var(or val) 변수명:타입 = 값 

#### `val`, `var`
###### `val` : 상수
- `read-only`

```kotlin
val a1 = 0
val a3: String
    a3 = "Test" //에러발생

val oneMillion = 1_000_000 //underscore 로 읽기 쉽게 만들 수 있다. since 1.1 
```

###### `var` : 변수
```kotlin
var a1 = 0
    a1 = 1
var a3: String
    a3 = "Test"
```

#### 변수선언 - `타입`
```kotlin
val a1: Int = 1 //즉시 대입
val a2 = 2 //타입 추론(Int 로 추론 가능)
val a3 = '안녕하세요' //String으로 추론
val pi: Double = 3.14
```

## 함수
> fun 함수명(매개변수:타입) : 리턴타입{return;}

```kotlin
fun sum(num1: Int, num2: Int): Int {
    return num1 + num2
}

fun sum(num1: Int, num2: Int) = num1 + num2 
```

#### java 에서 void 는? `Unit`
```kotlin
fun printSum(a: Int, b: Int): Unit {
    println("sum : $a + $b = ${a + b}")
}
```

- `Unit` 는 생략 가능함.
```kotlin
fun printSum(a: Int, b: Int) {
    println("sum : $a + $b = ${a + b}")
}
```

## 주석
```kotlin
// 주석

/* 주석 */
```

## null?
- 변수 or return type 에 `?` 을 붙이면 null 이 될 수 있다는 뜻.

```kotlin
var a1: Int = null // 오류 발생
var b1: Int? = null  // 정상, nullable
```
