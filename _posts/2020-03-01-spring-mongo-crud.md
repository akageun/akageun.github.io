---
layout: post
title:  "Spring Boot 에서 MongoDB CRUD 만들기! "
date:   2020-03-01 09:00:00 +0900
categories:
 - spring
tags: 
 - mongo
 - spring boot
---

# Spring Boot 에서 MongoDB CRUD 만들기!

## 기본 세팅
#### 라이브러리 추가
- pom.xml

```xml
 <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

#### application.yml
```yaml
spring:
    data:
        mongodb:
            host: localhost
            port: 27017
            database: test_docs
``` 

## 기본 소스코드 만들기
#### entity
```java
@Getter
@NoArgsConstructor(access = AccessLevel.PRIVATE)
@Document(collection = "new_collections")
@ToString
public class TestCollections {

    @Id
    private Long id;
    private String name;
    private String address;

    @Builder
    public TestCollections(Long id, String name, String address) {
        this.id = id;
        this.name = name;
        this.address = address;
    }
}
```

#### repository
```java
public interface TestCollectionsRepo extends MongoRepository<TestCollections, Long> {
}
```

## CRUD 만들기
#### Create or Update

###### 몽고쿼리
```
db.new_collections.insert([
    {
        "name" : "철수",
        "address" : "서울"
    }
])
```

###### Java
```java
@Autowired
private MongoTemplate mongoTemplate;

@Autowired
private TestCollectionsRepo testCollectionsRepo;

private void insert() {
    TestCollections entity = TestCollections.builder()
        .name("철수")
        .address("서울")
        .build();
    
    //Repository 버전
    testCollectionsRepo.save(entity);

    //mongoTemplate 버전
    mongoTemplate.insert(entity);
}
```

#### Read - Find All
###### 몽고쿼리
```
db.new_collections.find()

//.pretty() 를 넣을 경우 이쁘게 나온다.
db.new_collections.find().pretty()
```

###### Java
```java
private void selectAll() {
    //Repository 버전
    List<TestCollections> list_1 = testCollectionsRepo.findAll();

    //mongoTemplate 버전
    List<TestCollections> list_2 = mongoTemplate.findAll(TestCollections.class);
}
```

#### Read - Paging 
###### 몽고쿼리
```
// Page 1
db.new_collections.find().limit(5)

// Page 2
db.new_collections.find().skip(5).limit(5)

// Page 3
db.new_collections.find().skip(5).limit(5)
```

###### Java
```java
private void selectPaging() {
    Pageable pageable = PageRequest.of(0, 10);

    //Repository 버전
    Page<TestCollections> page_1 = testCollectionsRepo.findAll(pageable);

    Query query = new Query().with(pageable);
    List<TestCollections> list = mongoTemplate.find(query, TestCollections.class);
    
    //mongoTemplate 버전
    Page<TestCollections> page_2 = PageableExecutionUtils.getPage(
        list,
        pageable,
        () -> mongoTemplate.count(new Query().limit(-1).skip(-1), TestCollections.class));
}
```

#### Delete
###### 몽고쿼리
```
db.new_collections.deleteOne( { name: "철수" } )
```

###### Java
```java
//Repo 에 method 추가
void deleteByName(String name);

testCollectionsRepo.deleteByName("철수");
```
