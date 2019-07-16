---
layout: post
title:  "[Spring Webflux] 3. test case 만들어보기!"
date:   2019-06-23 09:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
---
# 3. test case 만들어보기!

## 컨트롤러 호출해서 테스트하기!(WebTestClient)
- `@WebFluxTest`를 사용해서 테스트하려는 controller를 추가한다.

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

## Publisher 테스트 해보기(StepVerifier)
- `StepVerifier`는 Mono/Flux를 Test하기 위한 도구 입니다.

###### verifyComplete();
> expectComplete().verify();  와 같은 로직

###### count check
```java
StepVerifier
	.create(Flux.just("안녕", "하세요", "뭐하니"))
	.expectNextCount(3)
	.verifyComplete();
```

###### Exception Check
- @Test(expected = RuntimeException.class) 와 같은 로직

```java
StepVerifier.create(Flux.error(RuntimeException::new))
	.expectError(RuntimeException.class)
	.verify();
```

## Mock처리해서 Test 확인하기
```java
@Slf4j
@RunWith(SpringRunner.class)
@WebFluxTest
@ContextConfiguration(classes = {ReactiveCassandraConfig.class})
public class WebfluxTestRepoTest {

	@Autowired
	private WebfluxTestRepo webfluxTestRepo;

	@Before
	public void setUp() {
		Flux<WebfluxTest> deleteAndInsert = webfluxTestRepo.deleteAll()
			.thenMany(webfluxTestRepo.saveAll(Flux.just(new WebfluxTest("1", 50),
				new WebfluxTest("2", 45),
				new WebfluxTest("3", 42),
				new WebfluxTest("4", 27))
			));

		StepVerifier
			.create(deleteAndInsert.doOnNext(info -> log.info("info : {}", info)))
			.expectNextCount(4)
			.verifyComplete();
	}

	@Test
	public void detail() {
		StepVerifier
			.create(webfluxTestRepo.findById("1"))
			.expectNextCount(1)
			.verifyComplete();

	}
}
```

---
참고자료
- https://www.thecuriousdev.org/junit-test-spring-webflux/ 
- http://blog.naver.com/PostView.nhn?blogId=gngh0101&logNo=221450410231&from=search&redirect=Log&widgetTypeCall=true&directAccess=false
- https://stackoverflow.com/questions/44762798/how-to-perform-assertion-on-all-remaining-elements-in-stepverifier
