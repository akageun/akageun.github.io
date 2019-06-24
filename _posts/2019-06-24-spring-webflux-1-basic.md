---
layout: post
title:  "[Reactive! Webflux] 1. Spring webflux 맛보기"
date:   2019-06-24 00:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
---
# Spring webflux 맛보기
- https://docs.spring.io/spring/docs/5.0.0.BUILD-SNAPSHOT/spring-framework-reference/html/images/webflux-overview.png
![image](https://user-images.githubusercontent.com/13219787/59997355-dc31f380-9697-11e9-9fc4-942e2f2422c3.png)

## Spring webflux 란?
- 기존 Spring MVC와는 다른 방식으로 구현됨(MVC는 동기방식)
- Non-blocking Reactive 개발 가능
- Request -> Response 시에 하나씩 차지했던 쓰레드 패러다임과 다름

## Spring Webflux 사용해보기
- **spring webflux는 기본적으로 tomcat이 아닌 netty를 기반으로 동작합니다.**

> 2019-xx-xx xx:xx:xx.xxx  INFO xxxx --- [  restartedMain] o.s.b.web.embedded.netty.NettyWebServer  : Netty started on port(s): 8080

- 두가지 방식으로 프로그래밍을 할 수 있다.
    - **Annotated Controller** : Spring MVC 모델 기반으로 Spring web 모듈과 같은 방식, 기존 Spring MVC에서 제공하는 Annotation을 사용할 수 있다.

    - **Functional Endpoints** : JDK 8, Lambda style routing 과 handling 방식, 가벼운 routing기능과 request 처리 라이브러리라고 생각하면 쉽고, callback형태로써 요청이 있을 때만 호출된다는 점이 annotated controller방식과의 차이점.

- **Mono**는 단일 데이터, **Flux**는 리스트 데이터

#### 공통 설정
- pom.xml
```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
	<scope>test</scope>
</dependency>
<dependency>
	<groupId>io.projectreactor</groupId>
	<artifactId>reactor-test</artifactId>
	<scope>test</scope>
</dependency>
```
- Bootstrap class
    - project 생성시 그대로 사용
    - `@EnableWebFlux` 를 추가한다.(추가 class를 만들어서 관리해도 무방)

```java
@SpringBootApplication
public class Application {
	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
}
```

#### Annotated Controller
- 기존 MVC와 마찬가지로 `@Controller` 를 붙여서 개발한다.

- router 관련 class

```java
@RestController
public class ExampleController {

	@GetMapping("/echo")
	public Mono<String> routerEcho2() {
		return Mono.just("Hello");
	}
}
```
- test code

```java
@RunWith(SpringRunner.class)
@WebFluxTest(controllers = ExampleController.class)
public class ExampleControllerTest {

	@Autowired
	private WebTestClient webTestClient;

	@Test
	public void testEcho1() {
		this.webTestClient.get().uri("/echo")
			.exchange()
			.expectStatus().isOk()
			.expectBody(String.class).isEqualTo("Hello");
	}

}
```

#### Functional Endpoints
- Handler를 만들고 해당 로직을 Router에 추가하는 형태
- Functional 하게 개발!

###### Basic
- Handler

```java
public class ExampleHandler {

	public Mono<ServerResponse> echo(ServerRequest req) {
		return ServerResponse.ok().body(Mono.just("Hello World!!"), String.class);
	}
}
```

- Router

```java
@Configuration
public class ExampleRouter {

	/**
	 * ExampleHandler class에 @Component 를 붙여 사용 할 수도 있음.
	 *
	 * @return
	 */
	@Bean
	public ExampleHandler exampleHandler() {
		return new ExampleHandler();
	}

	@Bean
	public RouterFunction<ServerResponse> routeEcho(ExampleHandler exampleHandler) {
		return RouterFunctions
			.route(RequestPredicates.GET("/echo2"), exampleHandler::echo);
	}
}
```

- 참고!!
    - 위 router 및 handler를 합쳐서 아래와 같이 선언 할 수 있음.

```java
@Bean
public RouterFunction<ServerResponse> routeEcho(ExampleHandler exampleHandler) {
	return RouterFunctions
		.route(RequestPredicates.GET("/echo2"), serverRequest -> ServerResponse.ok().body(Mono.just("Hello World!!"), String.class));
}
```

- test code

```java
@RunWith(SpringRunner.class)
@WebFluxTest(controllers = ExampleRouter.class)
public class ExampleRouterTest {

	@Autowired
	private WebTestClient webTestClient;

	@Test
	public void testEcho2() {
		this.webTestClient.get().uri("/echo2")
			.exchange()
			.expectStatus().isOk()
			.expectBody(String.class).isEqualTo("Hello World!!");
	}

}
```

###### URI 정보를 받아서 사용해보자.
- handler

```java
public class ExampleHandler {
	public Mono<ServerResponse> echo4(ServerRequest req) {
		return ServerResponse.ok().body(BodyInserters.fromObject("Hello, " + req.pathVariable("name")));
	}
}
```

- router

```java
@Bean
public RouterFunction<ServerResponse> routeEcho(ExampleHandler exampleHandler) {
	return RouterFunctions
		.route(RequestPredicates.GET("/echo2"), exampleHandler::echo)
		.andRoute(RequestPredicates.path("/echo4/{name}"), exampleHandler::echo4);
}
```

- test code

```java
@RunWith(SpringRunner.class)
@WebFluxTest(controllers = ExampleRouter.class)
public class ExampleRouterTest {

	@Autowired
	private WebTestClient webTestClient;

	@Test
	public void testEcho3() {
		final String name = "geun";

		this.webTestClient.post().uri("/echo4/" + name)

			.exchange()
			.expectStatus().isOk()
			.expectBody(String.class).isEqualTo("Hello, " + name);
	}
}
```

---

## 참고자료
- http://wiki.sys4u.co.kr/pages/viewpage.action?pageId=8552586

