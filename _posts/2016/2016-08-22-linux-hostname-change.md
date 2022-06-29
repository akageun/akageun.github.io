---
layout: post
title:  "호스트 네임 변경하기"
date:   2016-08-22 09:00:00 +0900
categories:
 - linux
tags: 
 - basic
---
# 1. 현재 호스트 확인
> hostname

# 2. 호스트명 변경
> vi /etc/sysconfig/network

- 내에 HOSTNAME="" 안 값을 변경

> vi /etc/HOSTNAME

- 좀전에 넣은 값을 넣음

# 3. 재시작
> reboot

# 4. 확인
> hostname

 