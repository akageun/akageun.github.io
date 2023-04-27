---
layout: post
title: "[Nginx] location block 설정"
date: 2023-04-27 09:00:00 +0900
categories:
- webserver
tags:
- nginx
---

- location 디렉티브 설정

```
# 정확히 일치하는 매치. /example 은 포함 안됨 
location = / {
  ...
}

# / 로 시작하는 uri 는 다 포함됨(패턴 일치)
location / {
  ...
}

# /example 로 시작하는 uri 는 다 포함됨(패턴 일치, 위와 같음)
location /example/ {
  ...
}

# 시작 패턴
location ^~ /example/ {
  ...
}

# 정규식 표현, 일치 (대소문자 구분)
location ~ \.(gif|jpg|jpeg|png)$ {
  ...
}

# 정규식 표현, 일치 (대소문자 구분 안함, * 이 구분안함 결정)
location ~* \.(md|mdwn|txt|mkdn)$ {
  ...
}
```


#### root and index
- location block 안에 문서 디렉토리에 대한 설정을 변경 할 수 있다.

```
location / {
  root html;
  index index.html index.htm;
}

```