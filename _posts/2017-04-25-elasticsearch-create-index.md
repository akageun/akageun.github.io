---
layout: post
title:  "[ElasticeSearch] Index Create(Settings, Mappings)"
date:   2017-04-25 00:00:00 +0900
categories:
 - elastic
tags: 
 - elasticsearch
---
# 1. Index Create
```
curl -XPUT "http://localhost:9200/{인덱스 네임}?pretty=true" -d' '{
  "settings": {
    {설정 옵션(아래참고)}
  },
  "mappings": {
    {설정 옵션(아래참고)}
  }
}'
```

## 1) settings 
#### (1) number_of_shards : Shard 개수
#### (2) number_of_replicas : Replica 개수
#### (3) index.refresh_interval : Index 변경 후 검색 결과에 반영되는 시간 설정
#### (4) analysis :analyzer와 tokenizer 설정
#### (5) store : 저장 옵션

## 2) mappings
#### (1) field type (2.x)
- string, number, boolean, date
- ip

#### (2) attribute
- index : 색인 방식 지정 (default : analyzed) -> 사용가능 옵션 : no, not_analyzed, analyzed
- analyzer : 색인 및 검색시 사용할 Global analyzer
- index_analyzer : 색인시 사용할 analyzer
- search_analyzer : 검색시 사용할 analyzer

 * [지원하는 Analyzer](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-analyzers.html)

---
## 참고페이지
- http://www.jopenbusiness.com/mediawiki/index.php?title=ElasticSearch_-_REST_API
- https://www.elastic.co/guide/en/elasticsearch/reference/master/indices-create-index.html
- http://semode.tistory.com/30
- field type 5.x 는 : https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html#_complex_datatypes