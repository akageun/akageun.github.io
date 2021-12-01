---
layout: post
title: "[GRPC] 2. Java 나 Spring 에서 GRPC 사용해보기."
date: 2021-12-01 10:00:00 +0900
categories:
- grpc
tags:
- grpc
- protobuf
- idl
- spring
- java
---

## Java에서 사용해보기
#### build.gradle
```gradle
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.google.protobuf:protobuf-gradle-plugin:0.8.16'
    }
}

plugins {
    id 'java'
    id 'com.google.protobuf' version '0.8.16'
}

group 'kr.geun'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'io.grpc:grpc-netty:1.38.0'
    implementation 'io.grpc:grpc-protobuf:1.38.0'
    implementation 'io.grpc:grpc-stub:1.38.0'
    implementation 'com.google.protobuf:protobuf-java:3.17.3'

    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.7.0'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.7.0'
}

protobuf {
    protoc {
        artifact = 'com.google.protobuf:protoc:3.17.3'
    }
    plugins {
        grpc {
            artifact = 'io.grpc:protoc-gen-grpc-java:1.38.0'
        }
    }
    generateProtoTasks {
        all()*.plugins {
            grpc {}
        }
    }
}

sourceSets {
    main {
        java {
            srcDirs 'build/generated/source/proto/main/grpc'
            srcDirs 'build/generated/source/proto/main/java'
        }
    }
}

test {
    useJUnitPlatform()
}
```

#### protobuf :
- src/main/proto
  
```protobuf
syntax = "proto3";
package kr.geun.grpc;

option java_multiple_files = true;
option java_package = "kr.geun.grpc";

service HelloWorldService {
  rpc SayHello (HelloRequest) returns (HelloResponse) {
  }
}

message HelloRequest {
  string name = 1;
}

message HelloResponse {
  string message = 1;
}
```    
- protobuf 파일 생성 

> ./gradlew clean \
> ./gradlew generateProto

#### server : GrpcServerApplication
```java
public class GrpcServerApplication {
    public static void main(String[] args) {
        Thread serverThread = new Thread(() -> {
            int port = 8080;
            Server server = ServerBuilder
                .forPort(port)
                .addService(new HelloWorldServiceImpl())
                .build();

            try {
                server.start();
            } catch (IOException e) {
                e.printStackTrace();
                return;
            }

            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                System.err.println("Server: Shutting down gRPC server");
                server.shutdown();
                System.err.println("Server: Server shut down");
            }));

            try {
                server.awaitTermination();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        serverThread.start();
    }
}
```

#### client : GrpcClientApplication
```java
public class GrpcClientApplication {

	public static void main(String[] args) {
		ManagedChannel channel = ManagedChannelBuilder
			.forAddress("localhost", 8080)
			.usePlaintext()
			.build();

		HelloWorldServiceGrpc.HelloWorldServiceBlockingStub stub = HelloWorldServiceGrpc.newBlockingStub(channel);

		System.out.println("connection!");

		HelloResponse response = stub.sayHello(HelloRequest.newBuilder()
			.setName("Name!!!")
			.build());

		System.out.println("Client: " + response.getMessage());

		channel.shutdown();

		System.out.println("Close");
		Runtime.getRuntime().exit(0);
	}
}
```

## Spring 에서 사용하기
- client 는 기본적이 spring boot 를 사용
- server 는 spring DI 와 함께 여러 GRPC 등의 프로토콜을 사용할 수 있는 armeria 를 사용
  - https://armeria.dev/
  - 자세한건 따로 포스팅할 예정
- https://github.com/akageun/spring-boot-study-grpc


