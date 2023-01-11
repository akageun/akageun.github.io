---
layout: post
title: "[Kotlin 경험기] Intelli J 에서 Kotlin Doc 자동완성"
date: 2023-01-01 09:00:00 +0900
categories:
- kotlin
tags:
- kotlin
---

- Intelli J 에서 Kotlin 을 사용 하면서 경험한 내용을 정리한 글 입니다.

## 주석 자동완성
- Java 에서 아래와 같이 method 명 위에 `Add JavaDoc` 을 통하여 주석을 자동 완성 할 수 있다.

![image](https://user-images.githubusercontent.com/13219787/211565833-7b6e106b-0868-40ab-be01-8fc3e2a6ebcd.png)

- 허나 기본적인 Kotlin 세팅에서는 아래와 같이 나온다.

![image](https://user-images.githubusercontent.com/13219787/211568600-5cc68828-7e7c-4f28-a05b-65b5bde8e79f.png)

- 플러그인 설치를 통해 불편함을 해소할 수 있다.

> BugKotlinDocument By Bin

![image](https://user-images.githubusercontent.com/13219787/211569082-2e861945-7ab4-4582-810e-6d6464904653.png)

```
/** 그리고 enter 를 통해서 자동완성 할 수 있다.

```