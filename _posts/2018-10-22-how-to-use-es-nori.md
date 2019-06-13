---
layout: post
title:  "[ElasticSearch] Nori 를 사용한 형태소 분석"
date:   2018-10-22 00:00:00 +0900
categories:
 - elastic
tags: 
 - elasticsearch
 - nori
---

# 1. nori 란?
- Elastic에서 개발한 한국어 형태소 분석기
- 사전은 기본으로 'mecab-ko-dic' 을 사용
- 6.4.x 에서 추가.

# 2. plugin설치
#### 1) 설치하기.

> bin/elasticsearch-plugin install analysis-nori

#### 2) (참고)삭제 명령어.

> bin/elasticsearch-plugin remove analysis-nori

# 3. 기본 analyze 호출
- 호출

```
curl -X POST http://localhost:9200/_analyze -d '{
  "analyzer": "nori",
  "text":     "노리 테스트 입니다."
}'
```

- 결과

```json
{
    "tokens": [
        {
            "token": "노리",
            "start_offset": 0,
            "end_offset": 2,
            "type": "word",
            "position": 0
        },
        {
            "token": "테스트",
            "start_offset": 3,
            "end_offset": 6,
            "type": "word",
            "position": 1
        },
        {
            "token": "이",
            "start_offset": 7,
            "end_offset": 10,
            "type": "word",
            "position": 2
        }
    ]
}
```

# 4. 사전 추가
#### 1) text 파일로 사전추가
- ${ELASTICSEARCH_PATH}/config/userdict_ko.txt 로 파일을 생성한다.
- 파일 내에 원하는 사전을 추가한다.
- 테스트로 '버카충'을 추가했습니다.

#### 2) INDEX 생성

```
curl -X PUT http://localhost:9200/nori_test -d '{
  "settings": {
    "index": {
      "analysis": {
        "tokenizer": {
          "nori_user_dict": {
            "type": "nori_tokenizer",
            "decompound_mode": "mixed",
            "user_dictionary": "userdict_ko.txt"
          }
        },
        "analyzer": {
          "my_analyzer": {
            "type": "custom",
            "tokenizer": "nori_user_dict"
          }
        }
      }
    }
  }
}'
```

#### 3) 호출해보기.

```
curl -X POST http://localhost:9200/nori_test/_analyze -d '{
  "analyzer": "my_analyzer",
  "text":     "오늘 버카충 해야합니다."
}'
```

- 결과

```json
{
    "tokens": [
        {
            "token": "오늘",
            "start_offset": 0,
            "end_offset": 2,
            "type": "word",
            "position": 0
        },
        {
            "token": "버카충",
            "start_offset": 3,
            "end_offset": 6,
            "type": "word",
            "position": 1
        },
        {
            "token": "해야",
            "start_offset": 7,
            "end_offset": 9,
            "type": "word",
            "position": 2,
            "positionLength": 2
        },
        {
            "token": "하",
            "start_offset": 7,
            "end_offset": 9,
            "type": "word",
            "position": 2
        },
        {
            "token": "아야",
            "start_offset": 7,
            "end_offset": 9,
            "type": "word",
            "position": 3
        },
        {
            "token": "합니다",
            "start_offset": 9,
            "end_offset": 12,
            "type": "word",
            "position": 4,
            "positionLength": 2
        },
        {
            "token": "하",
            "start_offset": 9,
            "end_offset": 12,
            "type": "word",
            "position": 4
        },
        {
            "token": "ᄇ니다",
            "start_offset": 9,
            "end_offset": 12,
            "type": "word",
            "position": 5
        }
    ]
}
```

# 5. 팁
- analyze 할 때 json 값에 'explain' : true 를 추가하면 좀 더 자세한 내용을 확인할 수 있습니다.

## 참고페이지
- Nori : https://www.elastic.co/guide/en/elasticsearch/plugins/6.4/analysis-nori-tokenizer.html
- Nori(엘라스틱블로그) : https://www.elastic.co/kr/blog/nori-the-official-elasticsearch-plugin-for-korean-language-analysis
- GITHUB : https://github.com/elastic/elasticsearch/tree/master/plugins/analysis-nori
- analyze 테스트 : https://www.elastic.co/guide/en/elasticsearch/reference/current/_testing_analyzers.html