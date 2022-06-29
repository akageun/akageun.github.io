---
layout: post
title:  "RDS Mysql or Aurora 에서 Max_connection 값 수정하기."
date:   2018-09-02 09:00:00 +0900
categories:
 - cloud
tags: 
 - aurora
 - mysql
 - cloud
 - aws
---
# 1. 현재 사용량 확인해보기.

> SHOW STATUS LIKE 'Max_used_connections';

# 2. 세팅된 현재 값 확인해보기.

> SHOW VARIABLES LIKE 'max_connections';
- 웹 콘솔에서 확인해보면 아래와 같은 값으로 세팅되어있다.

> GREATEST({log(DBInstanceClassMemory/805306368)*45},{log(DBInstanceClassMemory/8187281408)*1000})

# 3. 위처림 계산하는게 아닌! 하드코딩처럼 특정 값으로 수정하자!
- 파라미터에서 max_connections를 검색한다.

![image](https://user-images.githubusercontent.com/13219787/59700443-40832c00-922e-11e9-87c6-f6f030851f25.png)

- 빨간줄처럼 dynamic이라 DB 재부팅 없이도, 적용된다.
- 위 Values를 수정하면 된다.



