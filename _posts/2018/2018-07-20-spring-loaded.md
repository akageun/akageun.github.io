---
layout: post
title:  "Spring loaded 사용해보기"
date:   2018-07-20 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
---

- (작성일 기준으로 1.2.8 버전이 최신버전)
- 자바(with Spring)를 개발하다보면 Class를 추가/변경 하는 작업을 많이 한다. 그럴때마다 서버를 리스타트하는 일은 엄청나게 번거로운 일이다. 그래서 자동으로 reload 시켜주는 걸 찾아봤다.

# 1. 설치하기
- pom.xml

```xml
<plugins>
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <dependencies>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>springloaded</artifactId>
                <version>1.2.8.RELEASE</version>
            </dependency>
        </dependencies>
    </plugin>
</plugins>
```

- jar 다운로드(이 경우에는 다운로드한 경로를 따로 복사해 놓으세요.)

> http://mvnrepository.com/artifact/org.springframework/springloaded/1.2.8.RELEASE



# 2. Spring Boot
## 1) maven 명령어로 실행

> spring-boot:run 을 실행시킨다.

## 2) vm option 추가

> javaagent:<pathTo>/springloaded-{VERSION}.jar -noverify

#### (1) Intelli J 일 경우
- File -> Setting -> Build, Execution, Deployment -> Compiler
    - Build project automatically 체크!!
    

![image](https://user-images.githubusercontent.com/13219787/61383310-63fecc80-a8e9-11e9-88ee-6d96ef53eead.png)
    

#### (2) Eclipse 일 경우
- 추후 작성

# 3. Spring Framework + Tomcat
- 추후 작성

# 4. Daemon 실행
> java -javaagent:<pathTo>/springloaded-{VERSION}.jar -noverify SomeJavaClass

# 5. 테스트 결과
## 1) 전역변수 추가 -> 안됨.
- 테스트 코드(변경 전)

```java
@RequestMapping(value = "/")
public ResponseEntity<String> test() {
   return new ResponseEntity<String>("INDEX", HttpStatus.OK);
}
```

- 테스트코드(변경 후)

```java
private String ma = "test222";

@RequestMapping(value = "/")
public ResponseEntity<String> test() {
   LOG.info("test : {} ", ma);
   return new ResponseEntity<String>("INDEX", HttpStatus.OK);
}

```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61383337-70832500-a8e9-11e9-9bf9-16c2a42009fa.png)

## 2) @Controller 추가 -> 안됨.
```java
@Controller
public class Test {
   @RequestMapping(value = "/test")
   public ResponseEntity<String> test2() {
      return new ResponseEntity<String>("INDEX 2", HttpStatus.OK);
   }
}
```

## 3) @RequestMapping 추가 -> 안됨.

```java
@RequestMapping(value = "/test")
public ResponseEntity<String> test2() {
   return new ResponseEntity<String>("INDEX 2", HttpStatus.OK);
}
```

- 404가 뜬다.

## 4) Class 추가 - 됨!!
- 테스트 코드

```java
public enum TestCd {
   BOOK, NOTE;
}
```

- 잘 추가/수정 된다.

## 5) 지역변수 -> 됨!

```java
@RequestMapping(value = "/")
public ResponseEntity<String> test() {

   String testValue = "test test test";
   LOG.info("test : {} ", testValue);

   return new ResponseEntity<String>("INDEX", HttpStatus.OK);
}
```

- 잘 추가/수정 된다.

---
## 관련문서
- https://github.com/spring-projects/spring-loaded
- https://andromedarabbit.net/spring-loaded%EC%99%80-gradle%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%B4-%ED%95%AB%EC%8A%A4%EC%99%91-%EC%A7%80%EC%9B%90%ED%95%98%EA%B8%B0/
- http://www.holaxprogramming.com/2015/05/29/spring-boot-and-loaded/







