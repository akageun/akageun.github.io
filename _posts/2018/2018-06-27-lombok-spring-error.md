---
layout: post
title:  "[LOMBOK] constructor ... is already defined in class ... (1.16.22)"
date:   2018-06-27 09:00:00 +0900
categories:
 - spring
tags: 
 - java
 - lombok
---

# 1. 현상
- ***Spring boot 1.5.14*** 로 프로젝트를 세팅하는 중 에러 발생.
- Lombok Annotation 적용해놓은 class에서 컴파일 에러
- Github 이슈함 검색... 버그...

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Sample {
   private String test1;
   private String test2;

}
```

# 2. 해결법
- @NoArgsConstructor 를 @Data 보다 위에 선언해야한다.

```java
@NoArgsConstructor
@AllArgsConstructor
@Data
public class Sample {

   private String test1;
   private String test2;

}
```
---
## * 관련 문서
- https://github.com/rzwitserloot/lombok/issues/1703
