---
layout: post
title:  "BloomFilter 에 대해서 2 - Java 에서 사용하는 방법"
date:   2025-06-09 09:00:00 +0900
categories:
- java
tags:
- bloomfilter
- apache-collections4
- 자료구조
---

- Java 에서 BloomFilter 를 직접 구현하기 보다는 구현되어있는 라이브러리를 이용하여 사용하려고 하다보니, Guava 쪽으로 소개가 많았다.
- 하지만 Guava 를 사용하려고 하니, @Beta 가 붙어 있었고 다른 라이브러리를 찾아야 했다.

- 사용하려고 하는 라이브러리는 `Apache Commons Collections 4` 이다.
> https://commons.apache.org/proper/commons-collections/bloomFilters/implementation.html

- 필요 라이브러리

```gradle
dependencies {
    implementation("org.apache.commons:commons-collections4:4.5.0")
    implementation("commons-codec:commons-codec:1.18") 
}
```


