---
layout: post
title:  "[Webflux Tip] 2. WebClient 설정(connection pool, timeout)"
date:   2019-06-23 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - webflux
 - reactive
 - tip
 - webclient
---

# WebClient 설정(connection pool, timeout)
## WebClient Connection Pool 설정
- 기본적으로 사용함. 아래 설정을 통해 확인해볼 수 있다.

```yml
logging:
  level:
    reactor:
      netty: debug
```

- 출력 결과

> 2019-xx-xx xx:xx:xx.xxx DEBUG xxxxx --- [ctor-http-nio-6] r.n.resources.PooledConnectionProvider   : [id: 0x19d59db7] Created new pooled channel, now 0 active connections and 2 inactive connections

#### 미사용시
> TcpClient tcpClient = TcpClient.newConnection()

## WebClient Timeout 설정
- 설정코드 

```java
private WebClient getWebclient(int connectionTimeout, int readTimeout, int writeTimeout) {
	TcpClient tcpClient = TcpClient.create()
		.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, connectionTimeout) // Connection Timeout
		.doOnConnected(connection ->
			connection.addHandlerLast(new ReadTimeoutHandler(readTimeout, TimeUnit.MILLISECONDS)) // Read Timeout
				.addHandlerLast(new WriteTimeoutHandler(writeTimeout, TimeUnit.MILLISECONDS))); // Write Timeout

	ClientHttpConnector connector = new ReactorClientHttpConnector(HttpClient.from(tcpClient));

	return WebClient.builder().clientConnector(connector).build();
}
```

- Test code

```java
@Test(expected = io.netty.channel.ConnectTimeoutException.class)
public void connectionTimeoutTest() {
	getWebclient(1, 3000, 3000)
		.get()
		.uri("https://github.com")
		.retrieve()
		.bodyToMono(String.class)
		.block();
}

@Test(expected = io.netty.handler.timeout.ReadTimeoutException.class)
public void readTimeoutTest() {
	getWebclient(3000, 1, 3000)
		.get()
		.uri("https://github.com")
		.retrieve()
		.bodyToMono(String.class)
		.block();
}
```

#### Spring에서 Bean으로 사용할 경우 

```java
@Bean
public WebClient poolWebClient(
) {
	TcpClient tcpClient = TcpClient.create()
		.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 3000) // Connection Timeout
		.doOnConnected(connection ->
			connection.addHandlerLast(new ReadTimeoutHandler(3000, TimeUnit.MILLISECONDS)) // Read Timeout
				.addHandlerLast(new WriteTimeoutHandler(3000, TimeUnit.MILLISECONDS))); // Write Timeout

	ClientHttpConnector connector = new ReactorClientHttpConnector(HttpClient.from(tcpClient));

	return WebClient.builder().clientConnector(connector).build();
}
```

---
## 참고링크
- https://docs.spring.io/spring/docs/5.1.6.RELEASE/spring-framework-reference/web-reactive.html#webflux-client-builder-reactor-timeout
- https://stackoverflow.com/questions/48096573/set-connection-timeout-using-spring-webflux-reactive-webclient/53724661
- https://stackoverflow.com/questions/55617661/how-to-disable-connection-pooling-in-webclient-in-new-springboot-2-1-4-release
- https://github.com/spring-projects/spring-framework/blob/master/src/docs/asciidoc/web/webflux-webclient.adoc
