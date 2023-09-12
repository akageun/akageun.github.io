---
layout: post
title:  "[Cassandra] Primary Key"
date:   2022-04-04 09:00:00 +0900
categories:
- database
tags:
- cassandra
---
- Cassandra Table 설계시에 중요한 Primary Key 에 대해서 공부해보자.

## Primary Key 란?
- 한개(row)의 데이터가 유니크하게 보장해주는 Key 를 말하고 1개 이상 필요하다.
- Partition Key + Clustering Key 로 구성되어 있다.

- Basic

```sql
create table test_1 (
  key text PRIMARY KEY,
  data text      
);
```

- Composite Primary Key

```sql
 create table test_2 (
         t_partition_key text,
         t_clustering_key int,
         data text,
         PRIMARY KEY(t_partition_key, t_clustering_key)      
 );
```

## Partition Key 란?
- primary key 의 첫번째 key 를 의미함.
- 해시 알고리즘에 따라 클러스터에 분배되어 저장된다.
#### 단일 partition key

```sql
 create table test_2 (
         t_partition_key text,
         t_clustering_key int,
         data text,
         PRIMARY KEY(t_partition_key, t_clustering_key)      
 );
```
#### 복합 partition key

```sql
 create table test_2 (
         t_partition_key_1 text,
         t_partition_key_2 text,
         t_clustering_key int,
         data text,
         PRIMARY KEY((t_partition_key_1, t_partition_key_2), t_clustering_key)      
 );
```

## Clustering Key 란?
- Primary Key 에서 Partition Key 를 뺀 나머지 Key 를 말함.
- 지정한 순서대로 데이터가 저장 됨.

> with clustering order by (test_col_1 desc)

- 지정하지 않을 수도 있다. 기본값은 `ASC`