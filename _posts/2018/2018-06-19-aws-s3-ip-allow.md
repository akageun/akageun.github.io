---
layout: post
title:  "[S3] 특정 IP만 사용 가능하도록 설정하는 법"
date:   2018-06-19 09:00:00 +0900
categories:
 - cloud
tags:
 - aws
 - s3
---
# 1. S3 버킷 설정

![image](https://user-images.githubusercontent.com/13219787/61304785-ab6f5500-a824-11e9-8d24-e1d4fd4176a5.png)


# 2. 설정 추가
```json
{
   "Version":"2012-10-17",
   "Id":"S3PolicyId1",
   "Statement":[
      {
         "Sid":"IPAllow",
         "Effect":"Allow",
         "Principal":"*",
         "Action":"s3:*",
         "Resource":"arn:aws:s3:::examplebucket/*",
         "Condition":{
            "NotIpAddress":{
               "aws:SourceIp":"0.0.0.0/32"
            },
            "IpAddress":{
               "aws:SourceIp":[
                  "54.240.143.0/24",
                  "54.241.143.0/24"
               ]
            }
         }
      }
   ]
}
```



---
## 관련문서
- https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/dev/example-bucket-policies.html#example-bucket-policies-use-case-3