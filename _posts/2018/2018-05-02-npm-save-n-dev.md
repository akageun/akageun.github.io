---
layout: post
title:  "npm에서 --save, --save-dev 옵션"
date:   2018-05-02 09:00:00 +0900
categories:
 - node
tags: 
 - node
---

# 1. --save
- 응용 프로그램을 실행하는 데 필요한 패키지를 저장하는 데 사용
- '-S'로 줄여 쓸 수 있음.
- package.json 이 존재하면  dependencies 에 추가된다.

> npm install [package_name] --save

or

> npm install [package_name] -S

# 2. --save-dev

- 개발 목적으로 패키지를 저장하는 데 사용
- '-D'로 줄여 쓸 수 있다.
- package.json 이 존재하면 devDependencies 에 추가된다.
- mocha 등 unit test 등 추가할 때 사용...

> npm install [package_name] -save-dev

or

> npm install [package_name] -D

