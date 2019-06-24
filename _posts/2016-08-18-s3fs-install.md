---
layout: post
title:  "[AWS S3] s3fs 설치하기(Centos)"
date:   2018-08-18 00:00:00 +0900
categories:
 - aws
tags: 
 - s3
---

# 1. s3fs란?
- s3를 파일 시스템처럼 사용할 수 있음.
- AWS S3 API를 사용하지 않아도 파일 입출력이 편함.
- 단점은 느리다.

# 2. Install
## 1) dependencies 설치
 
> sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel

## 2) git clone && install
>  git clone https://github.com/s3fs-fuse/s3fs-fuse.git
```
cd s3fs-fuse
./autogen.sh
./configure
make
sudo make install
```


## 3) mount
- 키 파일 생성 

> echo MYIDENTITY:MYCREDENTIAL > /path/to/passwd

- 키 파일 권한 설정

> chmod 600 /path/to/passwd

- mount

> s3fs mybucket /path/to/mountpoint -o passwd_file=/path/to/passwd

# 3. 관련 링크
- github : https://github.com/s3fs-fuse/s3fs-fuse

 