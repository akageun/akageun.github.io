---
layout: post
title:  "[Cassandra] Cassandra 란?"
date:   2019-07-02 09:00:00 +0900
categories:
 - database
tags: 
 - cassandra
---
![image](https://user-images.githubusercontent.com/13219787/59586546-29551900-911e-11e9-9eff-ff8961aeae1a.png)

# 1. Cassandra 란?
- facebook에서 개발, 현재는 Apache 프로젝트로 진행되고 있는 오픈소스
- 구글 BigTable 기반으로 개발됨
- key-value형으로 분류

## Cassandra 특징
- CQL(Cassnadra Query Language) : SQL과 비슷한 쿼리 인터페이스
    - CREATE TABLE , INSERT, SELECT 등 거의 유사함.
- 대량의 데이터를 다루는데 효과적이다.
    - 대량의 데이터를 여러 서버에 분산시킴
    - 분산된 데이터를 여러 서버에 복제하고, 그로 인해 읽기와 쓰기가 모두 뛰어나다.
- Master-Slave 와 같은 정책이 없이도 장애 대응 가능
- 필요에 따라 장비들을 늘리고 줄이는 데 큰 비용이 들지 않음

#### 단점
- Join이나 Transaction 지원하지않음
- 검색을 위한 기능도 별로 없음

## 데이터 모델
- `Cluster` -> `keyspace` -> `ColumnFamily` -> `Column` or `Super Column` -> `key-value`

#### Cluster
- 가장 바깥쪽 구조
- Ring 으로 불리기도함

#### keyspace
- RDB의 스키마
- 하나 이상의 coulmn family

#### column family
- column 들의 집합
- column과 row로 구성
- RDB의 Table과 비슷함(단, 테이블 내부 설계에 대한 것 등 차이가 있음)
- 메타데이터만 들고 있는 것과 같음
- 각 행(ROW)마다 다른 컬럼을 가지고 있을 수 있다.
- 각 Row 별로 유니크 key가 생성됨(RDB의 PK와 유사함), 이 값을 가지고 컬럼패밀리는 파티션되고, 기본적으로 인덱싱 되어 있다.

###### static(정적)
- 관계형 데이터베이스처럼 사전에 컬럼들을 정의하는 것
- 꼭 정의한 컬럼을 다 사용하지 않아도 됨

###### Dynamic(동적)
- 어플리케이션에 의해서 컬럼이 생성되는 방식
- 사전에 컬럼의 메타데이터를 생성하지 않음.

#### Column
- 데이터를 이루는 가장 작은 단위
- key-value를 가지며, 데이터 갱신 시각이 기록됨

## 관련 GUI 툴
- tableplus : windows, mac GUI client, [바로가기](https://tableplus.io/)
- cassandra-web : web site로 관리하기, [바로가기](https://github.com/avalanche123/cassandra-web)
