---
layout: post
title:  "[Spring Batch Tip] 1. Job Id 가지고 오기"
date:   2018-05-03 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - spring_batch
---
# 1. Job 정보 가지고 오기.
- 개발하는 중에 ItemReader, ItemProcessor, ItemWriter 등에서 job정보를 가지고 와야 할 때가 있다.
- 간단한 소스 추가로 사용 가능하다.

# 2. 소스

```java
private Long jobId;

@BeforeStep
public void getInterstepData(StepExecution stepExecution) {
   JobExecution jobExecution = stepExecution.getJobExecution();
   this.jobId = jobExecution.getJobId();
}
```

- 비슷한 방식으로 확장해서 사용 가능 할 듯.

