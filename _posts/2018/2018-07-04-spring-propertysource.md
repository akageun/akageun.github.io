---
layout: post
title:  "@PropertySource 사용시 한글 깨짐"
date:   2018-07-04 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
---
# 1. 현상
- 아래와 같은 소스를 사용할 경우

```java
@PropertySource(value = {"classpath:common.properties"})
```

- 아래와 같이 호출할 경우,한글이 깨진다.

```java
@Autowired
private Environment env;


private void test(){
   env.getRequiredProperty("test");
}
```

# 2. 해결법
```java
@PropertySource(value = {"classpath:common.properties"}, encoding = "UTF-8")
```

- 간단한 해결 법이지만 기억하기 위해 기록해 놓는다.