---
layout: post
title:  "Node.js Install on Linux(Centos)"
date:   2016-08-14 00:00:00 +0900
categories:
 - node
tags: 
 - linux
 - install
---

# 1. DownLoad

> wget https://nodejs.org/dist/v6.3.1/node-v6.3.1.tar.gz

# 2. 압축해제

> tar xvzf node-v6.3.1.tar.gz

# 3. 컴파일 작업

> ./configure --prefix=~/node

- 위 명령어를 실행시키면 설정 값에 대한 정보가 json으로 나타날 것이다.

> make && make install

# 4. 환경변수 설정

> vi ~/.bashrc
> export PATH=$PATH:$HOME/node/bin
> source ~/.bashrc

# 5. Install check

> node -v

- 결과

> 6.3.1



# 6. 예외상황
> env: node: No such file or directory

> sudo ln -s /usr/bin/nodejs /usr/bin/node




