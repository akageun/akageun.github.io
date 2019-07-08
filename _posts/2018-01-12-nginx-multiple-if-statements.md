---
layout: post
title:  "[nginx] nginx conf 파일 내 다중 if 조건"
date:   2018-01-12 09:00:00 +0900
categories:
 - webserver
tags: 
 - nginx
---

- nginx conf 파일 내에 다중 if문 조건을 넣고싶다. 허나 nginx에서는 다중 조건 if문 사용이 안된다.

# 1. 하고싶은 소스
```
if ($host = 'a.example.com' || $host = 'b.example.com'){
    return 301 https://$host$request_uri;
}
```

# 2. 변경된 소스
```
set $is_redirect_val 0;

if ($host = 'a.example.com') {
    set $is_redirect_val 1;
}
if ($host = 'b.example.com') {
    set $is_redirect_val 1;
}
if ($is_redirect_val = 1) {
    return 301 https://$host$request_uri;
}
```