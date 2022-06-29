---
layout: post
title:  "[ElasticSearch] not_analyzed and wildcard query"
date:   2017-04-24 09:00:00 +0900
categories:
 - elastic
tags: 
 - elasticsearch
---

# 1. not_analyzed
- contain 검색을 할거다.

# 2. wildcard
- '*', '?'로 매칭할 수 있음.
- '*' 은 SQL 에서 '%' 와 비슷하다.(all characters match)
- SQL 예시 : SELECT * FROM {TABLE_NAME} where {컬럼} like '%{검색할 단어}%'
- '?' 는 single character match
- 주의사항 : '*', '?'를 첫 시작으로 사용하면 안됨.
- 샘플

```
curl -XPOST http://localhost:9200/{테스트Index}/{테스트Type}/_search?pertty -d '{
"query" : {
	"wildcard" : {
		"{테스트 Field}": "*얍*"
		}
	}
}
```

---
## 참고자료
- https://www.elastic.co/guide/en/elasticsearch/reference/current/term-level-queries.html
- http://stackoverflow.com/questions/21161062/elasticsearch-wildcard-search-on-not-analyzed-field
- http://m.blog.naver.com/parkjy76/30174434509

