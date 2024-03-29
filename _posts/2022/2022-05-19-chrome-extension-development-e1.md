---
layout: post
title:  "[Chrome Extension 개발기] 1. 왜? 크롬 익스텐션을 사용해서 개발했어?"
date:   2022-05-19 09:00:00 +0900
categories:
- project
tags:
- chrome
- chrome-extension
---

# 고민시작
- 몇년전 회사를 이직하고 이것 저것 인수인계를 받으면서 각종 `URL` 들을 전달 받았었다.
  - 배포시스템, wiki, 형상관리(멀티 모듈이 아니라서 컴퍼넌트별로 repository 가 따로 있었다.), jira 등...
  - 개발환경, 운영환경 등... 너무 많았다.
- 처음에는 크롬 즐겨찾기에 하나씩 정리해가면서 작성을 해놨었는데, 이게 지나다보니 애매한 부분도 생겨서 폴더를 생성하고 depth 가 깊어지기 시작했다.
- 점점... 찾아가는데에 시간이 걸리고, 마우스로 조심조심 움직여서 클릭하는게 귀찮아졌다.
  - 클릭한번 잘못하면 다시 폴더에 폴더에 폴더를 타고 타고 들어가서 다시 클릭 ㅠ_ㅠ 귀찮다...
  
## 필요했던 것들
- URL 들을 저장해 놓고 싶다.
  - 단 회사 데이터(?)이므로 외부 플랫폼을 이용하고 싶지는 않았다.
- 번거롭게 이것저것 하지 않고, 빠르게 찾고 싶었다.
- 내가 개발하게 된다면, 익숙한 언어로 빠르게 개발하고 싶었다.

## 고민했던 플랫폼
- electron.js 를 사용하여 desktop application 을 개발해보려고 했다.
  - 빌드과정이나 이런 것들이 손이 많이가므로 패스
  - desktop application 으로 alt tab 등의 액션을 해야...
  - 거기에 당시 조사할 때 기준으로 빌드한 프로그램이... 굉장히 무거웠다.(xx MB 는 기본...)
- python 으로 cli tool 을 개발
  - 터미널을 켜놓고 매번 왔다갔다 하는게 귀찮아서 많이 사용안하게 될 것 같음...
  - 생각보다 작업하면서 오가는 상황이 많을게 뻔해서...

## 결정
- 크롬 익스텐션!!
- 메인 브라우저로 크롬을 사용하고 있고, 개발하게 된다면 html, css, js 로 손쉽게 개발이 가능하므로 눈에 보이기 시작했다.
- 저장소로는 local, sync 가 있는데, 외부로 안 보내기 위해 local 사용
- 단점으로는 5달러.... (나중에 다른 어플 개발할 수 있으니 등록하자!!)

# 준비과정
## Chrome Extension
- https://developer.chrome.com/docs/extensions/mv3/
  - 개발할 당시는 v2 였었다.
- 각종 보일러플레이트 프로젝트들!

## 아이콘
- 디자인은 잘 못하므로... icon generator 를 이용하자
  - 이번에 버전업 하면서 새로운 사이트를 이용
  - https://prefinem.com/simple-icon-generator/
- 생각보다 여러 사이즈가 필요해서 내가 원하는 사이즈로 뽑아주는 곳을 찾아서 사용.
  - 이쁜것보다 대충... 이런거다~~ 하는 정도로 나오는 곳으로 선택
  - 디자인보다 사용이 급했으므로 일단 대충 ㅎㅎㅎ

## UI
- vue 를 주로 사용하고 있고, bootstrap 이 편해서 두개로 결정
  - 이번에 업데이트 하면서 bs 5 로 변경
  - vue 는 아직 2.x 로 다음 업데이트 때... 버전업을 할 예정.

## 검색
- 가볍게 나오면 좋겠어서 js 라이브러리 중에 `fuzzy search` 가 가볍게 구현되어 있는 걸 찾음
  - `https://fusejs.io/`

## 개발 시작!!
#### 개발할 기능 목록
- [ ] URL 저장하기
- [ ] 저장된 데이터 export(백업기능처럼.. 사용)
- [ ] json 파일 import (백업기능처럼.. 사용)
- [ ] 검색
  - fuse.js 사용
- [ ] 주소창을 통한 검색
  - omnibox 기능 사용(다음 장에 설명...)

#### 결말...
- 일단 위 내용들에 대해서는 개발이 끝나서 현재 아주 잘 사용하고 있다.
- N년째 잘 사용 중.... 매일 매일 사용 중... 없으면 안됩니다 ㅠㅠ
- repository : https://github.com/akageun/chrome-shortcut-url
- 확장프로그램 스토어 : https://chrome.google.com/webstore/detail/shortcut-url/cdfijakdeldlkdhpolimajpelaogimcp
- 다음 블로깅에서 개발하면서 정리한 내용들을 올려볼 예정이다.