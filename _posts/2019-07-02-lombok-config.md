---
layout: post
title:  "lombok.config 사용하기"
date:   2019-07-02 00:00:00 +0900
categories:
 - java
tags: 
 - lombok
---

# lombok.config 사용하기
- 실무에서 팀내 우리는 `@AllArgsConstructor` 를 사용하지말자! 등의 컨벤션을 지정할 때 도움이 됨.
- Warning 또는 빌드시 error를 낼 수 있음

## 기본 구조
> lombok.{어노테이션}.flagUsage=warning or error

#### 예시
```properties
lombok.AllArgsConstructor.flagUsage=error
lombok.val.flagUsage=error
lombok.var.flagUsage=error
```

## 우리가 필요한 log 옵션만 사용하기
- @log, @log4j 등 미사용 로그 관련 annotation이 많음
- 미사용 중인 logger를 사용하게 되면 빌드시 error 발생
```properties
lombok.log.apacheCommons.flagUsage=error
lombok.log.log4j.flagUsage=error
lombok.log.log4j2.flagUsage=error
lombok.log.xslf4j.flagUsage=error
```

## @Slf4j 등 log를 통해 자동생성되는 객체이름 변경
- default로 설정되는 `log` 를 원하는 다른걸로 변경 가능하다.
```properties
lombok.log.fieldName=LOG
lombok.log.fieldIsStatic=false # logger를 static이 아닌 필드로 생성
```

