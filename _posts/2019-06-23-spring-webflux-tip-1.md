---
layout: post
title:  "[Webflux Tip] 1. WebTestClient timeout"
date:   2019-06-23 09:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
 - tip
---

# [Webflux Tip] 1. WebTestClient timeout
- 아래 `WebClientOverTimeController` 와 같은 route를 테스트 하려고 한다.

```java
@RestController
public class WebClientOverTimeController {

	@GetMapping("/overtime/check")
	public String overTimeCheck() throws Exception {
		Thread.sleep(10000);
		return "OK";
	}
}
```

- 아래 `WebClientOverTimeControllerTest` 는 위 route를 테스트 하기위해 작성된 코드

```java
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class WebClientOverTimeControllerTest {

	@Autowired
	private WebTestClient webTestClient;

	@Test
	public void overtimeCheck() {
		this.webTestClient.get().uri("/overtime/check")
			.exchange()
			.expectStatus().isOk()
			.expectBody(String.class).isEqualTo("OK");
	}
}
```

## 에러발생
> java.lang.IllegalStateException: Timeout on blocking read for 5000 MILLISECONDS

## 해결책
#### @AutoConfigureWebTestClient 추가
- Timeout 설정을 늘려주자.

```java
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebTestClient(timeout = "1500") //15sec
```

#### @WebFluxTest 로 변경

```java
@RunWith(SpringRunner.class)
@WebFluxTest(controllers = {WebClientOverTimeController.class})
```

## 참고자료
- https://www.mkyong.com/spring-boot/spring-webflux-test-timeout-on-blocking-read-for-5000-milliseconds/