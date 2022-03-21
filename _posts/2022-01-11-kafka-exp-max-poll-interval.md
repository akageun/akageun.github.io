---
layout: post
title:  "[Kafka 경험기] 무한 컨슘 및 재처리 기능 추가시 고려할 부분"
date:   2022-01-11 09:00:00 +0900
categories:
- kafka
tags:
- kafka
- spring kafka
- experience
---

## 무한 컨슘 및 재처리 기능 추가시 고려할 부분
- 계속해서 컨슘 발생
- 컨슈머에서 max.poll.interval.ms 가 지나도  poll() 이 발생하지 않을 경우, 해당 consumer 에 문제가 생긴걸로 판단하여 리밸런싱이 일어남.
  - 커밋전에 리밸런싱이 일어나면서 다른 곳에서 또다시 컨슘됨...
- 관련 설정값
  - [max.poll.interval.ms](https://docs.confluent.io/platform/current/installation/configuration/consumer-configs.html#consumerconfigs_max.poll.interval.ms) : 컨슈머 poll() 대기시간, 해당시간동안 poll() 이 일어나지 않을 경우 리밸런싱이 일어남. , 기본값 5분
  - [max.poll.records](https://docs.confluent.io/platform/current/installation/configuration/consumer-configs.html#consumerconfigs_max.poll.records) : poll() 시에 읽어올 최대 record 수, 기본값 500개
        - 처리해야할 데이터 수가 많아지면 처리 시간이 늘어날 수 있으므로...
### 예시
- `max.poll.interval.ms` 값이 3초로 되어 있고, 1개의 record 를 처리하는데 5초가 걸리는 상황...

> consumerConfigs.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 3000);

```
- 컨슘 시작: 00:00:23
- 리밸런싱 : 00:00:26 (This member will leave the group because consumer poll timeout has expired.)
- 컨슘 종료 : 00:00:28

- 컨슘 시작: 00:00:29
- 리밸런싱 : 00:00:32 (This member will leave the group because consumer poll timeout has expired.)
- 컨슘 종료 : 00:00:34 

.... 끝나지 않....
```

### 그럼 어떻게 대응할 수 있을까?
- `max.poll.records` 만큼 가져왔을 때, 처리시간이 `max.poll.interval.ms` 값보다 작아야 합니다.
  - `max.poll.records` 를 작게 잡는 등 하는걸 추천 합니다.

### Spring-Kafka 에서 `RetryTemplate` 을 사용할 경우!
- 재처리를 위해서 해당 기능을 사용할 경우 위의 무한컨슘을 조심해야한다.
- 사용할 경우 잘 계산해서 설정값을 세팅해야함.
  - 1 record 처리시간 * 재처리 수 + BackOff 시간 * (재처리 수 - 1) < `max.poll.interval.ms`

#### 예시)
- `max.poll.interval.ms` 값이 3초로 되어 있고, 1개의 record 를 처리하는데 1초가 걸리는 상황...
  - 재시도는 3회로 설정하고 `BackOff` 를 1초로 설정

```
- (1) 컨슘 시작: 00:00:12
- (1) 컨슘 종료 : 00:00:13
- (1) 에러발생!
- (1) BackOff....
- (1) 컨슘 시작: 00:00:14
- (1) 리밸런싱 : 00:00:15 (This member will leave the group because consumer poll timeout has expired.)
- (1) 컨슘 종료 : 00:00:15 
- (1) 에러발생!
- (1) BackOff....
- (1) 컨슘 시작: 00:00:16
- (1) 컨슘 종료 : 00:00:17
- (1) 에러발생!
- (1) RecoveryCallback 호출...
- (2) 컨슘 시작: 00:00:19
- (2) 컨슘 종료 : 00:00:20

... 끝나지 않음.
```

- retryTemplate 샘플소스

```java
RetryTemplate retryTemplate = new RetryTemplate();

FixedBackOffPolicy fixedBackOffPolicy = new FixedBackOffPolicy();
fixedBackOffPolicy.setBackOffPeriod(1000L); //1초 후 재시도

retryTemplate.setBackOffPolicy(fixedBackOffPolicy);

Map<Class<? extends Throwable>, Boolean> exceptionMap = new HashMap<>();

exceptionMap.put(RuntimeException.class, true);
exceptionMap.put(IllegalArgumentException.class, false); //해당 exception 은 재처리 안함.

retryTemplate.setRetryPolicy(new SimpleRetryPolicy(3, exceptionMap, true));

return retryTemplate;
```