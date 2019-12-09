---
layout: post
title:  "[Intellij] Command line is too long. Shorten command line for Application or also for Spring Boot default configuration."
date:   2019-12-04 09:00:00 +0900
categories:
 - tools
tags: 
 - intellij
---

- Intelli J 에서 Spring Boot 빌드할려고 했더니... 아래와 같은 오류가 뜬다.

> Command line is too long. Shorten command line for Application or also for Spring Boot default configuration.

## 해결법
- 프로젝트 내에 `.idea/workspace.xml` 에 있는 `<component name="PropertiesComponent">` 안에  아래와 같이 추가한다.

```xml
<component name="PropertiesComponent">
     <property name="dynamic.classpath" value="true"/>
</component>
```

