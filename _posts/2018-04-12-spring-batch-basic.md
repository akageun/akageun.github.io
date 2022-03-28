---
layout: post
title:  "[Spring Batch] 1. 알아보자"
date:   2018-04-12 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - spring-batch
---
# 1. Spring Batch
## 1) Spring batch란? 
- Spring Batch는 Job과 Step으로 구성되어 있음.
- 하나의 Spring Batch안에는 여러 Job이 존재 할 수 있고, 그 Job 안에는 여러 개의 Step 또는 Tasklet을 존재 할 수 있음.
- Job -> Step -> ItemReader - ItemProcessor - ItemWriter

![image](https://user-images.githubusercontent.com/13219787/61384585-df617d80-a8eb-11e9-9bb6-3ef8612a7741.png)

- https://docs.spring.io/spring-batch/trunk/reference/htmlsingle/#domain 에서 가져온 이미지 입니다.

## 2) 장점
- 간단하게 대용량 배치를 만들 수 있다.
- 이미 만들어진 많은 모듈들을 사용해서 손쉽게 구현가능(CSV 파싱, DB에서 가지고 오기, S3 등에 파일업로드 등)

## 3) 단점
- 어렵다.(배우면 된다.)

# 2. Class 설명
## 1) ItemReader
- Step 안에서 데이터를 가져오는 역할을 하는 Class이다.
- 하나의 아이템이 리턴되거나 null

```java
package org.springframework.batch.item;

/**
 * Strategy interface for providing the data. <br>
 * 
 * Implementations are expected to be stateful and will be called multiple times
 * for each batch, with each call to {@link #read()} returning a different value
 * and finally returning <code>null</code> when all input data is exhausted.<br>
 * 
 * Implementations need <b>not</b> be thread-safe and clients of a {@link ItemReader}
 * need to be aware that this is the case.<br>
 * 
 * A richer interface (e.g. with a look ahead or peek) is not feasible because
 * we need to support transactions in an asynchronous batch.
 * 
 * @author Rob Harrop
 * @author Dave Syer
 * @author Lucas Ward
 * @since 1.0
 */
public interface ItemReader<T> {

   /**
    * Reads a piece of input data and advance to the next one. Implementations
    * <strong>must</strong> return <code>null</code> at the end of the input
    * data set. In a transactional setting, caller might get the same item
    * twice from successive calls (or otherwise), if the first call was in a
    * transaction that rolled back.
    * 
    * @throws ParseException if there is a problem parsing the current record
    * (but the next one may still be valid)
    * @throws NonTransientResourceException if there is a fatal exception in
    * the underlying resource. After throwing this exception implementations
    * should endeavour to return null from subsequent calls to read.
    * @throws UnexpectedInputException if there is an uncategorised problem
    * with the input data. Assume potentially transient, so subsequent calls to
    * read might succeed.
    * @throws Exception if an there is a non-specific error.
    * @return T the item to be processed
    */
   T read() throws Exception, UnexpectedInputException, ParseException, NonTransientResourceException;

}
```

## 2) ItemProcessor
- Step 안에서 가져온 데이터를 가공하는 역할을 하는 Class이다.
- Chunk 사이즈 만큼 Item들이 List로 들어온다.

```java
package org.springframework.batch.item;

/**
 * Interface for item transformation.  Given an item as input, this interface provides
 * an extension point which allows for the application of business logic in an item 
 * oriented processing scenario.  It should be noted that while it's possible to return
 * a different type than the one provided, it's not strictly necessary.  Furthermore, 
 * returning null indicates that the item should not be continued to be processed.
 *  
 * @author Robert Kasanicky
 * @author Dave Syer
 */
public interface ItemProcessor<I, O> {

   /**
    * Process the provided item, returning a potentially modified or new item for continued
    * processing.  If the returned result is null, it is assumed that processing of the item
    * should not continue.
    * 
    * @param item to be processed
    * @return potentially modified or new item for continued processing, null if processing of the 
    *  provided item should not continue.
    * @throws Exception
    */
   O process(I item) throws Exception;
}

```

## 3) ItemWriter
- Step 안에서 데이터를 쓰는 역할을 하는 Class이다.

```java
package org.springframework.batch.item;

import java.util.List;

/**
 * <p>
 * Basic interface for generic output operations. Class implementing this
 * interface will be responsible for serializing objects as necessary.
 * Generally, it is responsibility of implementing class to decide which
 * technology to use for mapping and how it should be configured.
 * </p>
 * 
 * <p>
 * The write method is responsible for making sure that any internal buffers are
 * flushed. If a transaction is active it will also usually be necessary to
 * discard the output on a subsequent rollback. The resource to which the writer
 * is sending data should normally be able to handle this itself.
 * </p>
 * 
 * @author Dave Syer
 * @author Lucas Ward
 */
public interface ItemWriter<T> {

   /**
    * Process the supplied data element. Will not be called with any null items
    * in normal operation.
    *
    * @param items items to be written
    * @throws Exception if there are errors. The framework will catch the
    * exception and convert or rethrow it as appropriate.
    */
   void write(List<? extends T> items) throws Exception;

}
```

# 3. 간단 용어 설명
## 1) Item 
- 데이터의 가장 작은 구성 요소를 말함.

## 2) Chunk
- commit-interval
- ItemReader 읽은 데이터를 Processor 통해 가공 한 후 ItemWriter 넘겨지는 갯수를 의미함.
- 트랜젝션이 걸려 있다면 한 트랜젝션 안에서 처리할 Item의 수이다.

# 4. 옵션
## 1) 옵션 설명
- spring.batch.initializer.enabled : Spring Batch 실행시에 Database 내 Table create 등 실행여부
- spring.batch.job.enabled : Spring Batch 실행시에 Context내 모든 Job들 실행 여부
- spring.batch.job.names : 실행할 Job 리스트, 콤마(,)로 구분한다.
- spring.batch.schema : db 스키마 초기화 sql파일 위치 (바로가기)
- spring.batch.table-prefix : 테이블명 앞에 붙일 명칭

## 2) 설정
- application.properties

```properties
spring.batch.initializer.enabled=false
spring.batch.job.enabled=false
spring.batch.job.names=test1,test2,test3
spring.batch.schema=org/springframework/batch/core/schema-h2.sql
spring.batch.table-prefix=tmp_
```
  
- application.yml

```yaml
spring:
  batch:
    schema: org/springframework/batch/core/schema-h2.sql
    table-prefix: tmp_
    initializer:
      enabled: false
    job:
      enabled: false
      names: test1,test2,test3
```
  
---
## 참고자료
- https://projects.spring.io/spring-batch/
- https://docs.spring.io/spring-batch/3.0.x/reference/html/index.html
- https://docs.spring.io/spring-batch/trunk/reference/html/listOfReadersAndWriters.html
