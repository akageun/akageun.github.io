---
layout: post
title:  "Netty Base 로 이용할 경우, URL 길이 제한 문제 해결 방법"
date:   2024-10-24 09:00:00 +0900
categories:
- database
tags:
- mongodb
---
- 공식 문서 : https://www.mongodb.com/docs/manual/core/wiredtiger/#compression
- WiredTiger 를 이용할 경우 기본적인 압축 라이브러리는 `snappy` 로 적용 된다.
    - 그외 적용 가능한 라이브러는 `zlib`, `zstd` 가 있음.
- 압축에 대한 설정은 collection, index 생성별로 구성할 수 있음.

- https://www.mongodb.com/ko-kr/docs/manual/reference/method/db.createCollection/#specify-storage-engine-options
```
db.createCollection(
  "sample",
  { storageEngine: { wiredTiger: { configString: "block_compressor=zlib" } } }
)
```

## 압축 라이브러리
- 라이브러리 별 성능 : https://www.percona.com/blog/evaluating-database-compression-methods-update/
### `snappy` : [바로가기](https://google.github.io/snappy/)
- MongoDB 기본 설정값
- 효율적인 압축 Rate
- 호환성과 빠른 속도, 합리적인 압축을 목표로 함.
- zlib 에 비해 20 ~ 100% 까지 큼.

### `zlib` : [바로가기](https://www.zlib.net/)
- snappy 와 비교했을 때 CPU 를 더 사용하고 높은 압축률을 제공함.
- OS 에 의존하지 않도록 설계되어있음.
- 손실 없는 압축을 목표로함.

### `zstd` : [바로가기](https://github.com/facebook/zstd)
- zlib 에 비교했을 때 더 높은 압축률을 제공하고 더 낮은 CPU 를 사용함.
- 페이스북에서 만들었음.
- 무손실, 실시간 압축 시나리오를 목표
