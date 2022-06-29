---
layout: post
title:  "[Spring Boot] Spring boot Actuator"
date:   2016-08-21 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - monitoring
---
## 1. Actuator란
- 어플리케이션의 health check를 손쉽게 할 수 있는 Spring boot 자원이다.

## 2. pom.xml 에 추가
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

## 3. Endpoints
[Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html)

## 4. run

## 5. 기타

#### 1) App info(application.properties에 위 소스 추가)

```
info.app.name=Sample
info.app.description=Spring Boot Start Sample 
info.app.version=1.0.0-snapshot
```

- 실행화면 

![image](https://user-images.githubusercontent.com/13219787/65332656-0e50e400-dbfa-11e9-8494-b5e26570f9a6.png)

#### 2) Custom Endpoint(application.properties에 위 소스 추가)

```
management.context-path=/monitor
```

#### 3) 실행화면

![image](https://user-images.githubusercontent.com/13219787/65332691-1f015a00-dbfa-11e9-8e90-52edca89c491.png)
