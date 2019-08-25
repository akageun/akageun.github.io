---
layout: post
title:  "public static void main(String[] args){}"
date:   2018-04-03 09:00:00 +0900
categories:
 - java
tags: 
 - java
---
# 1. public static void main(String[] args){} ????
- java로 처음 "Hello, World!"를 쓸 때 써본거.
- java application의 시작점

# 2. 소스
## 1) 전체보기
```java
/**
 * Java Entry Class
 *
 * @author geunspage
 */
public class MainTest {

   public static void main(String[] args) {
      System.out.print("Hello, World!");
   }
}
```

## 2) public
#### (1) 접근 제어자(Access Modifier)
- defualt, private, protected, public
- private -> default -> protected -> public 순으로 보다 많은 접근이 가능하다.
####  (2) 해당 값 변경 또는 제거 할 경우

```java
/**
 * Java Entry Class
 *
 * @author geunspage
 */
public class MainTest {

   private static void main(String... args) {
      System.out.print("Hello, World!");
   }
}
```

- 찾지 못함.
```
오류: MainTest 클래스에서 기본 메소드를 찾을 수 없습니다. 다음 형식으로 기본 메소드를 정의하십시오.

   public static void main(String[] args)

또는 JavaFX 애플리케이션 클래스는 javafx.application.Application을(를) 확장해야 합니다.
```

## 3) static
#### (1) 설명
- java가 처음 실행되면 클래스의 객체가 없기 때문에, 해당 메소드는 static(인스턴스를 생성하지 않고도 호출이 가능해짐)이어야 접근이 가능하다.

####  (2) 해당 값 변경 또는 제거 할 경우
```java
/**
 * Java Entry Class
 *
 * @author geunspage
 */
public class MainTest {

   public void main(String... args) {
      System.out.print("Hello, World!");
   }
}
```

- 찾지 못함.

```
오류: MainTest 클래스에서 기본 메소드가 static이(가) 아닙니다. 다음 형식으로 기본 메소드를 정의하십시오.
   public static void main(String[] args)
```

## 4) void 

#### (1) 설명
- Method의 리턴 유형
- void는 아무것도 돌려주지 않겠다는 내용.
- Main Method의 실행이 끝나면 프로그램이 종료되기 때문에, 아무것도 돌려줄 필요가 없다.

####  (2) return 0 추가

![image](https://user-images.githubusercontent.com/13219787/63651189-39781d00-c78d-11e9-9c44-7fe5b4ca9c0a.png)

####  (3) 중간에 종료하기
- 아래 "Hello, World! 2" 는 실행되지 않는다.
- 아래와 같이 작성할 경우, 대부분의 툴에서는 Dead Code라고 뜬다.

## 5) main
#### (1) java application 실행시 main 으로 실행한다는 약속된 값.
#### (2) 변경시

```java
/**
 * Java Entry Class
 *
 * @author geunspage
 */
public class MainTest {

   public static void mainTest(String... args) {
      System.out.print("Hello, World!");
   }
}
```

  - 찾지 못한다.

```
오류: MainTest 클래스에서 기본 메소드를 찾을 수 없습니다. 다음 형식으로 기본 메소드를 정의하십시오.

   public static void main(String[] args)

또는 JavaFX 애플리케이션 클래스는 javafx.application.Application을(를) 확장해야 합니다.
```

## 6) String[] args or String... args

#### (1) command line arguments 
#### (2) 예제

```java
/**
 * Java Entry Class
 *
 * @author geunspage
 */
public class MainTest {

   public static void main(String... args) {
      for (String arg : args) {
         System.out.println("arg : " + arg);
      }

   }
}
```

- 실행(intellij)

![image](https://user-images.githubusercontent.com/13219787/63651160-f9189f00-c78c-11e9-95d0-dc27b1520c81.png)

- 실행 Command Line
```
javac MainTest.java

java MainTest 1 2 3
```

- 결과
 
![image](https://user-images.githubusercontent.com/13219787/63651162-fe75e980-c78c-11e9-836f-1d2c96b64d9a.png)
