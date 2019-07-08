---
layout: post
title:  "[nginx] domain으로 referer block"
date:   2018-06-03 09:00:00 +0900
categories:
 - webserver
tags: 
 - nginx
---
- referer 내에 값을 참고하여 block!
- 허용된 referer만 내 이미지 서버를 사용할 수 있도록 작업할 때 유용함

# 1. 소스코드

```
server
{
 ....

  location / 
  {
    valid_referers none blocked server_names *.example.com;

    if ($invalid_referer) {
            return   403;
    }
    ....
  }
}
```

## 참고페이지

http://nginx.org/en/docs/http/ngx_http_referer_module.html