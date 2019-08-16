---
layout: post
title:  "[Spring Boot] Spring Boot로 5분만에 API 만들기"
date:   2016-08-20 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
---
# 1. Spring Boot 특징
- 따로 tomcat을 사용하지 않고도 내장 tomcat or jetty를 사용할 수 있다.(war로 배포하여 tomcat을 따로 사용할 수도 있다.)
- 복잡한 Spring의 xml or java config 설정들을 일부 자동으로 설정해준다.

# 2. Spring boot 시작하기

## 1) 프로젝트 만들기
- STS에서 NEW -> Spring Starter Project 선택 

![image](https://user-images.githubusercontent.com/13219787/61307810-f9d32280-a829-11e9-894c-92d7720ed531.png)

![image](https://user-images.githubusercontent.com/13219787/61307825-ff306d00-a829-11e9-9984-e63fe43687e2.png)

#### 기본 정보 입력

![image](https://user-images.githubusercontent.com/13219787/61307836-02c3f400-a82a-11e9-8b8b-c478fddcb01e.png)

#### 기본 라이브러리 선택
- spring-boot-starter-web을 추가했다.

## 2) Controller 만들기

```java
package kr.geun.bootStartSample.www.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Test Controller
 * 
 * @author geunspage
 *
 */
@RestController
public class TestController {

    /**
     * 테스트 데이터
     * 
     * @return
     */
    @RequestMapping("/test")
    public String getTest() {
        return "{\"result\":true,\"resultMsg\":\"성공입니다.\"}";
    }
}
```

## 3) Project Run
- Project 이름 우클릭
- Run As -> Spring Boot App 클릭 

![image](https://user-images.githubusercontent.com/13219787/61307853-09eb0200-a82a-11e9-86af-ae4a74732132.png)

# 3. 결과 화면

> Boot 기본 port는 8080이다.

![image](https://user-images.githubusercontent.com/13219787/61307876-0e171f80-a82a-11e9-9256-c1d7bb0b7c20.png)

- port 변경을 하고 싶으시면, ~/resources/application.properties 내에 아래 코드를 추가하면 된다.

> server.port=8081