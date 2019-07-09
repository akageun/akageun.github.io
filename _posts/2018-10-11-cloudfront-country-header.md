---
layout: post
title:  "CloudFront Header 내 국가코드 관련"
date:   2018-10-11 09:00:00 +0900
categories:
 - aws
tags: 
 - cloudfront
---
#### java
```
request.getHeader("CloudFront-Viewer-Country")
```

#### php
```
$\_SERVER\['CloudFront-Viewer-Country'\]
```

---
## 참고링크
- https://docs.aws.amazon.com/ko_kr/AmazonCloudFront/latest/DeveloperGuide/RequestAndResponseBehaviorCustomOrigin.html