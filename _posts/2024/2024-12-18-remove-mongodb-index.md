---
layout: post
title: "[MongoDB] MongoDB 에서 미사용 중인 Index 제거 과정"
date: 2024-12-18 09:00:00 +0900
categories:
- database
tags:
- mongodb
---

- 시스템에 여러개의 Index 가 존재 했었고, 사용 중인지에 대한 확신이 없는 상황이였으므로 어떤 식으로 검증하여 제거하고 Disk 가용량을 확보했는지에 대해서 정리함.

## 현재 생성되어있는 Index 목록 확인
- 아래 명령어로 확인한 목록을 정리해서 현재 사용 중인 쿼리와 비교함
- 공식문서 : https://www.mongodb.com/ko-kr/docs/manual/reference/method/db.collection.getIndexes/

> db.[CollectionName].getIndexes()

## 사용량 확인하기
- 확인할 사용량은 두가지 였음.
  - `Index 를 사용하고 있는지?`
  - `Index 가 차지하고 있는 용량은 어느정도 인지?`

### Index 사용량
- Index 별 호출 사용량을 확인.
  - 실제로 사용되고 있는지를 알 수 있음.
  - 단, 일회성으로 확인하고 넘어가기보다는 일주일 간격? 등 기간을 두고 확인하는 것이 좋음.
- https://www.mongodb.com/ko-kr/docs/manual/reference/operator/aggregation/indexStats/#mongodb-pipeline-pipe.-indexStats

> db.[CollectionName].aggregate([{$indexStats:{}},{$project:{name:1, accesses:1}}])

- 해당 명령어를 통해 accesses.ops 가 0 인 것들을 확인함.

### Index 용량
- https://www.mongodb.com/ko-kr/docs/manual/reference/method/db.collection.stats/

> db.[CollectionName].stat()

![image](/assets/postimage/img_1.png)

- 실제 명령을 날린 후 다음과 같은 용량을 확인하여 제거시 어느정도 용량이 확보되는지 예측함.

## 제거 정책 잡기
### hidden Index 에 대해서
- https://www.mongodb.com/ko-kr/docs/v5.0/core/index-hidden/
- 쿼리플래너에서 Index 를 사용 안하도록 제외하는 작업
- `쿼리플래너에서만 제거되고, 물리적 공간은 확보가 안됨`

### Drop Index 에 대해서
- 쿼리플래너에서 제거됨과 동시 물리 공간도 확보되므로 해당 방식으로 정함.

## 결과
- 쿼리 분석 및 간단한 명령어들을 통하여 미사용 Index 를 파악하고 제거함으로써 Disk 가용량을 확보함.
