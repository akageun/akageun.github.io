---
layout: post
title:  "lombok builder 사용시 generic 처리하기"
date:   2019-06-30 09:00:00 +0900
categories:
 - java
tags: 
 - lombok
---

# @builder generic 관련
- lombok으로 builder를 생성하여 사용 하는 경우가 많음.
- generic일 경우 에러가 나서 사용법을 찾아봄.

## Model
```java
import lombok.Builder;

@Builder
public class RequestParam<T> {
	private T body;
}
```

## 사용법
```java
import org.junit.Test;

public class Sample {

	@Test
	public void compileError() {
		RequestParam<String> req =  RequestParam.builder().body("TEST Value").build();
	}

	@Test
	public void success(){
		RequestParam<String> req =  RequestParam.<String>builder().body("TEST Value").build();
	}
}
```

—-
## 참고자료
- https://interviewbubble.com/project-lombok-builder-with-generics/
