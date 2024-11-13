---
layout: post
title: "[ElasticSearch] Max Result Window 설정"
date: 2024-11-06 09:00:00 +0900
categories:
- elastic
tags:
- elasticsearch
---
- 페이징 처리하게 되면 아래와 같은 에러메시지를 볼 수 있다.
  - from + size 값이 설정된 max_result_window 보다 클 경우 발생함

```
Result window is too large, from + size must be less than or equal to: [10000] but was [10001]. See the scroll api for a more efficient way to request large data sets. This limit can be set by changing the [index.max_result_window] index level setting.
```

## ES가 페이징을 처리하는 방식
- ES 의 구성
  - ES 의 Shard 를 사용하는 전략은 Index를 Shard 라는 단위로 나누고, 클러스터를 구성하는 각 노드에 분산하여 저장하는 분산 시스템
  - 각 샤드를 대상으로 조회한 결과를 중앙에서 정렬하여 최종 결과를 반환함.

- 실제 쿼리 요청이 전달되면?

  - 코디네이터 노드는 관련된 Shard 들에 요청을 보내, 조회함.

  - 각 샤드는 문서를 정렬하여 필요한 만큼 조회함. 코디네이터 노드로 결과를 반환

  - 코디네이터 노드에서 정렬하여 클라이언트에 최종 결과를 반환함.
- 실제로 페이지네이션을 뒤로 많이 검색할 수록 더 많은 데이터를 읽어야하는 상황이므로 기본값(10,000)이 존재함.

## 해결방안
- 기본으로 설정된 값 수정
```
PUT _settings
{
  "index.max_result_window": {size}
}
```

- Index 별 수정
```
PUT ${indexName}/_settings
{
  "index.max_result_window": {size}
}
```
