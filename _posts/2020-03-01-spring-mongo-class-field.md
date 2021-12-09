---
layout: post
title:  "Spring에서 mongo 에 데이터 추가시 생기는 class 에 대해서"
date:   2020-03-01 09:00:00 +0900
categories:
 - spring
tags: 
 - mongodb
 - spring_boot
---

- Spring Boot 자동설정으로 mongo를 사용할 경우 _class 값이 저장되는 결과값에 추가 됨.

## _class 추가 확인 

#### java 소스

```java
MongoRepository.save(new ObjectEntity());

or

MongoOperations ops = new MongoTemplate(new Mongo(), "users");
ops.insert(new ObjectEntity());

```

#### mongo DB find
```json
{ "_id" : ObjectId("5e5b8c7600871a0c570885a1"), "title" : "test", "content" : "content!!", "_class" : "kr.geun.sample.ObjectEntity" }
```

## Spring Boot Bean 설정 확인

#### MongoConverter 변경하는 방법
- `org.springframework.boot.autoconfigure.data.mongo.MongoDataAutoConfiguration` 를 확인
- 위 설정 클래스 내에 있는 `MongoDbFactoryDependentConfiguration` 를 확인

```java
   @Bean
    @ConditionalOnMissingBean({MongoConverter.class})
    MappingMongoConverter mappingMongoConverter(MongoDbFactory factory, MongoMappingContext context, MongoCustomConversions conversions) {
        DbRefResolver dbRefResolver = new DefaultDbRefResolver(factory);
        MappingMongoConverter mappingConverter = new MappingMongoConverter(dbRefResolver, context);
        mappingConverter.setCustomConversions(conversions);
        return mappingConverter;
    }
```

###### 위 @Bean 설정을 변경하자
- 아래 메소드를 추가하자.

> mappingConverter.setTypeMapper(new DefaultMongoTypeMapper(null)); 


#### MongoTemplate 설정을 변경하는 법
```java
@Bean
public MongoTemplate mongoTemplate() throws Exception {

    DbRefResolver resolver = new DefaultDbRefResolver(mongoDbFactory);

    // Remove _class
    MappingMongoConverter converter = new MappingMongoConverter(resolver, new MongoMappingContext());
    converter.setTypeMapper(new DefaultMongoTypeMapper(null));

    return new MongoTemplate(mongoDBFactory(), converter);

}
```
