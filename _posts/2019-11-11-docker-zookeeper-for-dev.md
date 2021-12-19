---
layout: post
title:  "docker를 이용한 zookeeper 개발환경 구축하기"
date:   2019-11-11 09:00:00 +0900
categories:
 - docker
tags: 
 - docker
 - zookeeper 
 - docker-compose
---

- 이전에 kafka를 사용하기 위해 zookeeper를 띄워본적은 있으나, 본격적으로 zookeeper를 사용해보기 위해 docker를 사용하여 local 개발환경을 구성해봄.
- docker 및 docker-compose 가 설치되어 있어야함.([참고링크](https://akageun.github.io/2019/09/10/docker-compose-local-kafka.html))

## docker image 를 찾아보자.
> docker search zookeeper

![image](https://user-images.githubusercontent.com/13219787/68592430-6e675680-04d6-11ea-804b-2b8e31791ebe.png)

- 많다... 당황하지말고! `Official Image`를 사용하자!!
- https://hub.docker.com/_/zookeeper

## 작업할 디렉토리를 만들자!
> mkdir zk-test

- mac 이나 linux는 위 명령어를 사용하면 되고, 윈도우는 알아서 만들자ㅎㅎ

## docker-compose
- docker-compose.yml 생성 후 아래 내용을 입력하자.

```yaml
version: '3.1'
services:
  zookeeper:
    container_name: local-zookeeper
    image: zookeeper
    ports:
      - "2181:2181"
```

> docker-compose -f docker-compse.yml up -d

- 위 명령어를 통해 실행시킴.

> docker ps 

- 실행 확인

## 사용하기 편하게 web-console 도 설치하자!
```yaml
version: '3.1'
services:
  zookeeper:
    container_name: local-zookeeper
    image: zookeeper
    ports:
      - "2181:2181"
  zk-web:
    container_name: local-zk-web
    image: goodguide/zk-web
    ports:
      - "8080:8080"
    environment:
      - ZKWEB_PORT=8080 #Web port
      - ZKWEB_CREDENTIALS=admin:hello #Admin 계정:비밀번호
```

- localhost:8080 로 접속하면 zk-web 을 이용할 수 있음.

> docker inspect ${container Id}

- NetworkSettings -> Networks -> Gateway ip 를 가지고옴.

![image](https://user-images.githubusercontent.com/13219787/68593115-1598bd80-04d8-11ea-90b6-c3285d2f51de.png)

- 해당 아이피:2181 로 접속하면 znode 를 볼 수 있음.
- `login` 버튼을 클릭하여 위 admin 계정으로 접속하면 `생성`, `수정`, `삭제`를 할 수 있음.

## Cluster 를 구성해보자!
- 아래와 같이 설정할 경우 cluster 를 손쉽게 구성 할 수 있다.

```yaml
version: '3.1'

services:
  zoo1:
    image: zookeeper
    restart: always
    hostname: zoo1
    ports:
      - 2181:2181
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181

  zoo2:
    image: zookeeper
    restart: always
    hostname: zoo2
    ports:
      - 2182:2181
    environment:
      ZOO_MY_ID: 2
      ZOO_SERVERS: server.1=zoo1:2888:3888;2181 server.2=0.0.0.0:2888:3888;2181 server.3=zoo3:2888:3888;2181

  zoo3:
    image: zookeeper
    restart: always
    hostname: zoo3
    ports:
      - 2183:2181
    environment:
      ZOO_MY_ID: 3
      ZOO_SERVERS: server.1=zoo1:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=0.0.0.0:2888:3888;2181

  zk-web:
    container_name: local-zk-web
    image: goodguide/zk-web
    ports:
      - "8080:8080"
    environment:
      - ZKWEB_PORT=8080
      - ZKWEB_CREDENTIALS=admin:hello
```

---
## 참고링
- https://hub.docker.com/_/zookeeper
- https://hub.docker.com/r/goodguide/zk-web/
