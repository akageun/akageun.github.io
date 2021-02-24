---
layout: post
title:  "[RestHighLevelClient] 2. Index 생성, 삭제 등"
date:   2020-09-15 09:00:00 +0900
categories:
- java
tags:
- elasticsearch
- kibana
- logstash
- java
---

## index 생성
#### kibana dev tool
```
PUT ${indexName}
{
    "settings":{
      "number_of_shards": 3,
      "number_of_replicas": 2
    },"mappings":{
      "properties":{
          "message":{
              "type":"text"
          }
      }
        
    }
}
```

#### java
```java
private void createIndex(RestHighLevelClient client, String indexName) throws IOException {
    CreateIndexRequest request = new CreateIndexRequest(indexName);
    request.settings(Settings.builder()
        .put("index.number_of_shards", 3)
        .put("index.number_of_replicas", 2)
    );
    XContentBuilder builder = XContentFactory.jsonBuilder();
    builder.startObject();
    {
        builder.startObject("properties");
        {
            builder.startObject("message");
            {
                builder.field("type", "text");
            }
            builder.endObject();
        }
        builder.endObject();
    }
    builder.endObject();
    request.mapping(builder);

    CreateIndexResponse createIndexResponse = client.indices().create(request, RequestOptions.DEFAULT);

    boolean acknowledged = createIndexResponse.isAcknowledged();
    boolean shardsAcknowledged = createIndexResponse.isShardsAcknowledged();

    log.info("acknowledged : {}, shardsAcknowledged : {}", acknowledged, shardsAcknowledged);
}
```

## index 제거
#### kibana dev tool
```
DELETE ${indexName}
```

#### java
```java
private void deleteIndex(RestHighLevelClient client, String indexName) throws IOException {
    DeleteIndexRequest request = new DeleteIndexRequest(indexName);

    AcknowledgedResponse response = client.indices().delete(request, RequestOptions.DEFAULT);

    log.info("acknowledged : {}", response.isAcknowledged());
}
```

## index exist
#### kibana dev tool
```
HEAD ${indexName}
```

###### 결과
> 200 - OK

- 없을 경우
```json
{"statusCode":404,"error":"Not Found","message":"404 - Not Found"}
```

#### java
```java
private void existIndex(RestHighLevelClient client, String indexName) throws IOException {
    GetIndexRequest request = new GetIndexRequest(indexName);
    boolean exists = client.indices().exists(request, RequestOptions.DEFAULT);

    log.info("indexName : {}, exists : {}", indexName, exists);
}
```

## index open
- 운영중인 index 의 경우 close 후에 설정을 변경 할 수 있다. 작업 완료 된 후 open 처리해주어야함.
#### kibana dev tool
```
POST /${indexName}/_open
```

#### java
```java
private void openIndex(RestHighLevelClient client, String indexName) throws IOException {
    OpenIndexRequest request = new OpenIndexRequest(indexName);

    OpenIndexResponse openIndexResponse = client.indices().open(request, RequestOptions.DEFAULT);

    log.info("acknowledged : {}", openIndexResponse.isAcknowledged());
}
```

## index close
#### kibana dev tool
```
POST /${indexName}/_close
```
#### java
```java
private void closeIndex(RestHighLevelClient client, String indexName) throws IOException{
    CloseIndexRequest request = new CloseIndexRequest(indexName);
    AcknowledgedResponse closeIndexResponse = client.indices().close(request, RequestOptions.DEFAULT);

    log.info("acknowledged : {}", closeIndexResponse.isAcknowledged());
}
```

---
## 참고링크
- https://www.elastic.co/guide/en/elasticsearch/client/java-rest/master/java-rest-high-create-index.html
- https://www.elastic.co/guide/en/elasticsearch/client/java-rest/master/java-rest-high-indices-exists.html
- https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-exists.html
- https://www.elastic.co/guide/en/elasticsearch/client/java-rest/master/java-rest-high-delete-index.html
- https://www.elastic.co/guide/en/elasticsearch/client/java-rest/master/java-rest-high-open-index.html
- https://www.elastic.co/guide/en/elasticsearch/client/java-rest/master/java-rest-high-close-index.html
