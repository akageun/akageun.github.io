---
layout: post
title: "Spring 에서 Validation 하기"
date: 2022-06-05 09:00:00 +0900
categories:
- spring
tags:
- spring
- validation
---

- API 를 개발하는 과정 등에서 중요한 부분이 요청 값에 대한 검증처리 일 것이다.
- 조금 더 편하게 데이터 유효성을 검사할 수 있는 방법을 알아보자.

# 의존성 추가

```groovy
implementation("org.springframework.boot:spring-boot-starter-validation")
```

- 위 의존성을 추가하게 되면 `hibernate-validator` 을 구현체로 사용한다.

# 간단하게 사용해보기
- `@Valid` 를 사용하여 간단히 유효성 검사를 해보자.

## 소스코드 

```java
@PostMapping("/test/validation")
public String testValidation(
        @Valid @RequestBody TestRequest request, BindingResult result
) {

    if (result.hasErrors()) {
        List<FieldError> list = result.getFieldErrors();
        for (FieldError e : list) {
            log.error("bad request - field: {}, message : {}", e.getField(), e.getDefaultMessage());
        }
    }

    return "OK";
}
```

```java
@Getter
@Setter
public class TestRequest {

  @NotBlank
  private String name;
  
  @Min(1)
  private int age;
  
  public TestRequest() {
  }
        
}
```

```http request
POST http://localhost:9999/test/validation
Content-Type: application/json

{}
```

## 결과
- 손쉽게 필드에 대해서 유효성 검증을 할 수 있다.

```text
bad request - field: name, message : 공백일 수 없습니다
bad request - field: age, message : 1 이상이어야 합니다
```



# @Validated and @Valid

# 수동 호출

# Custom Annotation 만들기