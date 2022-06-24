---
layout: post
title: "[Spring 다시보기] Spring DI"
date: 2021-01-02 09:00:00 +0900
categories:
- spring
tags:
- spring
- java
- di
---
## DI 란?
- Dependency Injection
- 의존성 주입
- 객체를 직접 생성하는 것이 아닌 외부에서 생성한 후 주입하는 것

## DI를 사용하는 이유
- 재사용성을 높여줌
- 테스트에 용이함
- 코드를 단순하게하고 읽기 쉽게 만들어 준다.
- 종속성이 감소하여 변경에 민감하지 않음
- 결합도를 낮추면서 유연성과 확장성을 향상 시킬 수 있다.
- 객체 간의 의존관계를 설정할 수 있다.

## 의존성 주입 방법
- Construct Injection

```java
@Service
public class TestA {

    private final TestB testB;

    public TestA(TestB testB) {
        this.testB = testB;
    }
}
```

- Field Injection

```java
@Service
public class TestB {

    @Autowired
    private TestC testC;

}
```

- Setter Injection

```java
@Service
public class TestC {

    private TestB testB;

    public void setTestB(TestB testB) {
        this.testB = testB;
    }
}
```

### 권장하는 방법
- `Construct injection` 방식을 권장한다.

##### 순환참조...
- field injection 이나 setter injection 의 경우, 객체를 생성하는 시점에 순환참조가 일어나는지 알 수가 없다.
- `TestB`, `TestC` 두개를 Construct injection 으로 변경하여 테스트 하였다.

```java
@Service
public class TestB {

    private TestC testC;

    public TestB(TestC testC) {
        this.testC = testC;
    }
}

@Service
public class TestC {

    private final TestB testB;

    public TestC(TestB testB) {
        this.testB = testB;
    }
}
```

```
***************************
APPLICATION FAILED TO START
***************************

Description:

The dependencies of some of the beans in the application context form a cycle:

   testA defined in file [~/test/target/classes/com/example/test/TestA.class]
┌─────┐
|  testB defined in file [~/test/target/classes/com/example/test/TestB.class]
↑     ↓
|  testC defined in file [~/test/target/classes/com/example/test/TestC.class]
└─────┘
```

- 이렇게 사용하게되면 객체를 생성할때 확인할 수 있으므로, runtime 이 아닌 build 타임에 순환참조를 잡을 수 있다.
  - `@Lazy` 와 같은 방식으로 대응은 할 수 있겠지만... 추천하는 방법은 아니므로 순환참조를 끊는게 중요한 포인트 같다.
