---
layout: post
title:  "[Spring Async] 3. 비동기 호출에 대한 응답 받기!"
date:   2019-06-04 09:00:00 +0900
categories:
 - spring
tags: 
 - async
---

- 아래와 같이 `void`로 리턴값이 없어야 비동기로 호출 할 수 있다.

```java
@Async
public void asyncRun() {
	
}
```

# 3. 비동기 호출에 대한 응답 받기!
- 비동기로 호출하고, 그에 대한 응답도 받아보자.

## 간단하게 결과값 받아보기

#### 비동기 메소드
```java
@Async
public Future<String> asyncRun() {
	String resultMessage = "실행이 완료되었습니다.";

	try {
		Thread.sleep(1000);
		return new AsyncResult<>(resultMessage);
	} catch (InterruptedException e) {
		e.printStackTrace();
		return null;
	}
}
```

#### 호출 및 결과값 받는 메소드
```java
public void run() throws ExecutionException, InterruptedException {
	Future<String> asyncFuture = tmpService.asyncRun();
	while(true) {
		if(asyncFuture.isDone()){
			log.info("message : {}", asyncFuture.get());
			break;
		}

		Thread.sleep(1000);
	}
}
```
- 아래와 같이 호출 결과가 나옵니다.

> message : 실행이 완료되었습니다.

## CompletableFuture 사용해보기
- `java.util.concurrent.CompletableFuture<T>`
- Future를 상속한 클래스고, JDK8에 추가된 클래스
- 완료될거라는 약속이 있는 클래스

- AsyncReult를 사용하게 되면 `get()`를 사용하면서 블락킹이 발생하게 됨. (`LinstenableFuture`  라는 대안이 있기는 함, AsyncRestTemplate or WebClient 를 참고하기를 바람.)

- 여러 비동기들을 합칠 수 있다.
- 추가 메소드 등 관련 링크 : [바로가기](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html)

#### 비동기 메소드
```java
@Async
public CompletableFuture<String> asyncRun() {
	String resultMessage = "실행이 완료되었습니다.";

	try {
		Thread.sleep(1000);
	} catch (InterruptedException e) {
		e.printStackTrace();
	}

	return CompletableFuture.completedFuture(resultMessage);
}
```

#### 호출 및 결과값 받는 메소드
- 기존처럼 while true 형태로 대기하지 않아도 됨.
- `allOf`를 사용하면 list 내에 있는 모든 Thread가 종료될 때까지 대기함.

```java
public void run() throws ExecutionException, InterruptedException {

	List<CompletableFuture<String>> result = new ArrayList<>();
	for (int i = 0; i < 3; i++) {
		CompletableFuture<String> asyncFuture = asyncRun();
		result.add(asyncFuture);
	}

	CompletableFuture.allOf(result.toArray(new CompletableFuture[0])).join();
}
```

# 4. 사용하며 주의해야할 점

## 본인 스스로를 호출하면 비동기 호출이 안된다.
- 분명 리팩토링 등의 이슈로 초기 소스가 변경 될 수 있다.
- 그런 경우를 대비하여 method 명 앞에 async를 붙인다던가, 주석 내에 비동기 임을 명시해 놓고, 분리해야한다는 걸 꼭 강조해놔야한다. 
- 분명 리팩토링 후 테스트 시에는 데이터가 적어 잘 드러나지 않아, 놓칠 수 있다.

## 유실될 수 있다.
- Thread 설정값에 따라 처리량이 넘칠 수 있다.
- `RejectedExecutionHandler` 를 어떻게 설정하느냐에 따라 유실 될 수도 있다.
- 사용량을 잘 판단해서 설정 값을 정해야한다.
- 또는 상황에 따라 `TaskExecutor` 설정을 다르게 해서 처리하게 할 수 있다.
    - 순간 여러 Thread를 열어 빠른 처리 하려고 한다. Max 값을 높게 하고 Queue값을 낮게 함.
    - 느리더라도 꾸준히 처리되면 된다. Max 값은 작지만 Queue 값을 크게 설정하여 운영.
