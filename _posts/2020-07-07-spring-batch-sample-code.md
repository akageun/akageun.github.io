---
layout: post
title:  "[Spring Batch] 간단한 코드로 chunk 구조 쉽게 이해하기."
date:   2020-07-07 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - spring_batch
---

- Spring Batch 에서 `Tasklet`을 사용하지않고, ItemReader, ItemProceesor, ItemWriter 를 사용한 Chunk 개념을 손쉽게 이해하기 위해 간단하게 구현해본 소스
- 아래 구현한 소스 외에도 `Spring batch` 에는 엄청 많은 기능들이 구현되어 있다.

## Reader
- 데이터를 읽어오는 곳
- reader에서는 한건씩 다음 단계인 Processor로 데이터를 넘긴다.

```java
public static InputModel itemReader() {
	return itemForReader.poll();
}
```

- reader 에서 데이터가 넘어오지 않으면 해당 `Step` 은 멈춘다.

```java
if (readerItem == null) {
	log.info("item empty!!");
	isExistItem = false;
	break;
}
```

## Processor
- 데이터를 가공하는 곳
- Reader에서 받은 데이터(`InputModel`) 를 가공하여 Writer로 넘긴다.(`OutputModel`).

```java
public static OutputModel itemProcessor(InputModel item) {
	return new OutputModel(item.language, item.language.length());
}
```

- `null` 을 리턴하게되면, 필터링 된다.(해당 Item은 writer로 넘어가지 않음)

```java
if (processedItem != null) { //processor 에서 null 로 넘오는 것들은 필터링.
	items.add(processedItem);
}
```

## Writer
- `ChunkSize` 만큼 Collection으로 Item이 넘어온다.

```java
public static void itemWriter(Collection<OutputModel> items) throws Exception {
	log.info("items.size() : {}, items : {}", items.size(), items);
}
```

## ChunkSize
- `ChunkSize`는 한번에 처리될 트랜잭션 단위
	- `Exception`이 발생했을 때, `ChunkSize` 만큼만 데이터가 날아감.

```java
try {
	itemWriter(items);  
} catch (Exception e) {
	log.error(e.getMessage(), e);
}
```

## 전체소스

```java

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class SpringBatchChunk {

	private static final int chunkSize = 3;
	private LinkedList<InputModel> itemForReader = new LinkedList<>();

	public static void main(String[] args) {
		itemForReader.add(new InputModel("java"));
		itemForReader.add(new InputModel("javascript"));
		itemForReader.add(new InputModel("typescript"));
		itemForReader.add(new InputModel("python"));
		itemForReader.add(new InputModel("go lang"));
		itemForReader.add(new InputModel("swift"));
		itemForReader.add(new InputModel("kotlin"));
		itemForReader.add(new InputModel("c"));
		itemForReader.add(new InputModel("c++"));
		itemForReader.add(new InputModel("php"));
		itemForReader.add(new InputModel("erlang"));
		itemForReader.add(new InputModel("ruby"));
		itemForReader.add(new InputModel("scala"));
	    
	    
		int readerCount = 0;
		int writerCount = 0;

		boolean isExistItem = true;
		while (isExistItem) {
			List<OutputModel> items = new ArrayList<>();

			for (int chunkIndex = 0; chunkIndex < chunkSize; chunkIndex++) {
				InputModel readerItem = itemReader();
				if (readerItem == null) {
					log.info("item empty!!");
					isExistItem = false;
					break;
				}
				readerCount += 1;
				OutputModel processedItem = itemProcessor(readerItem);
				if (processedItem != null) {
					items.add(processedItem);
				}
			}

			log.info("Chunk!! item.size() : {}", items.size());

			try {
				itemWriter(items);  //Chunk Size는 한번에 처리될 트랜잭션 단위
				writerCount += items.size();

			} catch (Exception e) {
				log.error(e.getMessage(), e);
			}
		}

		log.info("readCount : {}, writerCount : {}", readerCount, writerCount);
	}

	/**
	 * 아이템을 한개씩 리턴한다.
	 *
	 * @return
	 */
	public static InputModel itemReader() {
		return itemForReader.poll();
	}

	/**
	 * item 을 가공하는 역할을 한다.
	 *
	 * @param item
	 * @return
	 */
	public static OutputModel itemProcessor(InputModel item) {
		if ("erlang".equals(item.language)) { // 샘플 코드
			return null;
		}

		return new OutputModel(item.language, item.language.length());
	}

	/**
	 * Chunk 만큼 item들을 받아 처리함
	 *
	 * @param items
	 */
	public static void itemWriter(Collection<OutputModel> items) throws Exception {
		if (items.stream().anyMatch(outputModel -> outputModel.language.equals("kotlin"))) {
			throw new Exception("javascript Exception");
		}

		log.info("items.size() : {}, items : {}", items.size(), items);
	}

	private static class InputModel {
		private String language;

		public InputModel(String language) {
			this.language = language;
		}
	}

	private static class OutputModel {
		private String language;
		private int length;

		public OutputModel(String language, int length) {
			this.language = language;
			this.length = length;
		}
	}
}

```

#### 실행 결과

> SpringBatchChunk - readCount : 13, writerCount : 9
