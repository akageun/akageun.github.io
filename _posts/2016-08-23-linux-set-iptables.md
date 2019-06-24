---
layout: post
title:  "Centos 방화벽 설정"
date:   2018-08-23 00:00:00 +0900
categories:
 - linux
tags: 
 - basic
---
# 1. 열린포트 확인 
> netstat -anp | grep LISTEN​

# 2. 포트 열기

## 1) iptables 수정
> vi ​/etc/sysconfig/​iptables

## 2) 원하는 포트 추가
> iptables -I INPUT -p tcp --dport 포트번호 -j ACCEPT

## 3) 적용
> service iptables restart​



