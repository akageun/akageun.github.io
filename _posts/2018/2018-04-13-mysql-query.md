---
layout: post
title:  "[Mysql] 기억하면 좋은 쿼리 모음"
date:   2018-04-13 09:00:00 +0900
categories:
 - database
tags: 
 - mysql
---

## 1. 최대 접속자 수
> show variables like '%max_connect%';

## 2. 현재 접속자 수
> show global status like 'threads_connected';

## 3. 현재 존재하는 데이터베이스 목록
> show databases;

## 4. 특정 데이타베이스를 사용
> use {databases_name};

## 5. 현재 사용중인 데이터베이스 테이블 목록
> show tables;

## 6. 테이블 생성 쿼리 보기
> show create table {table_name};

## 7. 테이블 컬럼 목록 보기
> select column_name from information_schema.columns where table_name = '{table_name}' and table_schema='{database_name}'

## 8. 테이블 index 목록 보기
>show index from {table_name}

## 9. 현재 사용중인 데이터베이스 인덱스 목록
> select distinct table_name, index_name from information_schema.statistics where table_schema = '{database_name}';

## 10. TABLE Comment 확인
> select 
> table_name, table_comment 
> from information_schema.tables
> where 
> table_schema = '{database_name}'

## 11. TABLE 내 Column Comment 확인
> select 
> table_name, column_name,column_comment 
> from information_schema.columns
> where 
> table_schema = '{database_name}'

