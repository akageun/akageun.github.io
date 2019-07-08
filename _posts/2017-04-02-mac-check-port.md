---
layout: post
title:  "사용중인 포트 확인 및 닫기"
date:   2017-04-02 00:00:00 +0900
categories:
 - mac
tags: 
 - mac
---
# 1. 사용중인 포트 확인
> sudo lsof -i :{확인할 포트}

# 2. 사용중인 포트 닫기
> sudo kill -9 {닫을 포트 프로세스 ID}

