---
layout: post
title:  "[다시보기 Mysql] 1. Mysql 공부하기 위한 준비"
date:   2022-06-25 09:00:00 +0900
categories:
- database
tags:
- mysql
---

## 왜 다시보기 시작했는가?

- 최근 몇년간 RDB 보다 NoSQL 를 더 많이 사용하다보니 Mysql 관련해서 기억이 잘 안나더라...
- Inner Join 과 Outer Join 쿼리를 작성하는데 생각보다 시간이 걸려서 충격이...
- 하나씩 다시 살펴보며 기록을 남긴다.

## 준비작업

- 어떤 내용들을 공부할지 나열해놓고 하나씩 짧게라도 채워가며 공부를 시작함.
- Docker 를 이용하여 버전별로 테스트 할 수 있도록 하거나, 되도록 최신 버전인 8버전 위주로 해보려고 한다.

#### Docker 준비

- docker-compose 로 준비
  - https://hub.docker.com/_/mysql

```yaml

version: "3.7"
services:
  db:
    image: mysql:8.0.12 # 사용할 이미지
    restart: always
    container_name: mysql-study 
    ports:
      - "3306:3306" 
    environment: 
      - MYSQL_DATABASE=test
      - MYSQL_ROOT_PASSWORD=1234  
      - TZ=Asia/Seoul

    command: 
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
    volumes:
      - /Users/Shared/data/mysql-stduy:/var/lib/mysql 

```

#### client 받기
- https://dev.mysql.com/downloads/workbench/
- mysql 버전이랑 맞춰서 받았다.

![image](https://user-images.githubusercontent.com/13219787/176699392-1e520da7-f35f-4bb5-abe3-7021a9bb620c.png)

- Store in Keychain

![image](https://user-images.githubusercontent.com/13219787/176699515-727ccad9-8d7b-4a6a-befb-8bb73b6f99b0.png)


#### 명령어 모음
- 시작

> docker-compose -f docker-compose.yml up -d

- 종료

> docker-compose down

- docker log 확인하기

> docker logs mysql-study

- bash 접근

> docker exec -it mysql-study bash

- mysql 접근

> mysql -uroot -p1234
