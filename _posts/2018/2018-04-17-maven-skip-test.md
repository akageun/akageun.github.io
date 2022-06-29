---
layout: post
title:  "Maven Test Skip 하는 법"
date:   2018-04-17 09:00:00 +0900
categories:
 - tools
tags: 
 - maven
---

# 1. Test Skip하고 싶다.
- 오래걸리는 작업을 넘기고 싶다.

# 2. Skip하는 법
## 1) 명령어

> mvn [install....] -DskipTests 

or

> mvn [install....] -Dmaven.test.skip=true

## 2) pom.xml
```xml
<properties>
   <maven.test.skip>true</maven.test.skip>
</properties>
```