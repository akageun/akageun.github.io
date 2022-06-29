---
layout: post
title:  "[AWS] SCP로 EC2에서 파일/폴더 가져오기"
date:   2018-01-18 09:00:00 +0900
categories:
 - cloud
tags: 
 - aws  
 - scp
 - linux
 - ec2
---
# 1. SCP란?
> secure copy; SCP

# 2. 명령어
## 1) 샘플명령어(EC2에src_directory 폴더를 dst_directory로 복사한다.)
> scp -i {sample.pem} -r {user_id}@{remote_ip}:{src_directory} {dst_directory}

## 2) 팁
- pem파일은 600 권한을 잘 줘야한다.

> chmod 600 ./sample.pem

- 에러메시지

![image](https://user-images.githubusercontent.com/13219787/63651242-a8ee0c80-c78d-11e9-98bd-bc8eabb4998c.png)



