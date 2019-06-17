---
layout: post
title:  "Webserver 'nginx' install on Centos 6.5"
date:   2016-08-14 00:00:00 +0900
categories:
 - nginx
tags: 
 - linux
 - install
---

# 1. yum repo 설정

> vim /etc/yum.repos.d/nginx.repo

```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

# 2. yum 실행

> yum install -y nginx

# 3. chkconfig 등록(부팅시 자동 실행)

> chkconfig --levels 235 nginx on

# 4. nginx

> service nginx start
> service nginx stop
> service nginx restart