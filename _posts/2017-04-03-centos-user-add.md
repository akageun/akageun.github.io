---
layout: post
title:  "Centos User Add(+Aws EC2)"
date:   2017-03-20 00:00:00 +0900
categories:
 - linux
tags: 
 - centos
 - aws
---

# 1. 계정 존재 여부 확인

> cat /etc/passwd | grep {추가할 계정명}

# 2. 계정 추가

> sudo adduser {추가할 계정명}

- 확인

> cat /etc/passwd | grep {추가할 계정명}

# 3. 비밀번호 생성 or 키 설정
- 비밀번호 생성

> echo '{비밀번호}' | passwd --stdin {추가할 계정명}

- 키 설정(on AWS)

> sudo su - {추가할 계정명}
> mkdir .ssh
> chmod 700 .ssh
> touch .ssh/authorized_keys
> chmod 600 .ssh/authorized_keys

- 퍼블릭키 를 `authorized_keys`에 넣으시면 됩니다.



