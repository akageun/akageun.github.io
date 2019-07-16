---
layout: post
title:  "Docker Stop 손쉽게 사용하기"
date:   2019-07-12 09:00:00 +0900
categories:
 - docker
tags: 
 - docker
---

# Docker Stop 손쉽게 사용하기
- shell script 등으로 docker 를 켜고 끄고를 만들 경우 docker stop 이라는 기능을 사용해야한다.
- `docker stop ${container id}` 
- 위 방식이 아닌 name을 사용하는 방법

## docker run 할 때 이름 지정하기
> docker run --name {지정하고 싶은 이름}

#### 예시
> docker run --name test-container

## docker stop {name}
> docker stop test-container

