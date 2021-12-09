---
layout: post
title:  "yum으로 설치된 mongodb 삭제"
date:   2018-07-31 09:00:00 +0900
categories:
 - mongodb
tags: 
 - mongodb   
 - database
 - linux
---
# 1. 사용중인 몽고 정지

> sudo service mongod stop

# 2. 패키지 삭제

> sudo yum erase $(rpm -qa | grep mongodb-org)

# 3. 기타 데이터 삭제

> sudo rm -r /var/log/mongodb
> sudo rm -r /var/lib/mongo

## 참고페이지
- https://stackoverflow.com/questions/8766579/uninstalling-mongo