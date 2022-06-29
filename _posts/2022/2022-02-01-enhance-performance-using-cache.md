---
layout: post
title: "Cache 를 적용하여 서비스 개선하는 방법..."
date: 2022-02-01 01:00:00 +0900
categories:
- enhanced-experience
tags:
- spring
- cache
- caffeine-cache
---
- 캐싱 전략이라던가 local cache, global cache 등에 대한 정보들은 많다.
- 업무를 하면서 캐시를 적용하여 성능을 개선한다던가, 초기 캐시레이어를 도입할 때 고민했던 부분들에 대해서 정리해보았다.
  - java, spring 에서의 상황을 기준으로 설명 합니다.
  
## CacheManager 선택
#### 어떤 로컬 캐시를 사용할까?
- https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#cache
  - https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#cache-store-configuration
- ehcache 2, 3
  - 단순 로컬 캐시만으로 사용할 목적이므로 좀 더 심플하고 성능 좋은 걸 사용하고 싶어서 별로라고 생각함...
- caffeine cache
  - https://github.com/ben-manes/caffeine/wiki/Benchmarks
  - 위 성능 외에도 여러 만료정책을 가지고 있고, 비동기 처리 등 기능도 많아서 사용하기 좋아 보임.
  
#### CompositeCacheManager
- redisCacheManager와 caffeineCacheManager 를 `CompositeCacheManager` 를 사용하여 묶어서 처리.
  - 내부 동작을 보니, 묶어서 처리될뿐... local cache -> global cache -> db layer 등과 같이 계층 구성이 가능한 형태는 아니다.

```java
@Bean("compositeCacheManager")
public CacheManager compositeCacheManager(
        @Qualifier("redisCacheManager") CacheManager redisCacheManager,
        @Qualifier("caffeineCacheManager") CacheManager caffeineCacheManager
) {
    CompositeCacheManager manager = new CompositeCacheManager(caffeineCacheManager, redisCacheManager);
    // CompositeCacheManager 에 포함되지 않은 CacheManager 요청을 NoOpCache로 보냄
    manager.setFallbackToNoOpCache(true);
    return manager;
}
```

## 캐싱을 적용할 때...
#### 히트율을 챙기자!
- caffeine cache 를 사용하면 통계를 추가할 수 있다. 카나리 배포하여 hit 와 miss 를 챙긴 다음 ttl 이나 cache 사이즈 등을 고려해볼 수 있다.
  - 기타 다른 cache들도 제공되는 기능들이 있으니 확인해서 눈으로 보고 판단하는게 좋음.
  
#### global cache 의 데이터 갱신을 잘 챙기자!
- 이번 개선 작업에서는 크게 고려될 사항은 아니였지만, global cache 를 세팅하여 사용할 때는 해당 데이터의 ttl 이나 갱신에 대한 전략을 잘 작성해야한다.
- 잘못된 데이터가 계속 제공되서 서비스의 질이 떨어질 수 있다.

#### 모든서버가 같은 데이터를 제공해야하는지
- 모든 서버간의 동기화 목적으로 global cache 를 사용했으나, 사용량이 너무 많은 상황이므로 local cache 의 ttl 을 짧게하여 최대한 데이터가 동기화 될 수 있도록 함.
- 만약 그마저도 잘 맞아야하는 경우라면
  - 이벤트 버스를 구축하여 원본 데이터가 갱신되었을 때, 이벤트를 발행하고 각 서버에서 구독하고 있다가 local cache 를 갱신시키게 하는 방법이 있다.
  - zookeeper 라던가 kafka 를 사용하여 구성할 수 있다.
  
#### 만료일시 등 잘 챙기기
- 만약 12월 31일 23시 59분까지 제공 되어야하는 데이터가 있을 경우 
  - 기존에 db 에서 쿼리로 `endDate < '202212312359'` 동작하게 해놓고 그 로직에 캐시를 달아놓을 경우 캐시가 만료되지 않아 23시 59분 이후에도 캐시가 만료될 때까지 해당 데이터가 제공 될 수 있다.
  - 그럴 때는 캐시에서 데이터를 가지고 온 다음 로직으로 endDate 를 한번 더 체크해서 필터링하여 제공하게 되면 문제될 요소를 제거 할 수 있다.
- 추가로 1월 1일 0시 0분부터 제공되는 데이터의 경우
  - 기존 캐시 데이터가 만료되지 않아 0시 0분부터 모든서버에서 제공이 안될 수 있다.
  - 이럴 경우 `startDate >= '202201010000'` 쿼리에서 `ttl` 만큼 추가로 시작일자를 빼서 `startDate >= '202201010000' - ttl()` 미리 캐시에 올려놓고, 로직으로 필터링하게되면 좀 더 일관된 정보를 적시에 제공할 수 있다.

## Local Cache 를 적용하면서의 고민...
#### size 및 ttl에 대한 고민...
- 일단 각 캐시에 따라서 만료정책들을 잡아야하고, size 및 ttl 등을 고민...
- value 의 크기가 클 경우 size 를 작게 잡아 처리(터질 수도 있음...)
- batch 로 갱신되는 데이터의 경우 batch 주기의 20~30% 정도로 시간 설정

#### 객체 변조 가능성...
- 로컬캐시에서 가져온 값의 내부 값을 변경하게 될 경우 캐시 안에 있는 객체도 같이 변경되기 때문에 추가로 챙겨야한다.
- 대응방안...
  - a. immutable 한 객체를 로컬캐싱하여 사용한다.
  - b. json 으로 `Serialization` 하여 캐싱하고 `Deserialization` 하여 가져다 쓰도록 한다.
  - c. 매번 가져온 값을 deep copy 하여 사용한다.
- b, c 의 경우 개발 비용 뿐만 아니라, 서버 자원도 많이 사용되므로 a 안으로 가기로 함.

- 아래와 같이 localCache 된 값을 가져와서 사용할 때, setter 를 통해 해당 값을 변경해 봄.

```java
ContentEntity entity = contentService.find2(1L);
log.info("entity : {}", entity);

entity.setContent("test");
entity = contentService.find2(1L);
log.info("entity : {}", entity);
```

- `content` 내용이 변경된 entity 가 리턴되는 걸 확인할 수 있음.

```
entity : ContentEntity(id=1, name=Name 1, content=Content 1)
entity : ContentEntity(id=1, name=Name 1, content=test)
```

- 위와 같이 변조가 일어 날 수 있으므로, immutable 한 객체로 캐싱하여 변경이 안되도록 방어.


## Cache 적용해보기 
#### RDB or Redis 조회영역 변경... (단건)
- 단순 key 하나만을 조회해오는 영역
  - 만약 복합적인 조건일 경우 `key` 에 대한 설정 `중요!`
  - cacheManager 는 원하는 쪽으로 설정하면 됨.
  
```java
@Cacheable(cacheNames="book",  key="#id", cacheManager="redisCacheManager")
public Object findBookById(long id) {
  //RDB or Redis get
}
```

## RDB in 절을 사용한 쿼리... or Redis 조회영역 변경 (복수건.... ex. Collection)
- mget 같이 Collection 으로 조회해오는 녀석이 있음.
  - 인기 컨텐츠 등이 포함되어 있을 경우 지연이 발생 할 수 있음.
  - 추가로 DB In 절 등을 사용하여 쿼리할 경우...
- 위에서 작업한 `@Cachable` 을 사용할 경우 Collection에 들어간 녀석들에 따라 다른 캐싱이 잡히고, 유저마다 해당 Collection 에 들어가는 값이 달라질 경우 히트율이 엄청 낮을 것으로 오히려 local cache layer 를 붙이는 부분이 불필요할 수 있음.

- 간단하게 로직을 개발하여 대응
- local cache layer 에서 조회해보고 없는 녀석들만 빼서 `mget` or `db in 절`을  사용하여 데이터 조회,
- 조회한 데이터는 다시 local cache layer 에 추가

```java
/**
 * @param cache : Local Cache
 * @param keys : Keys
 * @param valueClass : Value Class
 * @param keyGenerator : Local Cache Key Generator
 * @param notFoundKeyFinder : Local Cache Miss Finder 
 * @param <K>
 * @param <V>
 * @return
 */
public <K, V> Map<K, V> multiGetWithCache(
	Cache cache,
	Collection<K> keys,
	Class<V> valueClass,
	Function<K, String> keyGenerator,
	Function<Set<K>, Map<K, V>> notFoundKeyFinder
) {
	if (cache == null) {
		throw new IllegalArgumentException("This Cache has not yet been initialised. It cannot be used yet.");
	}

	Set<K> notFoundKeys = new HashSet<>();
	Map<K, V> cacheValuesMap = new HashMap<>();

	for (K key : keys) {
		V cachedValue = cache.get(keyGenerator.apply(key), valueClass);
		if (cachedValue == null) {
			notFoundKeys.add(key);
		} else {
			cacheValuesMap.put(key, cachedValue);
		}
	}

	if (notFoundKeys.size() == 0) {
		return cacheValuesMap;
	}

	Map<K, V> loadedValues = notFoundKeyFinder.apply(notFoundKeys);
	for (Map.Entry<K, V> kvEntry : loadedValues.entrySet()) {
		cache.put(keyGenerator.apply(kvEntry.getKey()), kvEntry.getValue()); //for local cache
		cacheValuesMap.put(kvEntry.getKey(), kvEntry.getValue());
	}

	return cacheValuesMap;
}
```

```java
@Autowired
@Qualifier("caffeineCacheManager")
private CacheManager caffeineCacheManager;

public Set<ContentEntity> findAllWithCache(List<Long> ids) {
	Map<Long, ContentEntity> cachedValueMap = multiKeyCacheService.multiGetWithCache(
		caffeineCacheManager.getCache("contentCache"),
		ids,
		ContentEntity.class,
		String::valueOf,
		notFoundKeys -> contentRepo.findAllByIdIn(notFoundKeys)
			.stream()
			.collect(
				Collectors.toMap(ContentEntity::getId, Function.identity())
			)
	);

	return ids.stream()
		.map(cachedValueMap::get)
		.collect(Collectors.toSet());
}
```

- 단 위의 로직의 경우 컨텐츠가 많을 경우 히트율이 많이 떨어질 수 있어서 LRU 보다 다른 알고리즘을 찾아 적용해보면 더 좋은 효율을 볼 수 있다.