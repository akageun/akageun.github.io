---
layout: post
title:  "Netty Base 로 이용할 경우, URL 길이 제한 문제 해결 방법"
date:   2024-09-19 09:00:00 +0900
categories:
- netty
tags:
- spring-boot
- netty
- spring-webflux
---

- `GET` 요청에 `413 Payload To Large` 응답이 발생할 때 대응 방법.
- Spring Webflux 등에서 Netty Base 로 이용할 경우 발생할 수 있다.

- `maxInitialLineLength` 설정값은 Http Request 에서 가장 첫 줄의 최대 길이 값이다.
    - 그러므로 `GET` 요청시에 파라미터가 길거나 하면, 첫 라인이 길어지므로 413 처리가 된다.
    - [문서](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview#requests) 를 참고

## Netty 기본 설정값
```java
protected int maxInitialLineLength = DEFAULT_MAX_INITIAL_LINE_LENGTH;

public static final int DEFAULT_MAX_INITIAL_LINE_LENGTH = 4096; 
```

## 대응 방법 1안
```java
@Component
public class WebConfiguration implements WebServerFactoryCustomizer<NettyReactiveWebServerFactory> {


    @Override
    public void customize(NettyReactiveWebServerFactory serverFactory) {
        serverFactory.addServerCustomizers(httpServer -> httpServer.httpRequestDecoder(

//https://netty.io/4.0/api/io/netty/handler/codec/http/HttpRequestDecoder.html
            httpRequestDecoderSpec -> httpRequestDecoderSpec
                .maxInitialLineLength(40960) //10배
        ));
    }
}
```

## 대응 방법 2안
- application.yaml

```yml
server:
  netty:
    max-initial-line-length: 40KB
```

