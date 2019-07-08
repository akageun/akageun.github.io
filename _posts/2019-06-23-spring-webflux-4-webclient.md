---
layout: post
title:  "[Spring Webflux] 4. WebClient 사용해보기"
date:   2019-06-23 09:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
 - webclient
---
# Webclient

## Instance 생성하는 법

#### 기본 세팅으로 생성
```java
WebClient webClient = WebClient.create();
```

#### BaseURL 값을 추가해서 생성
```java
WebClient webClient = WebClient.create("http://localhost:8080");
```

#### DefaultWebClientBuilder 를 사용해서
```java
WebClient webClient = WebClient
  .builder()
    .baseUrl("http://localhost:8080")
    .defaultCookie("key", "value")
    .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE) 
  .build();
```

## URI 생성하기
#### 간단한 문자열 추가
```java
WebClient.create().get().uri("/test").retrieve()
```

#### URI class 사용
```java
WebClient.create().get().uri(URI.create("/test")).retrieve();
```

#### Builder 사용
###### queryParam 사용
```java
WebClient.create().get()
	.uri(uriBuilder ->
		uriBuilder.path("/test")
			.queryParam("name", "value")
                        .build()
	).retrieve();
```

###### queryParams, MultiValueMap

```java
MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
params.add("name_1", "value_1");
params.add("name_2", "value_2");
params.add("name_3", "value_3");

WebClient.create().get()
	.uri(uriBuilder ->
		uriBuilder.path("/test")
			.queryParams(params).build()
	).retrieve();
```

## parameter 추가
- GET일 경우에는 URI 에 추가.
- post()를 사용할 경우
- .body() -> `BodyInserters`클래스를 사용하여 주입
- MultiValueMap 도 사용가능

```java 
MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
params.add("test_1", "value_1");
params.add("test_2", "value_2");

WebClient.create()
	.post()
	.body(BodyInserters.fromFormData(params))
	.exchange();
```

- 사용하던 model 그대로 호출

```java
WebClient.create()
	.post()
	.body(BodyInserters.fromObject(new TempModel()))
	.exchange();
```

## Header 추가.
```java
WebClient.create()
	.get()
	.header("test", "value")
	.headers(headers -> {
		headers.add("test_1", "value_1");
		headers.add("test_2", "value_2");
	})
```

## Response 가져오기
- 상태값에 따른 에러처리 법도 추가해놓음.

#### retrieve()
- 바로 Body를 가지고옴
- `.bodyToMono(String.class)` 형태로 바로 사용 가능 : bodyToFlux 도 사용가능

```java
WebClient.create().get()
	.retrieve()
	.onStatus(HttpStatus::is4xxClientError, clientResponse -> Mono.error(RuntimeException::new))
	.onStatus(HttpStatus::is5xxServerError, clientResponse -> Mono.error(RuntimeException::new))
	.bodyToMono(String.class);
```

#### exchange()
- 상태값, Header 등을 가지고옴
- ClientResponse

```java
WebClient.create().get()
	.exchange()
	.flatMap(clientResponse -> {

		if (clientResponse.statusCode().is4xxClientError()) {
			return Mono.error(new RuntimeException("4xx exception"));
		} else if (clientResponse.statusCode().is5xxServerError()) {
			return Mono.error(new RuntimeException("5xx exception"));
		}

		return Mono.just(clientResponse);
	});
```


## 참고자료
- https://junebuug.github.io/2019-02-11/resttemplate-vs-webclient
- https://www.baeldung.com/spring-5-webclient
- https://hub.packtpub.com/implementing-a-non-blocking-cross-service-communication-with-webclienttutorial/