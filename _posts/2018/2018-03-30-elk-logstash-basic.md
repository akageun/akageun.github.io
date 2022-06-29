---
layout: post
title:  "[LOGSTASH] 01. Logstash 설치 및 기본 설명"
date:   2018-03-30 09:00:00 +0900
categories:
 - elastic
tags: 
 - logstash
---
# 1. Logstash란?
- 입력(input), 필터(filter), 출력(output) 3단계로 구성되어 있고, 다양한 플러그인이 있어 여러 상황에서 사용하기 편함.
- ex) 로그수집 등

# 2. Logstash 설치
## 1) Centos 7기준

#### (1) java 설치 여부 확인
> java -version

- 아래와 같이 나오면 설치되어 있는 것이고, 아닐 경우 jdk 설치를 먼저 진행하세요.

```
java version "1.8.0_151"
Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)
```

#### (2) Logstash 다운로드
- wget으로 받아야하므로, wget 설치 필요

> wget 'https://artifacts.elastic.co/downloads/logstash/logstash-6.2.0.tar.gz'

- 압축풀기

> tar -xvf ./logstash-6.2.0.tar.gz

- 링크설정

> ln -s logstash-6.2.0 logstash

- 다운받은 tar.gz 파일 삭제

> rm -rf ./logstash-6.2.0.tar.gz

- 확인

> logstash -e ‘input { stdin { } } output { stdout {} }’

# 3. Logstash 설정
- aws ec2를 프리티어로 사용할 경우나, 메모리가 부족할 경우에만 설정하세요.

## 1) JVM 메모리 설정

> vi ~/logstash/config/jvm.options

##  2) config 수정
```
-Xms128m
-Xmx128m
```

# 4. 플러그인 
## 1) 플러그인 리스트 확인
```
bin/logstash-plugin list
bin/logstash-plugin list --group input 
```

## 2) 플러그인 설치

> bin/logstash-plugin install #{플러그인명}



## 3) 플러그인 업데이트
```
bin/logstash-plugin update 
bin/logstash-plugin update #{플러그인명}
```

## 4) 전체플러그인 목록
- (1) INPUT : [바로가기](https://www.elastic.co/guide/en/logstash/current/input-plugins.html)
- (2) FILTER : [바로가기](https://www.elastic.co/guide/en/logstash/current/filter-plugins.html)
- (3) OUTPUT : [바로가기](https://www.elastic.co/guide/en/logstash/current/output-plugins.html)

---
## 참고페이지
- https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html
- https://www.elastic.co/guide/en/logstash/current/installing-logstash.html
