---
layout: post
title:  "History 명령어"
date:   2018-07-05 09:00:00 +0900
categories:
 - linux
tags: 
 - linux
---

# 1. History 명령어란?
- 이전에 입력한 명령어 이력을 볼 수 있는 명령어

# 2. 사용하기
## 1) history
- 기본 명령어로 순차적으로 입력했던 명령어 리스트를 보여준다.

> history

![image](https://user-images.githubusercontent.com/13219787/61382713-3f562500-a8e8-11e9-87f8-f81cb9ed648d.png)

## 2) 최근 N개 검색
- history n
- 최근 입력한 n 개의 명령어 이력을 보여준다.

> history 5

- 최근 5개의 명령어를 보여준다.

## 3) 이력 중 문자열 검색
- history |grep {검색할 문자열}
- {검색할 문자열}에 대한 명령어만 리스트로 노출된다.

> history |grep cd

## 4) 기존 이력 삭제
- 기존에 입력했던 명령어 목록 삭제

> history -c

## 5) 명령어 이력을 파일로 만들기
- 입력된 이력을 특정 파일로 저장

> history -w tmp_history.txt

## 6) 기존에 입력했던 명령어 재실행
- history 명령어로 출력한 앞에 번호로 명령어 재 실행
- !{이력번호}

> !506

## 7) 바로 전 입력한 명령어 실행
- !!

> !!

![image](https://user-images.githubusercontent.com/13219787/61382726-454c0600-a8e8-11e9-9bc5-952729035b97.png)

# 3. Tip
## 1) 명령어 수행시간 추가
- 명령어 입력 시간 추가

#### (1) /etc/profile 수정

> vi /etc/profile

#### (2)  아래 내용 추가
```
#Add Date to .bash_history
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S : "
export HISTTIMEFORMAT
```

#### (3) 적용
> source /etc/profile

