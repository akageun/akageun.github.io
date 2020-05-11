---
layout: post
title:  "docker-compose 를 사용하여 kafka Cluster 및 Kafka Manger 세팅하기"
date:   2020-05-01 09:00:00 +0900
categories:
 - docker
tags: 
 - kafka
 - zookeeper
 - docker-compose
---

- 로컬환경에서 간단하게 테스트할 목적으로 Single Broker 로 세팅할 경우 [링크](/2019/09/10/docker-compose-local-kafka.html) 를 확인해보자.
- 카프카 클러스터 관련해서 테스트 등을 진행하려고 Cluster 환경을 간단하게 구성하고,
- Kafka Manager를 추가하여, 손 쉽게 모니터링 할 수 있도록 구성했다.

## 세팅
- `zookeeper` 한대에 `broker` 3개로 세팅
- `kafka-manager` 는 한대만 띄울 예정
- `JMX` 세팅도 추가하여, Manger에서 모니터링 할 수 있도록 추가

## docker-compose.yml
#### zookeeper
```yaml
version: '3.6'
services:
    zookeeper:
        container_name: zookeeper
        image: wurstmeister/zookeeper:3.4.6
        volumes:
            - "./zookeeper/data:/data"
            - "./zookeeper/logs:/datalog"
        ports:
            - "2181:2181"
```

#### broker
- 총 3대의 브로커를 세팅할 예정
- 아래 `kafka1` 과 `KAFKA_ADVERTISED_PORT`를 맞춰서 3개를 추가하면된다.

```yaml
version: '3.6'
services:
    kafka1:
        container_name: kafka1
        image: wurstmeister/kafka:2.12-2.3.0
        restart: on-failure
        ports:
            - "9095:9092"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
            JMX_PORT: 9093
            KAFKA_ADVERTISED_HOST_NAME: ${EXPOSED_HOSTNAME}
            KAFKA_ADVERTISED_PORT: 9095
            KAFKA_JMX_OPTS: -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=${EXPOSED_HOSTNAME} -Dcom.sun.management.jmxremote.rmi.port=9093
        depends_on:
            - zookeeper
```

#### kafka-manager
- 야후에서 오픈소스로 공개한 https://github.com/yahoo/CMAK 를 사용할 예정
- docker repo로는 `https://github.com/hleb-albau/kafka-manager-docker` 를 사용할 예정,
    - 오픈소스로 공개한 버전들 대부분이 올라가 있다.
        
```yaml
version: '3.6'
services:
  kafka_manager:
    image: hlebalbau/kafka-manager:stable
    ports:
      - "9000:9000"
    environment:
      ZK_HOSTS: "zookeeper:2181"
      APPLICATION_SECRET: "random-secret"
```

- `ZK_HOSTS` 의 경우 위 zookeeper 설정에 따라 변경하면 된다.
- `APPLICATION_SECRET` 값도 필요할 경우 알아서 변경하면 된다.

- 실행 후 `localhost:9000` 으로 접속하면 된다.
    - cluster 등록시에 zookeeper를 한대만 세팅 했기 때문에 `zookeeper:2181` 넣어서 저장하면 해당 브로커들을 볼 수 있다.
    


## 전체 소스
-  `${EXPOSED_HOSTNAME}` 의 경우 IP를 넣어주면 된다.

```yaml
#https://gist.github.com/dkurzaj/2a899de8cb5ae698919f0a9bbf7685f0

version: '3.6'

services:
    zookeeper:
        container_name: zookeeper
        image: wurstmeister/zookeeper:3.4.6
        volumes:
            - "./zookeeper/data:/data"
            - "./zookeeper/logs:/datalog"
        ports:
            - "2181:2181"

    kafka1:
        container_name: kafka1
        image: wurstmeister/kafka:2.12-2.3.0
        restart: on-failure
        ports:
            - "9095:9092"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
            JMX_PORT: 9093
            KAFKA_ADVERTISED_HOST_NAME: ${EXPOSED_HOSTNAME}
            KAFKA_ADVERTISED_PORT: 9095
            KAFKA_JMX_OPTS: -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=${EXPOSED_HOSTNAME} -Dcom.sun.management.jmxremote.rmi.port=9093
        depends_on:
            - zookeeper
    kafka2:
        container_name: kafka2
        image: wurstmeister/kafka:2.12-2.3.0
        restart: on-failure
        ports:
            - "9096:9092"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
            JMX_PORT: 9093
            KAFKA_ADVERTISED_HOST_NAME: ${EXPOSED_HOSTNAME}
            KAFKA_ADVERTISED_PORT: 9096
            KAFKA_JMX_OPTS: -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=${EXPOSED_HOSTNAME} -Dcom.sun.management.jmxremote.rmi.port=9093
        depends_on:
            - zookeeper
    kafka3:
        container_name: kafka3
        image: wurstmeister/kafka:2.12-2.3.0
        restart: on-failure
        ports:
            - "9097:9092"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
        environment:
            KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
            JMX_PORT: 9093
            KAFKA_ADVERTISED_HOST_NAME: ${EXPOSED_HOSTNAME}
            KAFKA_ADVERTISED_PORT: 9097
            KAFKA_JMX_OPTS: -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=${EXPOSED_HOSTNAME} -Dcom.sun.management.jmxremote.rmi.port=9093
        depends_on:
            - zookeeper

    # https://github.com/hleb-albau/kafka-manager-docker
    kafka-manager:
        container_name: kafka-manager
        image: hlebalbau/kafka-manager:2.0.0.2
        restart: on-failure
        depends_on:
            - kafka1
            - kafka2
            - kafka3
            - zookeeper
        environment:
            ZK_HOSTS: zookeeper:2181
            APPLICATION_SECRET: "random-secret"
            KM_ARGS: -Djava.net.preferIPv4Stack=true
        ports:
            - "9000:9000"

```
