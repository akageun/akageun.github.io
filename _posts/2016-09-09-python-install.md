---
layout: post
title:  "[Pyton3] python 3.5.2 Install"
date:   2016-09-09 09:00:00 +0900
categories:
 - linux
tags: 
 - python
---

# 1. download
## 1) 링크가져오기
- https://www.python.org/downloads/release/python-352/ 에서 다운로드

![image](https://user-images.githubusercontent.com/13219787/61605602-429f3700-ac81-11e9-977c-c51c3fec2572.png)

- 명령어 실행

> wget https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz

# 2. 설치
## 1) MakeFile 만들기 위한 실행

> ./configure

## 2) 소스 컴파일

> make

## 3) 소스 설치

> sudo make install

# 3. 확인
> python3 --version

