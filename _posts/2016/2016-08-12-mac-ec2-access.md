---
layout: post
title:  "Mac 터미널에서 EC2 접속하기"
date:   2016-08-12 09:00:00 +0900
categories:
 - cloud
tags: 
 - aws
 - ec2
 - mac
---

# 1. Aws Console
- 1) Connect 에서 정보 확인

![image](https://user-images.githubusercontent.com/13219787/59450292-db04f900-8e43-11e9-9252-d9d14197af70.png)

- 2) 받은 *.pem 파일을 ~/.ssh/ 에 저장

> mv .pem ~/.ssh/.pem

- 3) 권한 설정
> chmod 400 *.pem

- 4) Example에 있는 명령어 입력
> ssh -i .pem ec2-user@.compute.amazonaws.com

