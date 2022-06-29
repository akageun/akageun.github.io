---
layout: post
title:  "[Spring Boot] 2.x 로 변경했을 때, Thymeleaf layout이 404일 경우"
date:   2018-06-20 09:00:00 +0900
categories:
 - spring
tags: 
 - thymeleaf
---
# 1. thymeleaf-layout-dialect 추가

## 1) 기존
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

## 2) 변경

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
<dependency>
    <groupId>nz.net.ultraq.thymeleaf</groupId>
    <artifactId>thymeleaf-layout-dialect</artifactId>
</dependency>
```

---
## 참고자료 
- https://stackoverflow.com/questions/49231742/thymeleaf-stopped-resolving-layout-templates-after-migrating-to-thymeleaf-3