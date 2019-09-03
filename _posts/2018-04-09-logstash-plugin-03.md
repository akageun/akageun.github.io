---
layout: post
title:  "[LOGSTASH] 03. Logstash Filter mutate"
date:   2018-04-09 09:00:00 +0900
categories:
 - elastic
tags: 
 - logstash
---

# 1. Filter Mutate??
- 데이터 변환

# 2. 기능
- remove_field : 해당 필드 값들을 제거한다.
- rename : 필드명을 변경한다.
- 기타 여러 기능들이 있다. 아래 참고링크를 참고하면 좋다.

# 3. 예제

```
filter {
	mutate {
		remove_field => [
			"@timestamp",
			"@version"
		]
		rename => {
			"TEST_VALUE" => "testValue"
		}
	}
}
```

---
## 참고 링크
 - https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html#plugins-filters-mutate-rename
