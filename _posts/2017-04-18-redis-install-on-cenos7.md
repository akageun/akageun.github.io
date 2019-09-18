---
layout: post
title:  "Install redis on Centos 7"
date:   2017-04-18 09:00:00 +0900
categories:
 - linux
tags: 
 - redis
---
## 1. yum으로 install

> sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
> sudo yum install --enablerepo=remi redis

## 2. Redis Run

> sudo service redis start

## 3. 접속
> redis-cli

## 4. 부팅시 자동 시작
> sudo chkconfig redis on

