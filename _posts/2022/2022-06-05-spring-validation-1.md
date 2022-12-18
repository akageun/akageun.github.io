---
layout: post
title: "Spring 에서 Validation 하기(1)"
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

```http
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

# @Validated
- `@Valid` 와 달리 `@Validated` 는 AOP 기반으로 동작
  - MethodValidationInterceptor
  - Spring Bean 이라면 검증을 진행함.
  
## @Valid 와 @Validated
- @Valid : JSR-303 자바 표준이고 ArgumentResolver 를 통해 진행되어 Controller 만 적용 가능
  - 실패시 `MethodArgumentNotValidException.class` 가 발생
- @Validated : Spring Framework 기능이고, 실패시에는 `ConstraintViolationException.class`가 발생.

# GlobalExceptionHandler
- 샘플코드처럼 `BindingResult result`를 선언하거나 Default 로 처리되고 있는 로직을 사용할 수 있겠지만, 공통 로직으로 선언하여 처리할 수 있다.
- `@ExceptionHandler` 를 선언한 곳에 아래와 같이 처리 할 수 있다.   

```java

@ExceptionHandler(MethodArgumentNotValidException.class)
public ResponseEntity<String> methodArgumentNotValidException(
        MethodArgumentNotValidException e, 
        HttpServletRequest request
        ) {
    return new ResponseEntity<String>(e.getBindingResult(), HttpStatus.BAD_REQUEST);
}

@ExceptionHandler(ConstraintViolationException.class)
public ResponseEntity<String> constraintViolationException(
        ConstraintViolationException e,
        HttpServletRequest request
        ) {
        return new ResponseEntity<String>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
```

# 수동 호출
- 아래 와 같은 방식으로 사용하면 수동으로 호출해볼 수 있고, Test case 에서도 사용 가능하다.

```java
public <T> void validate(T object, Class<?>... groups) {
	ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
	Validator validator = factory.getValidator();
	Set<ConstraintViolation<T>> violations = validator.validate(object, groups);
	if (!violations.isEmpty()) {
		throw new ConstraintViolationException(violations);
	}
}
```

# Custom Annotation 만들기
- annotation

```java
@Documented
@Constraint(validatedBy = StatusValidator.class)
@Target({ElementType.METHOD, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
public @interface StatusChecker {
    String message() default "지정된 Type 만 사용 가능 합니다.";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
```

- validator

```java
public class StatusValidator implements ConstraintValidator<Status, String> {

    @Override
    public void initialize(Name name){
    }

    @Override
    public boolean isValid(String field, ConstraintValidatorContext cxt){
        return false;
    }
}
```

- how to use

```java
class CreateRequest {

    @StatusChecker
    private String status;
    
    ...
}
```

---
## 참고 링크
- https://meetup.toast.com/posts/223
- https://kapentaz.github.io/java/Java-Bean-Validation-%EC%A0%9C%EB%8C%80%EB%A1%9C-%EC%95%8C%EA%B3%A0-%EC%93%B0%EC%9E%90/#
- https://mangkyu.tistory.com/174
- https://velog.io/@heehee/Spring-Bean-validation-%EB%BD%90%EB%82%98%EA%B2%8C-%EC%8D%A8%EB%B3%B4%EC%A7%80-%EC%95%8A%EC%9D%84%EB%9E%98