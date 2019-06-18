---
layout: post
title:  "Mysql 원격접속하기."
date:   2018-08-24 00:00:00 +0900
categories:
 - database
tags: 
 - mysql
---

# 1. 명령어

> mysql -h 127.0.0.1 -u USER_ID -p 

-h : 원격지 IP
-u : 유저 아이디
-p : 비밀번호

## mysql이 설치안되어있을 경우
- mysql client만 설치

> sudo yum-y install mysql

