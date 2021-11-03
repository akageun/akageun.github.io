---
layout: post
title:  "docker-compose를 이용한 Local 개발용 ELK 세팅하기"
date:   2020-09-15 09:00:00 +0900
categories:
- docker
  tags:
- docker
- elasticsearch
- kibana
- logstash
---
- 로컬에서 개발환경을 구축할 경우에 사용할 수 있도록 docker-compose를 사용하여, `elasticsearch`와 `kibana`를 세팅할 예정
- n대를 띄우지 않고 싱글노드로도 충분히 테스트 할 수 있으므로, 한대를 띄우는 내용으로 작성함.


## 잘 되어있는 yml 받기
```
git clone https://github.com/deviantony/docker-elk.git
```

## config 수정
- `docker-elk` path로 이동필요
> cd docker-elk
- xpack 관련된 내용은 주석처리 필요

#### elasticsearch
- es config 파일 수정하기.
> vi ./elasticsearch/config/elasticsearch.yml
```
## Default Elasticsearch configuration from Elasticsearch base image.
## https://github.com/elastic/elasticsearch/blob/master/distribution/docker/src/docker/config/elasticsearch.yml
cluster.name: "docker-cluster"
network.host: 0.0.0.0
## X-Pack settings(주석처리)
## see https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-xpack.html
#
#xpack.license.self_generated.type: trial
#xpack.security.enabled: true
#xpack.monitoring.collection.enabled: true
```

- 안쓰는 비밀번호 제거하기
> vi ./docker-compose.yml
```
## 제거
ELASTIC_PASSWORD: changeme
```

#### logstash
> vi ./logstash/config/logstash.yml
```
http.host: "0.0.0.0"
#xpack.monitoring.elasticsearch.hosts: [ "http://elasticsearch:9200" ]
## X-Pack security credentials
#
#xpack.monitoring.enabled: true
#xpack.monitoring.elasticsearch.username: elastic
#xpack.monitoring.elasticsearch.password: changeme
```

#### kibana
> vi ./kibana/config/kibana.yml
```
server.name: kibana
server.host: "0.0.0.0"
elasticsearch.hosts: [ "http://elasticsearch:9200" ]
#monitoring.ui.container.elasticsearch.enabled: true
## X-Pack security credentials
# 필요할 경우 세팅해서 사용
#elasticsearch.username: elastic
#elasticsearch.password: elastic
```

#### version 변경하는 법
> vi .env
```
ELK_VERSION=7.9.1
```

## 실행
> docker-compose up -d
## 확인
- Elasticsearch : 9200 / 9300
- Kibana : 5601

#### elasticsearch
> curl -XGET 'http://localhost:9200/_cluster/health'
#### kibana
- 브라우저에서 `http://localhost:5601/` 를 호출해본다.

## 종료하기
> docker-compose down
