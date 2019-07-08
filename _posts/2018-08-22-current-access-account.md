---
layout: post
title:  "현재 접속 계정 보기."
date:   2018-08-22 09:00:00 +0900
categories:
 - database
tags: 
 - mysql
---

- Mysql에서 현재 접속 중인 계정 정보를 보기 위한 쿼리다.

# 1. 명령어
## 1) show 명령어

> SHOW PROCESSLIST;

## 2) table 조회
- 아래 쿼리를 사용할 경우 where 조건을 걸 수 있다.
> SELECT * FROM `PROCESSLIST`

