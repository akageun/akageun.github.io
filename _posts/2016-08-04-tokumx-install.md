---
layout: post
title:  "Mongo 설치하기(Tokumx 설치하기)"
date:   2016-08-04 09:00:00 +0900
categories:
 - database
tags: 
 - mongodb
 - install
---

# 1. download
- 직접 다운로드 https://www.percona.com/downloads/percona-tokumx/LATEST/
 
> wget https://www.percona.com/downloads/percona-tokumx/tokumx-enterprise-2.0.2/binary/tarball/tokumx-e-2.0.2-linux-x86_64-main.tar.gz

# 2. Install
- 1) tar 풀기

> tar xzf tokumx-2.0.2-linux-x86_64-main.tar.gz --directory /opt

- 2) 링크 연결

> ln -snf /opt/tokumx-2.0.2-linux-x86_64/bin/* /usr/local/bin

- 3) 확인

> which mongod
> --> /usr/local/bin/mongod
> readlink /usr/local/bin/mongod
> --> /opt/tokumx-2.0.0-linux-x86_64/bin/mongod

# 3. 설정
- 1) 환경변수

> export PATH=/usr/local/bin:"$PATH"
> echo 'export PATH=/usr/local/bin:"$PATH"' >> $HOME/.bash_profile
 
- 2) OS 커널값 수정

> echo never > /sys/kernel/mm/transparent_hugepage/enabled

# 4. 시작

> mongod