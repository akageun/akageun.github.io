---
layout: post
title:  "[Webflux Tip] 4. webflux .map()에 null을 리턴하게 될 경우..."
date:   2019-11-05 09:00:00 +0900
categories:
 - spring
tags: 
 - webflux
 - reactive
 - tip
---

- Webflux를 사용해서 개발하던 중 어처구니 없는 에러가 발생했다.

## 에러발생 소스
- 특정 조건일 경우 null을 리턴한 다음에, filter로 null들을 제거하려고 했었다.

```java
Flux.fromIterable(IntStream.range(0, 5).boxed().collect(Collectors.toList()))
	.map(i -> {
		if (i == 3) {
			return null;
		}
		return i;
	})
	.filter(Objects::nonNull)
	.log()
	.subscribe();
```

#### 결과는??

> java.lang.NullPointerException: The mapper returned a null value.

## 자세히 파보자!
- 에러 메시지 중 아래와 같은 내용이 있어서, 자세히 봤다.

> at reactor.core.publisher.FluxMapFuseable$MapFuseableConditionalSubscriber.tryOnNext(FluxMapFuseable.java:301)

![image](https://user-images.githubusercontent.com/13219787/68108307-c75d4a80-ff2a-11e9-819d-a36d5a02e81b.png)

- 어??????????????????????????????? 이건 뭐지 이런 스팩이 있었나?? 

## 찾아보자
- https://github.com/reactive-streams/reactive-streams-jvm/ 
- (2019.11.04 기준)

```
Publisher.subscribe MUST call onSubscribe on the provided Subscriber prior to any other signals to that Subscriber and MUST return normally, except when the provided Subscriber is null in which case it MUST throw a java.lang.NullPointerException to the caller, for all other situations the only legal way to signal failure (or reject the Subscriber) is by calling onError (after calling onSubscribe).
```

## 대안
#### Optional 사용
```java
Flux.fromIterable(IntStream.range(0, 5).boxed().collect(Collectors.toList()))
	.map(i -> {
		if (i == 3) {
			return Optional.empty();
		}
		return Optional.of(i);
	})
	.filter(Optional::isPresent)
	.map(Optional::get)
	.log()
	.subscribe();
```

#### flatmap 사용
```java
Flux.fromIterable(IntStream.range(0, 5).boxed().collect(Collectors.toList()))
	.flatMap(i -> {
		if (i == 3) {
			return Mono.empty();
		}
		return Mono.just(i);
	})
	.log()
	.subscribe();
```

- 위에껄 추천한다...
