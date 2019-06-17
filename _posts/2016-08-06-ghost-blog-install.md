---
layout: post
title:  "[Ghost] 1. Ghost Blog 소개 및 설치"
date:   2016-08-06 00:00:00 +0900
categories:
 - open source
tags: 
 - ghost
 - install
---

# 1. 소개 
- Ghost란 : node.js 기반으로 만들어진 블로그 플랫폼이다.

# 2. 설치
- 1) Ghost 최신버전 다운로드

> curl -L https://ghost.org/zip/ghost-latest.zip -o ghost.zip

- 2) 압축 해제

> unzip -uo ghost.zip -d ghost

- 3) npm 설치

> npm install --production

- 4) 실행
> npm start

#3. 확인
- 사용자 화면 http://127.0.0.1:2368으로 접속하면 확인 가능하다. http://127.0.0.1:2368/ghost로 접속할 경우 관리자 화면을 볼 수 있다.

