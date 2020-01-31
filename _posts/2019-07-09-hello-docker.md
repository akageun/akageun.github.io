---
layout: post
title:  "docker 명령어 실행해보기"
date:   2019-07-09 09:00:00 +0900
categories:
 - docker
tags: 
 - docker
---
# Docker 명령어 실행해보기
## 명령어 구조
> docker {command}

## 버전 확인
> docker version 

- 간단버전

> docker -v

## search
- 컨테이너 검색할 때 도움이 됨.

> docker search {image name}

#### 예시
> docker search centos
![image](https://user-images.githubusercontent.com/13219787/60896711-c03a6e80-a2a1-11e9-9bbf-1e48ccb59857.png)

## image 받아오기(pull)
> docker pull {image name}:{version}

#### 예시
> docker pull centos

## 받아온 이미지 목록 보기
> docker images

## docker run
- 위에 pull 받은 centos를 실행 시킬 수 있음.

옵션 | 설명
-- | --
-i | 인터렉티브 모드
-t | tty 모드

#### 예시

> docker run -i -t centos /bin/bash

- 아래와 같이 리눅스 명령어를 실행 할 수 있음.

> [root@ea41d37bc2c6 /]#  ls -al

옵션 | 설명
-- | --
-i | 인터렉티브 모드
-t | tty 모드

## 현재 실행중인 docker 프로세스 확인

> docker ps

#### 옵션
옵션 | 설명 | 예시
--|--|--
-a | 종료된 컨테이너도 전부 나옴 | > docker ps -a

## 종료된 컨테이너 재실행
- container id 는 조금 전 위에서 사용한 `docker ps` 를 통해 확인 할 수 있습니다.

> docker restart {container id}

- 컨테이너 안으로 다시 들어가기 위해서는 `attach` 명령어를 사용해야함.

## 에러발생?
- 에러메시지가 발생했을 경우는 docker 설치가 잘 못되었거나, `sudo`를 입력하지 않아서다.

> Error response from daemon: Bad response from Docker engine

