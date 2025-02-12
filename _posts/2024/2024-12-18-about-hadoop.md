---
layout: post
title: "[Hadoop] Hadoop 맛보기"
date: 2024-12-18 09:00:00 +0900
categories:
- hadoop
tags:
- bigdata
- hadoop
- hadoop-ecosystem
---

- Hadoop 관련 작업을 진행하기전 대략적인 개념파악을 위해 정리한 내용 입니다.

### Hadoop 이란?
- Java 기반의 대용량 분산 시스템
- Hadoop Core : HDFS와 MapReduce, 2.0 이후부터는 Yarn 포함
  - hdfs 에 분산 저장하고, MapReduce 로 분산 처리를 함.
  - Yarn 은 리소스 매니징을 함.
- Hadoop 의 주요 Feature
  - Distributed : 분산처리된다.
  - Scalable : 확장 가능하다.
  - Fault-tolerant : 서버 한대 이상 고장나더라도 정상 동작함
- Master-Slave 구조(name node, data node)

### hdfs 란?
- Java 기반의 분산 확장 파일 시스템

### MapReduce
- 대용량 데이터를 분산처리하여 정렬된 데이터를 분산처리하고 이를 다시 합치는 작업을 거치는 작업을 해줌.

### Yarn
- 작업에 대한 스케쥴링, 클러스터의 리소스 관리를 위한 프레임워크
- 맵리듀스, hive, impala, spark 등 다양한 것들이 yarn 에서 작업을 실행함.

### Hive
- 하둡에 저장된 데이터를 쉽체 처리할 수 있게 해주는 Data Warehouse(DW) Package
- 복잡한 MapReduce 등을 SQL 과 유사한 HiveQL 로 처리
- catalog, metastore 를 제공
- Hive Client : https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients#HiveServer2Clients-JDBC

#### Metastore
- HDFS 의 저장 위치 등 메타 데이터를 저장하는 곳
  - Data abstraction, Data Discovery 를 제공
- SQL 질의 할 때 사용함.
- MySQL, PostgreSQL 등 이중화하여 관리함.

### Impala
- 대규모 병렬 처리 엔진
- 자체 분산 쿼리 엔진을 사용하기 때문에 응답 속도가 빠름.
- 구성요소
  - Impala Daemon, StateStore, Catalog Service

### trino
- 병렬처리 엔진 등..
- presto 가 바뀐거
- JDBC : https://trino.io/docs/current/client/jdbc.html

### HBase 란?
- Java 기반의 NoSql 분산 데이터 베이스
- HDFS 와 함께 사용됨.
- 내구성(durability)과 지속성(persistence)을 보장

#### 데이터를 쓰는과정
- HDFS 에 바로쓰지 않고, RegionServer 의 `MemStore` 라는 영역에 저장되고, Flush 할 때 HDFS 에 저장됨.
  - [이미지 출처](https://blog.cloudera.com/apache-hbase-write-path/)
    ![image](https://github.com/user-attachments/assets/d65d7cac-863c-4868-aecc-84a663d25da6)
- 장애 발생시 Memory 영역의 데이터가 유실 될 수 있으므로 WAL(Write-Ahead-Log)에 변경사항을 기록하고, 이후 사용 됨.
  - Mysql 의 Bin 로그와 유사함.
  - HBase WAL 은 HDFS 에 쓰여짐.

