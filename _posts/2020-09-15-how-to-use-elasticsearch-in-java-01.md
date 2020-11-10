---
layout: post
title:  "[RestHighLevelClient] 1. 기본 사용법"
date:   2020-09-15 09:00:00 +0900
categories:
 - java
tags: 
 - elasticsearch
 - kibana
 - logstash
 - java
---

- `Java High Level REST Client` 를 사용하여 Elasticsearch를 사용해보자!

## pom.xml
- version 은 사용 중인 es 버전으로 맞춰서 작업하는게 좋습니다.

```xml
<dependency>
    <groupId>org.elasticsearch.client</groupId>
    <artifactId>elasticsearch-rest-high-level-client</artifactId>
    <version>7.9.1</version>
</dependency>
```

## gradle
```gradle
compile 'org.elasticsearch.client:elasticsearch-rest-high-level-client:7.9.1'
```

## RestHighLevelClient 
```java
RestHighLevelClient client = new RestHighLevelClient(
    RestClient.builder(
        new HttpHost("localhost", 9200, "http")
    )
);

client.close();

```

- try with resources

```java
try (
    RestHighLevelClient client = new RestHighLevelClient(
        RestClient.builder(
            new HttpHost("localhost", 9200, "http")
        )
    );
) {

} catch (IOException e) {
    log.error(e.getMessage(), e);
}
```

---
## 참고자료
- https://www.elastic.co/guide/en/elasticsearch/client/java-rest/master/java-rest-high.html

