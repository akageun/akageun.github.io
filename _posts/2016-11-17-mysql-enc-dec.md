---
layout: post
title:  "[Mysql] 데이터의 암호화, 복호화"
date:   2016-11-17 09:00:00 +0900
categories:
 - database
tags: 
 - mysql
---
# 1. Mysql에서 제공하는 암호화 함수

|        | 암호화                 | 복호화      | 비고                              |
|--------|------------------------|-------------|-----------------------------------|
| 단방향 | MD5                    | -           | MD5, password은 같은 방법 입니다. |
|        | PASSWORD, OLD_PASSWORD | -           |                                   |
|        | SHA1, SHA              | -           |                                   |
| 양방향 | AES_ENCRYPT            | AES_DECRYPT |                                   |
|        | DES_ENCRYPT            | DES_DECRYPT |                                   |

- (이외에서 제공되는 암호화 함수가 있습니다.)

# 2. 사용 예제
## 1) 단방향
#### (1) MD5

> SELECT MD5('컬럼' or '문자열')

#### (2) PASSWORD

> SELECT PASSWORD('컬럼' or '문자열')

#### (3) SHA1

> SELECT SHA1('컬럼' or '문자열')

## 2) 쌍방향
#### (1) AES 암호화

> SELECT HEX(AES_ENCRYPT('컬럼' or '문자열', '암호화키'))

#### (2) AES 복호화

> SELECT AES_DECRYPT(UNHEX('컬럼' or '문자열'), '암호화키')



