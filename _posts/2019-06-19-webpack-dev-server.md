---
layout: post
title:  " [webpack 물고 뜯고 맛보기!!] 4. webpack-dev-server"
date:   2019-06-19 00:00:00 +0900
categories:
 - front
tags: 
 - webpack
 - es6
 - webpack-dev-server
---
# webpack-dev-server
- 개발모드에서 사용하기 좋음 : webpack --watch 옵션보다 작업하기 훨씬 좋음
- HMR(Hot Module Replacement) : 브라우저 실시간 리로딩

## 맛보기
#### 1. 설치

###### project 생성

> #폴더 생성 및 이동
> mkdir devserver-ex-1 && cd devserver-ex-1

> #npm을 사용한 프로젝트 생성
> npm init -y

###### webpack-dev-server 설치

> npm install --save-dev webpack-dev-server

#### 1-1 직접 실행

###### 실행
> webpack-dev-server

#### 1-2 스크립트로 실행

###### package.json 내 script에 설정 추가해보기
```json
"scripts": {
 "start": "webpack-dev-server --inline --hot"
 }
```

###### 실행
> npm run start

## option
#### 설명
- **inline** : 모듈이 변경되었을 경우, 브라우저 전체를 리로드 해준다.
- **hot** : 변경된 모듈만 리로드 해주는 옵션

#### 사용법 
- 브라우저를 리로드 하지 않음.

> webpack-dev-server

- 브라우저 전체를 리로드 한다.

> webpack-dev-server --inline

- 변경된 모듈만 변경되거나, 전체 페이지를 리로드 한다.

> webpack-dev-server  --inline --hot

## webpack.config.js 내 설정해보기
