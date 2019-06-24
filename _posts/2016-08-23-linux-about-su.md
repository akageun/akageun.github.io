---
layout: post
title:  "su와 su - 의 차이점"
date:   2018-08-23 00:00:00 +0900
categories:
 - linux
tags: 
 - basic
---

# 1. su와 su - 의 차이
- ex) su - root
- ex) su root

- root로 로그인을 변경한다는 것은 동일하다

#### 그러나 

- "su" 만 사용할 경우 root 권한에 포함되어 있는 환경변수는 하나도 가져오지 않음. 
- 즉, 어떠한 환경변수도 포함하지 않고 단지 로그인 계정만 바꿈
- "su -"의 경우 환경변수까지 다 가져옵니다. 또한 su - root를 하면 기본 /root 디렉토리로 이동해 있을 것이다.

 

