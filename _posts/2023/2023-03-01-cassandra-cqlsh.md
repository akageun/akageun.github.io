---
layout: post
title:  "Cassandra CQLSH 사용하기"
date:   2023-03-01 09:00:00 +0900
categories:
- database
tags:
- cassandra
---

- 카산드라 설치한 곳에서 아래와 같이 사용 가능함.

``` ./bin/cqlsh ```

## 아이디와 비밀번호를 설정햇을 경우
- https://docs.datastax.com/en/cql-oss/3.3/cql/cql_reference/cqlsh.html

``` ./bin/cqlsh -u {userId} -p {password} ```

## 일관성 레벨 확인 및 변경하기
- https://docs.datastax.com/en/cql-oss/3.3/cql/cql_reference/cqlshSerialConsistency.html

``` test@cqlsh> CONSISTENCY ```

> Current consistency level is ONE

``` test@cqlsh> CONSISTENCY QUORUM; ```

> Consistency level set to QUORUM.


