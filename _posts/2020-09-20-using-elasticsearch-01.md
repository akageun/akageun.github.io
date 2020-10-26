---
layout: post
title:  "[ES 를 사용하면서...] 1. 타입 관련 내용 모음 "
date:   2020-09-20 09:00:00 +0900
categories:
 - elasticsearch
tags: 
 - elasticsearch
 - kibana
 - logstash
---

- 엘라스틱서치를 사용하면서 헷갈리는 부분을 찾아서 정리한 내용들 모음 입니다.

## 문자열 타입(text vs keyword)
- 둘다 문자열 관련 타입
- ES 5 부터 `String Type`이 `text` 와 `keyword` 두개로 변경됨.

#### text 
- 전문검색 가능(full-text)
- 색인 전 형태소 기반으로 분리하여 저장함.

#### keyword
- 단순 검색
- 집계/필터링/정렬 등이 가능


## Date 관련
- 
