---
layout: post
title:  "Fluentd 와 Fluent Bit 차이 알아보기"
date:   2025-10-16 20:03:44 +0900
categories:
- observability
tags:
- fluentd
- fluent-bit
- logging
- kubernetes
- cncf
---

- Application과 Server가 많아지면 각 장비의 로그 파일을 직접 확인하기 어렵다.
- 로그를 한곳에 모으려면 데이터를 읽고, 필요한 형태로 가공하고, 저장소로 전달하는 수집 계층이 필요하다.
- 이때 자주 사용하는 도구가 `Fluentd`와 `Fluent Bit`이다.
- 이름과 설정 방식이 비슷하지만 지향하는 실행 환경과 확장 방식에는 차이가 있다.

# Fluentd 와 Fluent Bit 란?

- Fluentd와 Fluent Bit은 다양한 Source에서 Telemetry Data를 수집하고 가공한 뒤 여러 Destination으로 전달하는 오픈소스 도구다.
- 두 프로젝트 모두 CNCF Graduated Project이며 Apache License 2.0을 사용한다.
- 주로 로그 수집기로 알려져 있지만 Fluent Bit은 Log뿐 아니라 Metric과 Trace도 지원한다.

```text
Input -> Parse -> Filter -> Buffer -> Route -> Output
```

- 예를 들면 아래와 같은 Pipeline을 구성할 수 있다.

```text
Container Log
  -> Fluent Bit
      -> Parse JSON
      -> Add Kubernetes Metadata
      -> Elasticsearch / OpenSearch / Kafka
```

# 공통점

- Input, Parser, Filter, Output Plugin으로 Pipeline을 구성한다.
- Event에 Tag를 붙이고 Match Rule로 전달할 Output을 결정한다.
- Memory 또는 File System을 이용한 Buffering을 지원한다.
- Destination 장애에 대비한 Retry와 Backpressure 처리 기능을 제공한다.
- 하나의 입력 데이터를 여러 Output으로 전달할 수 있다.
- Forward Protocol을 통해 서로 연결할 수 있다.

# 주요 차이점

| 항목 | Fluent Bit | Fluentd |
| --- | --- | --- |
| 구현 언어 | C | C와 Ruby |
| 기본 방향 | 낮은 자원 사용량과 높은 처리량 | 풍부한 Plugin 생태계와 유연한 Pipeline |
| 배포 위치 | Kubernetes Node, Container, Edge, Server | Server, 중앙 또는 지역 Aggregator |
| Plugin | 내장 Plugin 중심 | Core와 외부 Ruby Gem Plugin 생태계 |
| 확장 방식 | C, Wasm, Lua Filter, Go Output 등 | Ruby 기반 Custom Plugin |
| 설정 형식 | Classic Mode, YAML | Fluentd Configuration DSL |
| Buffer 제어 | Memory와 File System Storage | Chunk Key, Flush, Retry 등 세밀한 Buffer 설정 |

- 위 표는 일반적인 선택 기준일 뿐 역할을 강제하는 구분은 아니다.
- 공식 문서에서도 Fluent Bit과 Fluentd 모두 Forwarder 또는 Aggregator로 사용할 수 있다고 설명한다.
- 최근 Fluent Bit도 Filter, Routing, Buffering, Stream Processing 기능이 확장되었기 때문에 단순히 `Fluent Bit은 전달만 하고 Fluentd는 가공만 한다`고 구분하면 정확하지 않다.

# Fluent Bit

- Fluent Bit은 낮은 Memory 사용량과 높은 처리량에 초점을 맞춘 Telemetry Agent다.
- C로 구현되었으며 별도의 Ruby Runtime이 필요하지 않다.
- 제한된 자원을 사용하는 Edge Device부터 Kubernetes Node까지 폭넓게 배치할 수 있다.

## 잘 맞는 환경

- Kubernetes의 Node마다 DaemonSet으로 로그를 수집하는 경우
- Application Pod 옆의 Sidecar로 실행하는 경우
- Server 또는 VM에 Agent를 배포하는 경우
- IoT와 Edge처럼 CPU와 Memory가 제한된 환경
- 복잡한 변환보다 수집과 전달의 처리량이 중요한 경우

## Pipeline

- Fluent Bit의 주요 처리 단계는 아래와 같다.

```text
INPUT -> PARSER -> FILTER -> BUFFER -> OUTPUT
```

- Input에서 들어온 Record에는 Tag가 지정된다.
- Filter는 Record에 값을 추가하거나 제거하고, 조건에 따라 Record를 제외한다.
- Output의 `Match`가 Tag와 일치하면 해당 Destination으로 전달한다.
- 일치하는 Output이 여러 개라면 하나의 Record를 여러 Destination으로 전달할 수도 있다.

## 설정 예제

- Nginx Access Log를 읽고 표준 출력으로 전달하는 간단한 예제다.

```ini
[INPUT]
    Name              tail
    Path              /var/log/nginx/access.log
    Tag               nginx.access
    Read_from_Head    true

[OUTPUT]
    Name              stdout
    Match             nginx.*
```

- 실행한다.

```bash
fluent-bit -c fluent-bit.conf
```

- Elasticsearch로 전달하려면 Output Plugin을 변경할 수 있다.

```ini
[OUTPUT]
    Name              es
    Match             nginx.*
    Host              elasticsearch.example.com
    Port              9200
    Index             nginx-access
```

# Fluentd

- Fluentd는 C와 Ruby로 구현된 Unified Logging Layer다.
- 다양한 Input과 Output을 연결하고, 복잡한 Event 가공 및 Routing을 구성할 수 있다.
- Core Plugin 외에도 Ruby Gem 형태의 외부 Plugin 생태계가 크다는 장점이 있다.

## 잘 맞는 환경

- 여러 Agent에서 전달한 데이터를 중앙에서 모으는 경우
- Event에 대한 복잡한 변환과 조건부 Routing이 필요한 경우
- 여러 Destination으로 전달하면서 Buffer와 Retry를 세밀하게 제어해야 하는 경우
- Fluentd Plugin 생태계에 있는 특정 Integration이 필요한 경우

## 설정 예제

- Fluent Bit 예제와 동일하게 Nginx Access Log를 읽고 표준 출력으로 전달한다.

```xml
<source>
  @type tail
  path /var/log/nginx/access.log
  pos_file /var/log/fluent/nginx-access.pos
  tag nginx.access

  <parse>
    @type none
  </parse>
</source>

<match nginx.**>
  @type stdout
</match>
```

- 실행한다.

```bash
fluentd -c fluent.conf
```

- Elasticsearch Output은 일반적으로 별도의 `fluent-plugin-elasticsearch` 설치가 필요하다.

```xml
<match nginx.**>
  @type elasticsearch
  host elasticsearch.example.com
  port 9200
  index_name nginx-access

  <buffer tag,time>
    @type file
    path /var/log/fluent/buffer/nginx
    timekey 1m
    flush_interval 10s
    retry_type exponential_backoff
  </buffer>
</match>
```

# Tag 와 Match를 이용한 Routing

- 두 도구 모두 Tag와 Match를 이용해 Event의 전달 경로를 결정한다.

```text
Tag: app.api
  -> Match: app.*
      -> Elasticsearch
      -> S3
```

- 하나의 로그를 검색용 저장소와 장기 보관용 Object Storage에 동시에 전달할 수 있다.
- 다만 Output이 많아질수록 느린 Destination이 Buffer 사용량과 Retry에 미치는 영향을 확인해야 한다.

# Buffer가 필요한 이유

- 로그 Destination은 항상 정상이라는 보장이 없다.
  - Network 장애
  - Elasticsearch Cluster 장애
  - Kafka 지연
  - Destination의 처리량 부족
- Buffer가 없다면 Destination으로 보내지 못한 Event가 바로 유실될 수 있다.
- Memory Buffer는 빠르지만 Process 또는 Node가 종료되면 복구하기 어렵다.
- File System Buffer는 Disk I/O를 사용하지만 Process 재시작 이후에도 데이터를 복구할 가능성이 높다.

## Fluentd Buffer

- Fluentd는 Event를 Chunk로 묶어 Buffer의 Stage와 Queue에서 관리한다.
- Output 전송에 실패하면 설정한 Retry 정책에 따라 다시 시도한다.
- `tag`, `time`, Record의 특정 Key를 Chunk Key로 지정할 수 있다.
- 일반적인 Workload에서는 공식 문서가 File Buffer 사용을 권장한다.

## Fluent Bit Buffer

- Fluent Bit도 Memory와 File System 기반 Buffering을 지원한다.
- Input이 데이터를 생성하는 속도보다 Output이 처리하는 속도가 느리면 Backpressure가 발생한다.
- 이때 Memory 제한, File System Storage, Backlog와 Pause 동작을 함께 설계해야 한다.

- 어떤 도구를 선택하더라도 아래 항목을 명시적으로 확인하는 것이 좋다.
  - 허용할 Memory 사용량
  - Buffer를 저장할 Disk 용량
  - Chunk 크기와 Flush 주기
  - Retry 간격과 최대 재시도 정책
  - Buffer가 가득 찼을 때의 Drop 또는 Pause 정책
  - 장애 복구 후 밀린 데이터가 만드는 순간 부하

# Kubernetes에서 사용하는 방법

- Kubernetes에서는 Node의 `/var/log/containers`를 읽을 수 있도록 Fluent Bit을 DaemonSet으로 배포하는 구성이 흔하다.

```text
Node A: Fluent Bit DaemonSet Pod --+
Node B: Fluent Bit DaemonSet Pod --+--> Storage
Node C: Fluent Bit DaemonSet Pod --+
```

- 각 Node마다 Agent 하나를 두기 때문에 Application Pod마다 Sidecar를 추가하는 방식보다 운영 대상과 자원 사용량을 줄일 수 있다.
- Kubernetes Filter를 이용하면 Namespace, Pod, Container 같은 Metadata를 Record에 추가할 수 있다.

## Fluent Bit과 Fluentd를 함께 사용하기

- Node에서는 Fluent Bit으로 가볍게 수집하고, 중앙 Fluentd에서 복잡한 가공과 Routing을 수행하는 구조도 가능하다.

```text
Kubernetes Node
  -> Fluent Bit
      -> Forward Protocol
          -> Fluentd Aggregator
              -> Elasticsearch
              -> Object Storage
              -> Message Queue
```

- Filebeat과 Logstash를 조합한 구조와 비슷하게 이해할 수 있다.
- 다만 반드시 두 계층이 필요한 것은 아니다.
- Fluent Bit만으로 필요한 처리와 Routing을 만족한다면 중앙 Fluentd를 추가하지 않는 편이 구성 요소와 장애 지점을 줄일 수 있다.

# 어떤 도구를 선택해야 할까?

## Fluent Bit을 먼저 검토할 때

- Node 또는 Container마다 Agent를 배포해야 한다.
- CPU와 Memory 사용량을 작게 유지해야 한다.
- 필요한 Input, Filter, Output이 Built-in Plugin으로 제공된다.
- Pipeline이 비교적 단순하고 처리량이 중요하다.

## Fluentd를 검토할 때

- 필요한 Integration이 Fluentd Plugin 생태계에만 존재한다.
- 복잡한 Record 변환과 조건부 Routing이 필요하다.
- Chunk, Flush, Retry, Secondary Output을 세밀하게 제어해야 한다.
- 중앙 Aggregator에 충분한 자원을 할당할 수 있다.

## 함께 사용할 때

- 수집 지점에는 경량 Agent가 필요하지만 중앙에서 무거운 가공도 해야 한다.
- Edge 또는 여러 Cluster의 로그를 지역 Aggregator로 모아야 한다.
- Agent가 Storage와 직접 연결하지 않도록 Network와 인증을 중앙화해야 한다.

# 운영할 때 확인할 항목

- Tool 선택보다 운영 정책이 더 중요할 수 있다.
- 다음 항목을 사전에 정리하는 것이 좋다.
  - 로그 유실을 어느 정도까지 허용할 것인가?
  - Destination 장애를 얼마 동안 Buffer로 버틸 것인가?
  - 민감 정보는 어느 단계에서 제거할 것인가?
  - Multi-line Log와 Timestamp를 어떻게 Parse할 것인가?
  - 로그 급증 시 Agent가 Application 자원을 침범하지 않는가?
  - Agent 자체의 처리량, Retry, Drop, Buffer Metric을 어떻게 감시할 것인가?
  - Plugin과 Image Version을 어떻게 검증하고 배포할 것인가?

# 정리

- Fluentd와 Fluent Bit은 모두 데이터를 수집하고 가공해 여러 목적지로 전달할 수 있다.
- Fluent Bit은 C 기반의 낮은 자원 사용량과 높은 처리량이 장점이며 Node Agent와 Edge 환경에 잘 맞는다.
- Fluentd는 큰 Plugin 생태계와 유연한 Buffer 및 Routing 설정이 장점이며 복잡한 Pipeline과 중앙 Aggregator에 잘 맞는다.
- 두 도구의 역할은 완전히 분리되어 있지 않으며 각각 단독 Forwarder 또는 Aggregator로 사용할 수 있다.
- 필요한 기능을 Fluent Bit만으로 만족한다면 단순한 구성을 우선하고, 복잡한 가공이나 특정 Plugin이 필요할 때 Fluentd 또는 2단계 구조를 검토하는 것이 좋다.

# 참고자료

- [Fluent Bit 공식 문서](https://docs.fluentbit.io/manual)
- [Fluent Bit - Fluentd and Fluent Bit](https://docs.fluentbit.io/manual/about/fluentd-and-fluent-bit)
- [Fluent Bit - Key concepts](https://docs.fluentbit.io/manual/concepts/key-concepts)
- [Fluent Bit - Buffering and storage](https://docs.fluentbit.io/manual/administration/buffering-and-storage)
- [Fluentd 공식 문서](https://docs.fluentd.org/)
- [Fluentd - Buffer plugins](https://docs.fluentd.org/buffer)
- [Fluentd - Buffer section](https://docs.fluentd.org/configuration/buffer-section)
- [Fluentd - Output plugins](https://docs.fluentd.org/output)
