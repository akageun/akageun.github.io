---
layout: post
title:  "[Reactive! Webflux] 2. Mono and Flux"
date:   2019-06-24 00:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
---
# Mono and Flux
- **org.reactivestreams.Publisher**의 구현체
- 시퀀스를 제공하는 발행자 역할
- Mono : 0-1 개의 데이터 전달
- Flux : 0-N개의 데이터 전달

## 간단하게 사용해보기

#### Mono

###### empty()
> Mono<String> data = Mono.empty();

###### just()
> Mono<String> data = Mono.just("");

###### error()
> Mono.error(RuntimeException::new);

###### 위 내용에 대한 전체소스
```java
@Test
public void mono() {
    Mono.empty().subscribe(s -> log.info("empty() : {}", s)); //출력안됨

    Mono.just("Test Value")
        .subscribe(s -> log.info("just() : {}", s));

    Mono.error(RuntimeException::new)
        .doOnError(e -> log.error(e.getMessage(), e))
        .subscribe(s -> log.info("error() : {}", s));
}
```

#### Flux
- 한개의 시퀀스가 전달 될 때마다 **doOnNext** 이벤트 발생
- 모든 데이터가 전달 완료되면 **doOnComplete** 이벤트 발생
- 전달 과정에서 오류가 발생하면 **doOnError** 이벤트발생
- Publisher는  **subscribe**가 되었을 경우에만 데이터를 전달함. `subscribe()` 호출 필요
    - 매개변수로 넣을 수 있는 Consumer의 경우 **doOnNext**가 호출 될 때마다 실행되는 함수
    - 소스 : 아래 소스  `.subscribe();` 를 제거하게되면, 실행되지 않는다.

```java
@Test
public void test() {
	Flux.just(1, 2, 3)
		.doOnNext(i -> log.info("doOnNext : {} ", i))
		.subscribe();
}
```
    - 결과
```
xxx.FluxTestCase - doOnNext : 1 
xxx.FluxTestCase - doOnNext : 2 
xxx.FluxTestCase - doOnNext : 3 
```

###### empty()
> Flux<String> data = Flux.empty();
###### just()
> Flux<String> data = Flux.just("", "");
###### range()
> Flux.range(0, 10);
###### fromArray(), fromIterable(), fromStream()
> Flux.fromArray(new String[]{"value 1", "value 2", "value 3"});
> Flux.fromIterable(Arrays.asList("value 1", "value 2", "value 3"));
> Flux.fromStream(IntStream.range(0, 10).boxed())

###### 위 내용에 대한 전체소스
- **log()** 함수를 붙여 로그를 확인 할 수 있다.

```java
@Test
public void flux() throws InterruptedException {
    Flux.empty().subscribe(s -> log.info("empty() : {}", s)); //출력안됨
    Flux.just("value 1", "value 2", "value 3")
        .subscribe(s -> log.info("just() : {}", s));

    Flux.range(0, 10)
        .subscribe(s -> log.info("range() : {}", s));

    Flux.fromArray(new String[]{"value 1", "value 2", "value 3"})
        .subscribe(s -> log.info("fromArray() : {}", s));

    Flux.fromIterable(Arrays.asList("value 1", "value 2", "value 3"))
        .subscribe(s -> log.info("fromIterable() : {}", s));

    Flux.fromStream(IntStream.range(0, 10).boxed())
        .subscribe(s -> log.info("fromStream() : {}", s));

    Flux.interval(Duration.ofMillis(100))
        .map(item -> "tick: " + item)
        .take(10)
        .subscribe(s -> log.info("fromIterable() : {}", s));

    Thread.sleep(150);

    Flux.error(RuntimeException::new)
        .doOnError(e -> log.error(e.getMessage(), e))
        .subscribe(s -> log.info("error() : {}", s));
}
```
