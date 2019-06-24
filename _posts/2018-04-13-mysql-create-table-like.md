---
layout: post
title:  "[Mysql] Create Table like"
date:   2018-04-13 00:00:00 +0900
categories:
 - database
tags: 
 - mysql
---
# 1. Create Table like
- 이미 생성된 테이블과 같은 스키마로 테이블을 생성하고 싶다.
- Oracle 의 'CREATE TABLE NEW_TABLE_NAME AS SELECT * FROM OLD_TABLE_NAME [필요시 WHERE 절]' 와 같이 손 쉽게 만들고 싶다. 

#2. SQL 문

> CREATE TABLE [IF NOT EXISTS] NEW_TABLE_NAME  LIKE OLD_TABLE_NAME;


