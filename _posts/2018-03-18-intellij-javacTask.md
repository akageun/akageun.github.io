---
layout: post
title:  "[Intellij] javacTask: source release 1.8 requires target release 1.8"
date:   2018-03-08 09:00:00 +0900
categories:
 - tools
tags: 
 - intellij
 - maven
---

## 1. 에러메시지

> Error:java: javacTask: source release 8 requires target release 1.8

## 2. 해결방법
#### 1) 설정변경
- File -> Settings -> Build, Execution, Deployment -> Compiler -> Java Compiler 
- 아래 이미지 내에 'target bytecode version' 옵션 1.8로 변경

![image](https://user-images.githubusercontent.com/13219787/64697609-2a5ad400-d4dc-11e9-9e71-fc0e01479e8b.png)


#### 2) Maven을 사용할 경우
- 아래소스 pom.xml에 추가

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <source>1.8</source>
                <target>1.8</target>
            </configuration>
        </plugin>
    </plugins>
</build>
```
