---
layout: post
title:  "Jenkins Install on Centos(yum Install)"
date:   2016-08-06 00:00:00 +0900
categories:
 - jenkins
tags: 
 - centos
 - linux
 - install
---

# yum Install 
## 1. Java Version Check
 - java -version 
 - 없을 경우 설치해야함. 

## 2. Jenkins Install
- 1) sudo wget -O /etc/yum.repos.d/jenkins.repo   http://jenkins-ci.org/redhat/jenkins.repo
- 2) sudo  rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
- 3) sudo yum install jenkins
- 4) /etc/init.d/jenkins `start` or `stop` or `restart`
- 5) chkconfig jenkins on (부팅시 자동실행, 필요시에만 사용할 것~)
 
## 3. Config 수정
- 1) Jenkins Port Change

> sudo vim /etc/sysconfig/jenkins

```
  Default:
    JENKINS_PORT="8080"
    New:
    JENKINS_PORT="8443"
```
