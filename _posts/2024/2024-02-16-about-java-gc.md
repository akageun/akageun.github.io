---
layout: post
title:  "Java GC 에 대해서"
date:   2024-02-16 09:00:00 +0900
categories:
- java
tags:
- garbage-collection

---

- Garbage(`유효하지 않음 메모리`) 를 정리해주는 것을 `Garbage Collection` 이라고 한다.
- 처리 방식이나 기타 사항들은 언급하지 않고 종류에 대해서만 정리할 예정이다.

## Serial GC
- Single Thread
- Stop the world 가 느림.
- Mark & Sweep & Compact 알고리즘
- 서버가 CPU Core 가 1인 경우 사용할 수 있다.

> java -XX:+UseSerialGC -jar App.java

## Parallel GC
- JDK 8 의 Default GC
- `Serial GC` 와 기본적인 알고리즘은 같지만, Young 영역 Minor GC 는 Mutli Thread 수행(Old 영역은 Single Thread)
- Stop the world 는 `Serial GC` 보다 짧다.

> java -XX:+UseParallelGC -jar App.java

## Parallel Old GC (Parallel Compacting GC)
- `Parallel GC 의 Old 영역에 대해서도 Multi Thread 적용 방식
-  JDK 5 update 6 부터 제공

> java -XX:+UseParallelOldGC -jar App.java

## CMS GC (Concurrent Mark Sweep)
- Application Thread 와 Gc Thread 가 동시 실행, Stop th world 시간을 줄이기 위한 GC
- JDK 9 에서 deprecated 되었고, JDK 14 에서 사용 중지
- 단점으로는 CPU 를 다른 GC 에 비해서 많이 사용하고, Compaction 단계를 기본적으로 제공하지 않음.

> java -XX:+UseConcMarkSweepGC -jar App.java

## G1 GC (Garbage First)
- CMS GC 를 대체하기 위해 JDK 7부터 적용
- JDK 9+ 부터 Default GC 로 지정됨.
- Young/Old 영역이 아닌 `Region` 이라는 개념을 도입하여 사용
  - 영역을 분할하여 `Eden`, `Survivor`, `Old` 등의 역할을 동적으로 부여
- Garbage 로 찬 `Region`을 처리하여 공간 확보하는 원리
  - `Region`은 `Heap 메모리 설정 / 2048` 로 지정됨.

> java -XX:+UseG1GC -jar App.java

## ZGC (Z Garbage Collector)
- JDK 15에 추가됨.
- 대량의 메모리(8MB ~ 16TB)에서 잘 처리 될 수 있도록 설계된 GC
- G1 의 `Region`처럼 `ZPage` 라는 영역을 사용, `ZPage`는 2mb 배수로 동적 할당
- 힙 크기가 증가하더라도 stop the world 가 10ms 를 넘지 않음.

> java -XX:+UseZGC -jar App.java
