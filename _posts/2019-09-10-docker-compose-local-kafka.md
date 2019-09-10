---
layout: post
title:  "docker-compose 를 사용하여 kafka 개발환경 구축해보기!"
date:   2019-09-10 09:00:00 +0900
categories:
 - docker
tags: 
 - kafka
 - zookeeper
 - docker-compose
---

- 로컬 개발환경에서 사용할 목적으로 `kafka`를 `docker`로 설치하려고 한다.
- `kafka`는 `zookeeper` 를 같이 사용해줘야해서 `docker-compose`를 사용해야한다.

- docker는 이미 설치되어 있어야함.

## docker-compose 설치
- 글 작성 시기의 버전으로 만들어 놓은 명령어(version : `1.24.1`)

```
curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

#### 설치확인
- 아래 명령어를 입력하여, version 을 확인할 수 있으면 설치가 된 것!
> docker-compose -v

- install 관린 글

> https://github.com/Yelp/docker-compose/blob/master/docs/install.md  

## docker-compose.yml 작성

#### zookeeper
- 로컬 환경이므로 1대만 구성! (운영 환경이라면 고민이 필요 합니다.)

```yaml
version: '2'
services:
  zookeeper:
    container_name: local-zookeeper
    image: wurstmeister/zookeeper:3.4.6
    ports:
      - "2181:2181"
```

#### kafka
- https://github.com/wurstmeister/kafka-docker

```yaml
version: '2'
services:
  kafka:
    container_name: local-kafka
    image: wurstmeister/kafka:2.12-2.3.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 127.0.0.1
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_CREATE_TOPICS: "test:1:1" # Topic명:Partition개수:Replica개수
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

###### environment!
- `KAFKA_CREATE_TOPICS` : 생성할 topic 정보(Topic명:Partition개수:Replica개수)
- `KAFKA_ZOOKEEPER_CONNECT` : Zookeeper 정보
- `KAFKA_ADVERTISED_HOST_NAME`: 호스트
- `KAFKA_ADVERTISED_PORT` : 포트 번호

#### 두개를 합친 docker-compose.yml 

```yaml
version: '2'
services:
  zookeeper:
    container_name: local-zookeeper
    image: wurstmeister/zookeeper:3.4.6
    ports:
      - "2181:2181"
  kafka:
    container_name: local-kafka
    image: wurstmeister/kafka:2.12-2.3.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 127.0.0.1
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_CREATE_TOPICS: "test:1:1" # Topic명:Partition개수:Replica개수
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
## docker 내부 접속해보기

## 접속해서 확인해보기!!


