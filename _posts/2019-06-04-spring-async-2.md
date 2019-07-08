---
layout: post
title:  "[Spring Async] 2. 예외 처리에 대해"
date:   2019-06-04 09:00:00 +0900
categories:
 - spring
tags: 
 - async
---
# Async를 사용하며 예외에 대한 대응 방법

## AsyncUncaughtExceptionHandler 설정
#### Method로 만들기
- **AsyncExceptionHandler** 를 만들어보자!

```java
@EnableAsync
@Configuration
public class AsyncConfig implements AsyncConfigurer {

	@Override
	public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
		return new AsyncExceptionHandler();
	}
}
```

#### Class로 만들기
```java
@Slf4j
public class CustomAsyncExceptionHandler implements AsyncUncaughtExceptionHandler {
	@Override
	public void handleUncaughtException(Throwable ex, Method method, Object... params) {
		log.error("Method name : {}, param Count : {}\n\nException Cause -{}", method.getName(), params.length, ex.getMessage());
	}
}
```

#### 람다로 이쁘게 표현하기
```java
@Override
public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
	return (ex, method, params) -> log.error("Method name : {}, param Count : {}\n\nException Cause -{}", method.getName(), params.length, ex.getMessage());
}
```

##  Executor 설정
- 더이상 Thread를 생성하여 Task 수행이 안될 경우 발생
- 아래와 같은 설정 중 **RejectedExecutionHandler**에 대한 클래스 설정

> 	executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());


#### Excutor 설정 중 ThreadPoolExecutor 관련
- 아래 정책들 중 상황에 맞춰서 사용하면 됨.

###### ThreadPoolExecutor.AbortPolicy
- 기본 설정값
- Reject가 발생했을 때 `RejectedExecutionException` 가 발생한다.

- 테스트 소스

```java
public static void main(String[] args) {
	final int CORE_POOL_SIZE = 2; // 스레드풀을 사용할때 원하는 스레드의 개수
	final int MAXIMUM_POOL_SIZE = 2; //동시에 동작할 수 있는 스레드의 최대값
	final int KEEP_ALIVE_TIME = 60; //스레드의 유지시간
	final int QUEUE_SIZE = 1; //queue 사이즈, 테스트 목적으로 작게 설정

	final RejectedExecutionHandler rejectedExecutionHandler = new ThreadPoolExecutor.AbortPolicy();

	ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
		CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_TIME, TimeUnit.SECONDS, new LinkedBlockingQueue<>(QUEUE_SIZE), rejectedExecutionHandler
	);

	for (int i = 0; i < 4; i++) {

		try {
			threadPoolExecutor.execute(() -> System.out.println("Thread " + Thread.currentThread().getName()));
		} catch (RejectedExecutionException e) {
			System.out.println(e.getMessage());
		}
	}
}
```

- 결과

```
Thread pool-1-thread-1
Thread pool-1-thread-1
Task com.webtoon.velad.tasker.AsyncTest$$Lambda$1/1404928347@5d22bbb7 rejected from java.util.concurrent.ThreadPoolExecutor@41a4555e[Running, pool size = 2, active threads = 2, queued tasks = 1, completed tasks = 0]
Thread pool-1-thread-2
```

###### ThreadPoolExecutor.CallerRunsPolicy
- Reject된 Task를 실행 중인 main Thread에서 동작한다.

- 테스트 소스

```java
public static void main(String[] args) {
	final int CORE_POOL_SIZE = 2; // 스레드풀을 사용할때 원하는 스레드의 개수
	final int MAXIMUM_POOL_SIZE = 2; //동시에 동작할 수 있는 스레드의 최대값
	final int KEEP_ALIVE_TIME = 60; //스레드의 유지시간
	final int QUEUE_SIZE = 1; //queue 사이즈, 테스트 목적으로 작게 설정

	final RejectedExecutionHandler rejectedExecutionHandler = new ThreadPoolExecutor.CallerRunsPolicy();

	ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
		CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_TIME, TimeUnit.SECONDS, new LinkedBlockingQueue<>(QUEUE_SIZE), rejectedExecutionHandler
	);

	for (int i = 0; i < 4; i++) {

		try {
			threadPoolExecutor.execute(() -> System.out.println("Thread " + Thread.currentThread().getName()));
		} catch (RejectedExecutionException e) {
			System.out.println(e.getMessage());
		}
	}
}
```

- 결과

```
Thread main
Thread pool-1-thread-1
Thread pool-1-thread-2
Thread pool-1-thread-1
```
###### ThreadPoolExecutor.DiscardPolicy
- Reject된 Task에 대해서 어떠한 행위도 하지 않음.
- Exception도 발생하지 않는다.

- 테스트 소스

```java
public static void main(String[] args) {
	final int CORE_POOL_SIZE = 2; // 스레드풀을 사용할때 원하는 스레드의 개수
	final int MAXIMUM_POOL_SIZE = 2; //동시에 동작할 수 있는 스레드의 최대값
	final int KEEP_ALIVE_TIME = 60; //스레드의 유지시간
	final int QUEUE_SIZE = 1; //queue 사이즈, 테스트 목적으로 작게 설정

	final RejectedExecutionHandler rejectedExecutionHandler = new ThreadPoolExecutor.DiscardPolicy();

	ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
		CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_TIME, TimeUnit.SECONDS, new LinkedBlockingQueue<>(QUEUE_SIZE), rejectedExecutionHandler
	);

	for (int i = 0; i < 4; i++) {

		try {
			threadPoolExecutor.execute(() -> System.out.println("Thread " + Thread.currentThread().getName()));
		} catch (RejectedExecutionException e) {
			System.out.println(e.getMessage());
		}
	}
}
```

- 결과

```
Thread pool-1-thread-1
Thread pool-1-thread-1
Thread pool-1-thread-2
```

###### ThreadPoolExecutor.DiscardOldestPolicy
- 오래된 Thread를 제거하고 신규 task를 실행시킨다.
- DiscardPolicy와 마찬가지로 데이터가 유실될 수 있다.

- 테스트 소스

```java
public static void main(String[] args) {
	final int CORE_POOL_SIZE = 2; // 스레드풀을 사용할때 원하는 스레드의 개수
	final int MAXIMUM_POOL_SIZE = 2; //동시에 동작할 수 있는 스레드의 최대값
	final int KEEP_ALIVE_TIME = 60; //스레드의 유지시간
	final int QUEUE_SIZE = 1; //queue 사이즈, 테스트 목적으로 작게 설정

	final RejectedExecutionHandler rejectedExecutionHandler = new ThreadPoolExecutor.DiscardOldestPolicy();

	ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
		CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_TIME, TimeUnit.SECONDS, new LinkedBlockingQueue<>(QUEUE_SIZE), rejectedExecutionHandler
	);

	for (int i = 0; i < 4; i++) {

		try {
			threadPoolExecutor.execute(() -> System.out.println("Thread " + Thread.currentThread().getName()));
		} catch (RejectedExecutionException e) {
			System.out.println(e.getMessage());
		}
	}
}
```

- 결과

```
Thread pool-1-thread-1
Thread pool-1-thread-1
Thread pool-1-thread-2
```

