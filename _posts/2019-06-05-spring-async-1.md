---
layout: post
title:  "[Spring Async] 1. 비동기 처리를 해보자."
date:   2019-06-05 00:00:00 +0900
---

- Spring에서 제공해주는 @Async Annotation을 사용하여 비동기처리를 한다.
- 비동기로 실행하고, 결과값을 받아보자.
- 비동기로 처리 중에 발생되는 문제(Exception)를 잡아서 처리하자.
- [비동기 전송 방식이란?](https://ko.wikipedia.org/wiki/%EB%B9%84%EB%8F%99%EA%B8%B0_%EC%A0%84%EC%86%A1_%EB%B0%A9%EC%8B%9D)

# @Async?
- https://spring.io/guides/gs/async-method/

## 기본 사용법
```java
@Async
public void run() {
}
```

## 제약사항
- 리턴값은 void와 java.util.concurrent.Future<V>만 사용가능하다.
- public 메소드만 사용 가능하다.
- 스스로를 호출하여 동작시킬 수 없다.(self-invocation)



#### 리턴값이 정해져 있다.

###### void

###### java.util.concurrent.Future<V>

#### 스스로를 호출하여 동작시킬 수 없다.

#### 같은 클래스에서 

# 설정하기
- Spring Boot 기준으로 설명할 예정.

## Dependency
> `spring-context` 가 포함되어 있으면 됩니다.

## Spring Configuration
- annotation : `@EnableAsync`
- 기본으로 설정되어 있는 `TaskExecutor`는 `SimpleAsyncTaskExecutor `로 매번 Thread를 생성하여 Thread Pool이 아니다. 

#### 기본 설정 구조

```java
@EnableAsync
@Configuration
public class AsyncConfiguration implements AsyncConfigurer {

}
```

#### 공통된 Thread Pool을 사용하는 방법
- `AsyncConfigurer` 를 implements 하여 `getAsyncExecutor` method를 override 한다.

```java
@Configuration
@EnableAsync
public class AsyncConfiguration implements AsyncConfigurer {

	@Override
	public Executor getAsyncExecutor() {
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setThreadNamePrefix("async-thread-");
		executor.setCorePoolSize(10);
		executor.setMaxPoolSize(50);
		executor.setQueueCapacity(100);
                executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy()); //추후 설명
		executor.initialize();
		return executor;
	}
}
```

- 호출하는 법

```java
@Async
public void taskExecutor() {
    log.info("thread run");
}
```

#### 각각 다른 Thread Pool을 사용하는 방법

- 사용할 각각의 TaskExecutor를 생성한다.

```java 
@Bean("taskExecutor_1")
public Executor taskExecutor_1() {
	ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
	executor.setThreadNamePrefix("each-async-thread-1-");
	executor.setCorePoolSize(10); 
	executor.setMaxPoolSize(50); 
	executor.setQueueCapacity(100); 
	executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
	return executor;
}

@Bean("taskExecutor_2")
public Executor taskExecutor_2() {
	ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
	executor.setThreadNamePrefix("each-async-thread-2-");
	executor.setCorePoolSize(10); 
	executor.setMaxPoolSize(50); 
	executor.setQueueCapacity(100);
	executor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
	return executor;
}
```

- 호출하는 법

```java
@Async("taskExecutor_1")
public void taskExecutor1() {
    log.info("thread 1 run");
}

@Async("taskExecutor_2")
public void taskExecutor2() {
    log.info("thread 2 run");
}
```

#### Excutor 설정 중 ThreadPoolExecutor 관련
###### ThreadPoolExecutor.AbortPolicy
- A handler for rejected tasks that throws a RejectedExecutionException

###### ThreadPoolExecutor.CallerRunsPolicy
- A handler for rejected tasks that runs the rejected task directly in the calling thread of the execute method, unless the executor has been shut down, in which case the task is discarded.

###### ThreadPoolExecutor.DiscardPolicy
- A handler for rejected tasks that silently discards the rejected task.

###### ThreadPoolExecutor.DiscardOldestPolicy
- A handler for rejected tasks that discards the oldest unhandled request and then retries execute, unless the executor is shut down, in which case the task is discarded.
