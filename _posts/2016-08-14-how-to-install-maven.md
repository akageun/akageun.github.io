---
layout: post
title:  "Maven Install"
date:   2016-08-14 00:00:00 +0900
categories:
 - maven
tags: 
 - java
 - maven
---

# 1. 설치확인

> mvn -version

> -bash: mvn: command not found

# 2. tar파일 다운로드
- 링크는 Maven에서 받을 수 있다. (Binary tar.gz archive을 받아야함)

> wget http://apache.tt.co.kr/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

# 3. 압축풀기

> tar xvzf ./apache-maven-3.3.9-bin.tar.gz 

# 4. 링크 만들기

> ln -s ./apache-maven-3.3.9 ./maven

# 5. 환경변수 설정
- .bash_profile열기

> vi ~/.bash_profile

> export M2_HOME=$HOME/apps/maven
> export PATH=$PATH:$M2_HOME/bin
> source ~/.bash_profile 

# 6. 확인

> mvn -version

> Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-    10T16:41:47+00:00)
> Maven home: /home/ec2-user/apps/maven
> Java version: 1.8.0_73, vendor: Oracle Corporation

