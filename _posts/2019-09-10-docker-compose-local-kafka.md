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
      KAFKA_CREATE_TOPICS: "test_topic:1:1" # Topic명:Partition개수:Replica개수
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

###### 실행
> docker-compose -f docker-compose.yml up -d

###### 종료

> docker-compose down

or

> docker-compose stop


## docker!!
#### 각 컨테이너 log 보기
- 각 설정값에 `image` 값을 logs 뒤에 넣어주면 된다.

###### zookeeper

> docker container logs local-zookeeper

###### kafka

> docker container logs local-kafka

#### 컨테이너 접속해보기

> docker exec -i -t local-kafka bash

###### 컨테이너 내부 topic log 보기 

> cd ./kafka/kafka-logs-**/test_topic-**

## Kafka 로 접근해보기!!
- 공식사이트에서 위 docker-kafka 버전과 같은 kafka를 다운 받는다.
    - 스칼라 : 2.12, 카프카 : 2.3.0 
    - https://kafka.apache.org/downloads


#### 설치
```
wget https://www.apache.org/dyn/closer.cgi?path=/kafka/2.3.0/kafka_2.12-2.3.0.tgz
tar xzvf kafka_2.12-2.3.0.tgz
cd kafka_2.12-2.3.0
```


#### topic 
- 옵션
    - `--zookeeper` : zookeeper가 실행 중인 호스트
    - `--list` : 리스트
    - `--create` : topic 생성
    - `--topic` : topic 명
    - `--partitions` :  topic 파티션 수
    - `--replication-factor` : topic 복사본 수

###### 생성
> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic tmp_topic

- 위 명령어를 실행하면 topic 명 때문에 warning 이 발생한다.

> WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.

- `tmp_topic` 을 `tmp-topic` 으로 바꿔서 만들자!

###### 확인
> bin/kafka-topics.sh --zookeeper localhost:2181 --list

#### consumer

> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic tmp-topic --from-beginning

- 위 명령어를 입력하고 새창을 하나 더 띄우자!

#### producer

> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic tmp-topic

- 무언가를 `producer`에서 입력하게 되면 `consumer`에 나오게 된다. 

## 추가
#### 컨테이너 정지 및 제거

> docker-compose -f docker-compose.yml stop && docker-compose -f docker-compose.yml rm -vf

---
## 참고링크
- https://github.com/Yelp/docker-compose
- http://www.kwangsiklee.com/2017/03/docker-compose%EB%A1%9C-kafka%EB%A5%BC-%EB%A1%9C%EC%BB%AC%EC%97%90-%EB%9D%84%EC%9B%8C%EB%B3%B4%EC%9E%90/
- https://blog.naver.com/PostView.nhn?blogId=occidere&logNo=221390946271&categoryNo=0&parentCategoryNo=0&viewDate=&currentPage=1&postListTopCurrentPage=1&from=postView
