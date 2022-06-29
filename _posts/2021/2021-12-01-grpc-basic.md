---
layout: post
title: "[GRPC] 1. GRPC 살펴보기"
date: 2021-12-01 09:00:00 +0900
categories:
- grpc
tags:
- grpc
- protobuf
- idl
---

# GRPC 란?
- Google 에서 만든 RPC
  - Google Remote Procedure Call
- 다른 RPC 와 같이 IDL(interface definition language) 를 이용하여 정의함.

## 살펴보기 전에...
#### IDL
- Interface definition language
- 어느 한 언어에 국한되지 않는 언어중립적인 방법으로 인터페이스를 표현함으로써, 같은 언어를 사용하지 않는 소프트웨어 컴포넌트 사이의 통신을 가능하게 함.
  - https://ko.wikipedia.org/wiki/%EC%9D%B8%ED%84%B0%ED%8E%98%EC%9D%B4%EC%8A%A4_%EC%A0%95%EC%9D%98_%EC%96%B8%EC%96%B4

#### RPC 란?
- 네트워크로 연결된 서버 상의 프로시저를 원격으로 호출할 수 있는 기능.
- IDL(Interface Definition Language) 기반으로 다양한 언어를 가진 환경에서도 쉽게 확장 가능.
  - 대표적인 구현체는 `GRPC`, [Facebook의 Thrift](https://thrift.apache.org/), [Twitter의 Finalge](https://twitter.github.io/finagle/)
- Stub(스텁)
  - Stub Compiler가 IDL 파일을 읽어 원하는 Language로 생성.
  - Parameter Object를 Message로 marshalling/unmarshalling하는 Layer

#### HTTP/2
- http/1 와 차이점
  - 클라이언트 -> 서버
  - 요청 단위로 클라이언트와 서버를 왕복
    - 요청이 올때만 전달 가능.
  - 쿠키 등을 포함한 header 가 무거움
- http/2 의 장점
  - Header compression
    - header table 과 huffman encoding 기법을 사용하여 헤더정보를 압축
  - Multiplexed Streams
    - http/1 에서는 요청단위로 커넥션 생성하지만, http/2 에서는 한개의 커넥션으로 여러개의 메시지를 동시에 주고 받을 수 있음.
  - Server Push
    - 요청없이도 서버가 리소스를 보낼 수 있음.
    - 클라이언트 요청을 최소화 할 수 있음.

#### ProtoBuf
- grpc 에서 idl 로 사용함.
  - 데이터 직렬화 라이브러리로 사용
- 구글에서 만들었음.
- 바이너리로 직렬화된 메시지를 교환하므로 텍스트 기반의 Json이나 Xml 에 비해 크기가 작음.
  - 직렬화 등의 비용이 적게 들어감.
- proto 파일을 통해 protoc 컴파일러를 통해 소스코드 생성
- 뒤에서 좀 더 자세하게 작성 예정...

- 기본구조
  - syntax : proto 버전, default proto2
  - package : 여기에 정의된 패키지로 stub 이 생성된다.
  - service : 실제 서비스를 정의하고 인터페이스를 이안에서 정의.
  - rpc : 메소드 인터페이스, request, response, stream 등 키워드로 정의
  - message : rpc 통신을 할 때 주고 받을 모델 정의

## GRPC 장점
- 유지보수하기가 쉽다.
  - Protocol Buffers 를 사용
  - 자동으로 소스 생성
- 다양한 언어와 플랫폼을 지원함.
  - 공식적으로 지원하는 언어는 https://www.grpc.io/docs/languages/ 참고.
- Http/2 기반으로 양방향 스트리밍 가능
- ....

## GRPC 단점
- protobuf http/2 에 대한 러닝커브가 있음.
- 기존 rest api 와 다르게 메시지가 바이너리로 전달되기 때문에 테스트가 쉽지 않음.
- 메시지 구조 등이 많이 변할 경우, 놓치는 부분이 생길 수 있으므로 CI 등을 도입하여 안정성을 확보할 필요가 있다.
  - 개발 프로세스 복잡도가 증가할 수 있음.

## GRPC  lifecycle
- 총 4가지 방식이 있음.
- Client-Side 에서는 Marshaling(마샬링)을 수행
- Server-Side 에서는 Unmarshaling(언마샬링)을 수행
- https://grpc.io/docs/what-is-grpc/core-concepts
    
#### Unary RPC
- 클라이언트에서 서버로 `단일 요청`, 서버는 `단일 응답` 하는 형태

```proto
rpc xxx(yyyRequest) returns (zzzResponse);
```

#### Server Streaming RPC
- 클라이언트에서 서버로 `단일 요청`, 서버는 `연속적인 스트림 응답` 하는 형태
- 클라이언트는 완료처리가 될때까지 스트림 데이터를 수신함.

```proto
rpc xxx(yyyRequest) returns (stream zzzResponse);
```

#### Client Streaming RPC
- 클라이언트에서 서버로 `연속적인 스트림 요청`, 서버는 `단일 응답`하는 형태
- 서버는 완료처리 될때까지 스트림 데이터를 수신함.
  - 수신 도중 스트림을 취소하여 클라이언트의 메시지를 조기에 중단 할 수 있음.

```proto
rpc xxx(stream yyyRequest) returns (zzzResponse);
```

#### Bidirectional Streaming RPC
- 클라이언트, 서버 모두 독립적으로 동작하는 스트림을 이용하여 서로가 서로에게 완료처리가 될때까지 연속적인 스트림을 전달.

```proto
rpc xxx(stream yyyRequest) returns (stream zzzResponse);
```

## 클라이언트 Stub
- https://grpc.io/docs/languages/java/generated-code/#client-stubs

#### Asynchronous Stub
- 모든 방식의 RPC 사용 가능
  
- Java 에서 생성하는 법

```java 
ServiceNameGrpc.newStub(Channel channel)
```

#### Blocking Stub
- Unary RPC, Server Streaming RPC 만 사용가능

- Java 에서 생성하는 법

```java 
ServiceNameGrpc.newBlockingStub(Channel channel)
```

#### Future Stub
- Streaming 호출을 지원하지 않음.
- Unary RPC 만 사용 가능.
  
- Java 에서 생성하는 법

```java 
ServiceNameGrpc.newFutureStub(Channel channel)
```

## 추가로...
#### 외부 Rest API 를 제공할 경우
- https://github.com/grpc-ecosystem/grpc-gateway
- grpc-gateway 를 사용하면 제공 가능.

#### GRPC vs REST
- protobuf vs json or xml
- http 버전
  - http/2 의 장점...
  - 이건 뭐 올리면 될 것 같은데...
- ....

---
## 참고링크
- https://nesoy.github.io/articles/2019-07/RPC
- https://meetup.toast.com/posts/261
