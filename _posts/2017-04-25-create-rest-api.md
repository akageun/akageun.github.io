---
layout: post
title:  "[ElasticSearch] Rest API"
date:   2017-04-25 09:00:00 +0900
categories:
 - elastic
tags: 
 - elasticsearch
---
# 1. 통계정보
> curl http://localhost:9200/_stats?v&pretty=ture

# 2. index 정보
- 전체 index 정보

> curl http://localhost:9200/_cat/indices?v&pretty=true

- {검색}으로 시작하는 index 정보

> curl http://localhost:9200/_cat/indices/{검색}*?v&pretty

- 전체 index 안에 type 정보

> curl http://localhost:9200/_all/_mapping?pretty=true

- 해당 index 안에 type 정보

> curl http://localhost:9200/{INDEX_NAME}/_mapping?pretty=true

# 3. Index 관리
- index 삭제

> curl -XDELETE 'http://localhost:9200/{INDEX_NAME}


