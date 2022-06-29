---
layout: post
title:  "[SPRING BOOT TIP] 2. X-Application-Context header?????"
date:   2018-03-08 09:00:00 +0900
categories:
 - spring
tags: 
 - spring-boot
---
# 1. X-Application-Context Header????
- response header를 보면, 아래와 같은 header 값이 있다. 
- application name과 port가 노출된다.

> X-Application-Context:application:8080

 - 사용자에게 알려줄 필요없는 정보다.
 - 지우자!!

# 2. 옵션 설정
```yml
management:
  add-application-context-header: false
```

# 3. 참고 
- 해당 Header 값은 OncePerRequestFilter에서 ApplicationContext ID를 추가한다.
