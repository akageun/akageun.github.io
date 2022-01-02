---
layout: post
title: "Caffeine Cache 사용해보기"
date: 2021-12-30 10:00:00 +0900
categories:
- java
tags:
- spring
- caffeine cache
- local cache
---
# Caffeine Cache
- https://github.com/ben-manes/caffeine/wiki/Benchmarks
- 위 github 에 있는 것과 같이 성능적인면이나 기능적인면에서 심플하고 장점들이 많아서 진행 중인 프로젝트에서 사용해보기 위해 테스트

## 테스트 준비
- 라이브러리 추가

```xml
<dependency>
    <groupId>com.github.ben-manes.caffeine</groupId>
    <artifactId>caffeine</artifactId>
    <version>2.5.5</version>
</dependency>
```

- 테스트용 class 생성

```java
public static class DataObject {
    private final String data;

    public DataObject(String data) {
        this.data = data;
    }

    public String getData() {
        return data;
    }
}
```

## 단순 조회 및 캐싱 테스트
```java
Cache<String, DataObject> cache = Caffeine.newBuilder()
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .maximumSize(100)
        .build();

String key = "A";
DataObject dataObject = cache.getIfPresent(key);

Assertions.assertNull(dataObject);

dataObject = new DataObject(key);
cache.put(key, dataObject);
dataObject = cache.getIfPresent(key);

Assertions.assertNotNull(dataObject);

cache.invalidate(key); //Caller 에 의한 제거

dataObject = cache.get(key, k -> new DataObject("test Data"));

Assertions.assertNotNull(dataObject);
Assertions.assertEquals("test Data", dataObject.getData());
```

## 동기 로딩처리...
```java
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
        .maximumSize(100)
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .build(k -> {
            log.info("K : {}", k);
            return new DataObject("test Data " + k);
        });

String key = "A";
DataObject dataObject = cache.get(key);

Assertions.assertNotNull(dataObject);
Assertions.assertEquals("test Data " + key, dataObject.getData());

Map<String, DataObject> dataObjectMap
        = cache.getAll(Arrays.asList("A", "B", "C"));

Assertions.assertEquals(3, dataObjectMap.size());
```

## 비동기로직 테스트
```java
AsyncLoadingCache<String, DataObject> cache = Caffeine.newBuilder()
        .maximumSize(100)
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .buildAsync(k -> new DataObject("Data for " + k));

String key = "A";

cache.get(key)
        .thenAccept(dataObject -> {
    Assertions.assertNotNull(dataObject);
    Assertions.assertEquals("Data for " + key, dataObject.getData());
});

cache.getAll(Arrays.asList("A", "B", "C"))
        .thenAccept(dataObjectMap -> Assertions.assertEquals(3, dataObjectMap.size()));
```

## 사용량보기
```java
LoadingCache<String, DataObject> cache = Caffeine.newBuilder()
        .maximumSize(100)
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .recordStats()
        .build(k -> return new DataObject("test Data " + k));

// 동기로직 처리와 같이 cache 호출 로직 테스트...

CacheStats stats = cache.stats();
log.info("hit : {}, {}", stats.hitCount(), stats.hitRate());
log.info("miss : {}, {}", stats.missCount(), stats.missRate());
```

- 로그 결과
```
CaffeineCacheTest - hit : 1, 0.25
CaffeineCacheTest - miss : 3, 0.75
```

---
## 참고링크
- https://github.com/ben-manes/caffeine
- https://www.baeldung.com/java-caching-caffeine