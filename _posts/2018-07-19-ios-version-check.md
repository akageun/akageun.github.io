---
layout: post
title:  "IOS 버전 관련 처리"
date:   2018-07-19 09:00:00 +0900
categories:
 - javascript
tags: 
 - ios
---

# 1. IOS Useagent

> Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1

# 2. 하고싶은 것
- 11.4 버전 이상일 경우를 체크하고 싶다.
- 소스
```javascript
function osVersion(){
    var mt = (navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/);

    if (mt === undefined || mt === null || nt === '') {
      return false;
    }

       var version = [
           parseInt(mt[1], 10),
           parseInt(mt[2], 10),
           parseInt(mt[3] || 0, 10)
       ];

    return parseFloat(version.join('.'))
}
```

- 사용법

```javascript
if (osVersion() > 11.4) {
    alert("에러");
}
```

* IOS 인지 아닌지에 대한 처리는 없습니다. 관련 소스는 추가해서 사용하세요 ^_^