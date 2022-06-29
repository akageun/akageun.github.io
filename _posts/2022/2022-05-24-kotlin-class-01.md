---
layout: post
title: "[Kotlin 맛보기] 3. Class "
date: 2022-05-24 09:00:00 +0900
categories:
- kotlin
tags:
- kotlin
---

## `open`, `abstract`
- Kotlin 은 Java 와 다르게 기본적으로 `final` 이 적용되어 있다.
  - 자바는 `final` 키워드를 사용하여 상속 또는 오버라이드를 못하도록 함.
- kotlin 에서는 상속 등을 사용하려면 기본 설정이 `final`이므로 따로 처리를 해줘야 사용이 가능함.
- `open` 을 선언하게 되면 자식 클래스에서 부모 클래스를 상속 할 수 있다.

```kotlin
/**
 * 부모 클래스
 */
open class Parent {
    /**
     * 하위 클래스에서 오버라이드할 수 없음.
     */
    fun call() {

    }

    /**
     * open 을 추가해놔서, 하위 클래스에서 오버라이드 가능
     */
    open fun call(name: String) {

    }
}

/**
 * 자식 클래스
 */
class Child : Parent() {

    override fun call(name: String) {

    }
}
```

- `abstract`

```kotlin
/**
 * 부모 클래스
 */
abstract class Parent {
    /**
     * 하위 클래스에서 오버라이드 해야만함.
     */
    abstract fun callMe()

    /**
     * 하위 클래스에서 오버라이드할 수 없음.
     */
    fun call() {

    }

    /**
     * open 을 추가해놔서, 하위 클래스에서 오버라이드 가능
     * - 하위 클래스에서 오버라이드 할지 말지는 로직에 따라 판단할 수 있음.
     */
    open fun call(name: String) {

    }
}

/**
 * 자식 클래스
 */
class Child : Parent() {
    override fun callMe() {

    }

    override fun call(name: String) {

    }
}
```

## `constructor` : 생성자
#### 주 생성자 

```kotlin
class TempTest(val name: String)

```

#### private 생성자
- 생성자를 숨기고 싶을 때 사용 가능

```kotlin
class TempTest private constructor(val name: String) {

}
```

#### 부 생성자
- 디폴트 파라미터로 사용하여 만들 수 있지만, 굳이 생성자를 여러개 만들겠다면 아래와 같이 사용 가능.

```kotlin
class TempTest(val name: String) {
    var age: Int = 20
    var height: Int = 500
    
    constructor(name: String, age: Int) : this(name) {
        this.age = age
    }
    constructor(name: String, age: Int, height: Int) : this(name, age) {
        this.height = height
    }
}
```