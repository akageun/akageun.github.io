---
layout: post
title:  "[Webflux Tip] 3. Webflux Error 처리!"
date:   2019-07-26 09:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
 - tip
---

# Webflux Error 처리!
- `doOnError()` : 예외가 발생했을 경우, 특정 행위를 실행시킬 경우 사용
- `onErrorReturn` : 예외가 발생했을 때 특정 값을 Return 함
- `onErrorResume` : 예외가 발생했을 때 다른 Flux형태로 Return 함
- `onErrorContinue` : 예외가 발생했을 때 멈추지 않고 해당 영역만 skip해서 동작함.

## doOnError
- 소스
```java
@Test
public void doOnError() {
	Flux.range(0, 5)
		.map(num -> {

			if (num == 3) {
				throw new RuntimeException("Num is " + num);
			}

			return num;
		})
		.doOnError(throwable -> log.error("err : {}", throwable.getMessage()))
		.log()
		.subscribe();
}
```
- 결과
```
| onSubscribe([Fuseable] FluxPeekFuseable.PeekFuseableSubscriber)
| request(unbounded)
| onNext(0)
| onNext(1)
| onNext(2)
WebFluxTest3 - err : Num is 3
| onError(java.lang.RuntimeException: Num is 3)
java.lang.RuntimeException: Num is 3
```

## onErrorReturn
- 소스
```java
@Test
public void onErrorReturn() {
	Flux.range(0, 5)
		.map(num -> {

			if (num == 3) {
				throw new RuntimeException("Num is " + num);
			}

			return num;
		})
		.onErrorReturn(100)
		.log()
		.subscribe();
}
```
- 결과
```
request(unbounded)
onNext(0)
onNext(1)
onNext(2)
onNext(100)
onComplete()
```

## onErrorResume
- 소스
```java
@Test
public void onErrorResume() {
	Flux.range(0, 5)
		.map(num -> {

			if (num == 3) {
				throw new RuntimeException("Num is " + num);
			}

			return num;
		})
		.onErrorResume(throwable -> {
			log.error("err : {}", throwable.getMessage());
			return Mono.empty();
		})
		.log()
		.subscribe();
}
```
- 결과
```
onSubscribe(FluxOnErrorResume.ResumeSubscriber)
request(unbounded)
onNext(0)
onNext(1)
onNext(2)
err : Num is 3
onComplete()
```

## onErrorContinue
- 소스
```java
@Test
public void onErrorContinue() {
	Flux.range(0, 5)
		.map(num -> {

			if (num == 3) {
				throw new RuntimeException("Num is " + num);
			}

			return num;
		})
		.onErrorContinue((error, element) -> log.error("err : {}, element : {} ", error.getMessage(), element))
		.log()
		.subscribe();
}
```
- 결과
```
onSubscribe(FluxOnErrorResume.ResumeSubscriber)
request(unbounded)
onNext(0)
onNext(1)
onNext(2)
err : Num is 3
onNext(4)
onComplete()
```
