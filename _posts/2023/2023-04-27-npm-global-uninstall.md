---
layout: post
title:  "Npm Global uninstall"
date:   2023-04-27 09:00:00 +0900
categories:
- node
tags:
- npm
- uninstall
---

- 아래 명령어로 설치한 모듈 삭제하기

> npm install -g {모듈명}


- 일단 설치된 모듈 확인

> npm list -g | grep {모듈명}

- 제거하기

> npm uninstall -g {모듈명}