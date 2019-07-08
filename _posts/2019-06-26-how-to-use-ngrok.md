---
layout: post
title:  "ngrok 사용하기"
date:   2019-06-26 09:00:00 +0900
categories:
 - tools
tags: 
 - ngrok
---

- 로컬환경에서 ssl을 사용하고 싶은 경우
- localhost를 외부에서 호출하고 싶은 경우

# ngrok 사용하기.
- [바로가기](https://dashboard.ngrok.com)

## 설치하기(다운로드)
- 사이트 -> 다운로드 -> 압축해제

#### 실행
###### mac or linux
> ./ngrok http 8080

###### windows
./ngrok.exe http 8080

## npm로 설치하기
#### 설치
> npm install -g ngrok

#### 실행
> ngrok http 8080

## Session Expire
- 한 세션은 8시간만 유지된다. (재실행하면 다시 8시간으로 변경됨)
- 회원 가입 후 아래 링크에서 AuthToken을 가지고 온다.
- [auth 페이지 바로가기](https://dashboard.ngrok.com/auth)

- 추가 전

![image](https://user-images.githubusercontent.com/13219787/60274220-a9575c00-9932-11e9-86c7-240019624af7.png)

- 추가 후

> ngrok http 8080 --authtoken=[AuthToken]

![image](https://user-images.githubusercontent.com/13219787/60274219-a9575c00-9932-11e9-8d24-c364389774eb.png)


---
## 참고링크
- https://github.com/bubenshchykov/ngrok

- https://dol2156.tistory.com/515
