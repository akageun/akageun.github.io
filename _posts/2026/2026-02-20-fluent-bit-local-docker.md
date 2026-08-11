---
layout: post
title:  "Fluent Bit을 Local Mac 환경에서 테스트하기"
date:   2026-02-20 17:54:36 +0900
categories:
- observability
tags:
- fluent-bit
- logging
- docker
- mac
---

- Fluent Bit 설정을 운영 환경에 배포하기 전에 Input, Filter, Output이 의도한 대로 동작하는지 빠르게 확인하고 싶을 때가 있다.
- 이번 글에서는 Mac의 Docker 환경에서 Fluent Bit을 실행하고, Dummy Input으로 만든 데이터를 Filter로 가공한 뒤 표준 출력으로 확인하는 방법을 정리한다.

# 준비하기

- Docker 명령을 실행할 수 있어야 한다.
- Docker Desktop을 사용한다면 Application이 실행 중인지 확인한다.
- Colima를 사용한다면 상태를 확인한다.

```bash
colima status
```

- 실행 중이 아니라면 시작한다.

```bash
colima start
```

- Docker 연결 상태를 확인한다.

```bash
docker info
```

# Docker로 바로 실행하기

- Fluent Bit 공식 Container Image는 `cr.fluentbit.io/fluent/fluent-bit`에서 제공한다.
- 먼저 Dummy Input과 stdout Output을 CLI Option으로 지정해 실행해본다.

```bash
docker run --rm \
  cr.fluentbit.io/fluent/fluent-bit:latest \
  /fluent-bit/bin/fluent-bit \
  -i dummy \
  -o stdout
```

- `dummy` Input Plugin이 일정한 간격으로 가짜 Record를 만든다.
- `stdout` Output Plugin은 전달받은 Record를 Container 표준 출력에 표시한다.
- 아래와 비슷한 로그가 반복해서 출력되면 정상이다.

```text
[0] dummy.0: [[1771581276.000000000, {}], {"message"=>"dummy"}]
```

- 종료하려면 `Ctrl+C`를 누른다.

## Image Version 고정하기

- 간단한 확인에는 `latest`를 사용할 수 있지만 팀에서 같은 결과를 재현하려면 배포할 Version으로 고정하는 편이 좋다.

```bash
docker pull cr.fluentbit.io/fluent/fluent-bit:<version>
```

- Production Image는 불필요한 Package를 줄인 Distroless 기반이므로 Container 안에서 Shell이나 Debug Tool을 사용할 수 없다.
- Container 내부를 조사해야 한다면 동일 Version의 `-debug` Image를 검토할 수 있다.

# Configuration File 만들기

- CLI Option만으로는 복잡한 Pipeline을 표현하기 어렵다.
- 프로젝트의 빈 Directory에서 `test.conf`를 생성한다.

```ini
[SERVICE]
    Flush        1
    Log_Level    info
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_Port    2020
    Health_Check On

[INPUT]
    Name         dummy
    Alias        local_dummy
    Tag          dummy.log
    Dummy        {"message":"local test!","user":"test"}
    Rate         1

[FILTER]
    Name         record_modifier
    Match        dummy.*
    Record       hostname local-test-machine

[OUTPUT]
    Name         stdout
    Alias        local_stdout
    Match        dummy.*
```

- 각 Section의 역할은 아래와 같다.
  - `SERVICE`: Flush 주기, Log Level, Monitoring Server 같은 Process 전체 설정
  - `INPUT`: 데이터를 수집하거나 생성하는 Plugin
  - `FILTER`: 조건에 맞는 Record를 변경하거나 제외하는 Plugin
  - `OUTPUT`: 처리한 Record를 전달할 목적지 Plugin

## SERVICE

- `Flush 1`은 Output Plugin이 데이터를 내보내도록 Scheduler가 동작하는 간격을 1초로 설정한다.
- `Log_Level info`는 Fluent Bit 자체 로그의 출력 수준이다.
- `HTTP_Server On`은 내부 Metric과 상태를 확인할 HTTP Server를 활성화한다.
- `HTTP_Listen 0.0.0.0`으로 설정해야 Container 외부에서 Port Mapping을 통해 접근할 수 있다.
- `Health_Check On`은 Health Check 기능을 활성화한다.

## INPUT

- `dummy` Plugin이 테스트 Record를 만든다.
- `Tag dummy.log`는 이후 Filter와 Output이 Record를 선택하는 기준이 된다.
- `Rate 1`은 초당 한 건의 Event를 생성한다.
- `Alias`를 지정하면 Monitoring Metric에서 `dummy.0` 같은 내부 이름 대신 의미 있는 이름을 확인할 수 있다.

## FILTER

- `record_modifier` Filter가 원본 Record에 값을 추가한다.
- `Match dummy.*`이므로 `dummy.log` Tag를 가진 Record에만 적용된다.

```json
{
  "message": "local test!",
  "user": "test",
  "hostname": "local-test-machine"
}
```

## OUTPUT

- Filter 처리가 끝난 Record를 stdout으로 출력한다.
- Input, Filter, Output의 `Tag`와 `Match`가 서로 맞지 않으면 원하는 경로로 Record가 전달되지 않는다.

# Configuration File로 실행하기

- 현재 Directory의 `test.conf`를 Container 기본 설정 경로에 Read Only로 Mount한다.

```bash
docker run --rm \
  --name fluent-bit-local \
  -v "$(pwd)/test.conf:/fluent-bit/etc/fluent-bit.conf:ro" \
  -p 2020:2020 \
  cr.fluentbit.io/fluent/fluent-bit:latest
```

- 정상적으로 실행되면 stdout Record에 Filter에서 추가한 `hostname`이 표시된다.

```text
{"message"=>"local test!", "user"=>"test", "hostname"=>"local-test-machine"}
```

- 설정 파일의 Syntax나 Plugin Option이 잘못되면 시작 과정에서 오류를 출력하고 종료한다.

## 설정 파일 경로를 직접 지정하기

- 기본 경로가 아닌 위치로 Mount한다면 `--config` Option으로 경로를 지정한다.

```bash
docker run --rm \
  -v "$(pwd)/test.conf:/tmp/test.conf:ro" \
  -p 2020:2020 \
  cr.fluentbit.io/fluent/fluent-bit:latest \
  /fluent-bit/bin/fluent-bit --config /tmp/test.conf
```

# HTTP Monitoring 확인하기

- Fluent Bit이 실행 중인 상태에서 다른 Terminal을 연다.

## Build 정보

- HTTP Server의 Root Path에서 Version과 Build 정보를 확인한다.

```bash
curl -s http://localhost:2020/
```

## Uptime

```bash
curl -s http://localhost:2020/api/v1/uptime
```

## Plugin Metric

```bash
curl -s http://localhost:2020/api/v1/metrics
```

- `jq`가 설치되어 있다면 읽기 쉽게 출력할 수 있다.

```bash
curl -s http://localhost:2020/api/v1/metrics | jq
```

- Input Record 수, Output 처리 수, Error와 Retry 등을 확인할 수 있다.
- 설정에 `Alias`를 지정했기 때문에 Plugin별 Metric을 구분하기 쉬워진다.

## Prometheus 형식 Metric

```bash
curl -s http://localhost:2020/api/v1/metrics/prometheus
```

## Health Check

```bash
curl -s http://localhost:2020/api/v1/health
```

- 정상 상태라면 `ok`를 반환한다.
- 단순히 Process가 실행 중인지 확인하는 것과 모든 로그가 Destination에 정상 전달되고 있는지는 다른 문제다.
- 운영 환경에서는 Output Error, Retry, Drop과 Buffer 상태에 대한 별도 Alert가 필요하다.

# Filter가 적용됐는지 확인하기

- 테스트의 핵심은 Input Record가 Output으로 나오는지만 확인하는 것이 아니라 중간 가공 결과까지 검증하는 것이다.
- Container Log에서 `hostname`을 확인할 수 있다.

```bash
docker logs -f fluent-bit-local
```

- `record_modifier`의 Match를 존재하지 않는 Tag로 바꿔보면 `hostname`이 추가되지 않는다.

```ini
[FILTER]
    Name         record_modifier
    Match        not-matched.*
    Record       hostname local-test-machine
```

- 이런 식으로 Tag와 Match 조합, Parser, Filter 순서를 작은 입력으로 먼저 검증하면 운영 배포 후 로그가 사라지는 문제를 줄일 수 있다.

# 실제 파일 Tail 테스트하기

- Dummy Input 확인이 끝나면 Local Log File을 Tail하는 테스트로 확장할 수 있다.
- `sample.log` 파일을 만들고 Container에 Mount한다.

```text
{"level":"INFO","message":"application started"}
```

- `test-tail.conf`를 작성한다.

```ini
[SERVICE]
    Flush        1
    Log_Level    info

[INPUT]
    Name         tail
    Path         /var/log/sample/sample.log
    Tag          app.local
    Read_from_Head true
    Parser       json

[FILTER]
    Name         record_modifier
    Match        app.*
    Record       environment local

[OUTPUT]
    Name         stdout
    Match        app.*
```

- 설정과 Log File을 Mount해 실행한다.

```bash
docker run --rm \
  --name fluent-bit-tail-local \
  -v "$(pwd)/test-tail.conf:/fluent-bit/etc/fluent-bit.conf:ro" \
  -v "$(pwd)/sample.log:/var/log/sample/sample.log:ro" \
  cr.fluentbit.io/fluent/fluent-bit:latest
```

- `Read_from_Head true`를 지정했으므로 시작 시점에 이미 존재하는 첫 줄부터 읽는다.
- 출력 Record에 `environment=local`이 추가됐다면 Tail, JSON Parser, Filter, Output이 모두 연결된 것이다.

# 자주 만나는 문제

## HTTP API에 접속할 수 없다

- `HTTP_Server On`인지 확인한다.
- `HTTP_Listen`이 `0.0.0.0`인지 확인한다.
- Docker 실행 명령에 `-p 2020:2020`이 있는지 확인한다.
- 다른 Process가 Local Port 2020을 사용 중인지 확인한다.

```bash
lsof -nP -iTCP:2020 -sTCP:LISTEN
```

## 설정 파일을 읽지 못한다

- Mount Source가 절대 경로로 해석되는지 확인한다.
- 파일명이 아니라 Directory를 잘못 Mount하지 않았는지 확인한다.
- Docker Desktop을 사용한다면 해당 Directory가 File Sharing 범위에 포함되는지 확인한다.

## Filter 또는 Output으로 Record가 전달되지 않는다

- Input의 `Tag`와 Filter 및 Output의 `Match`를 비교한다.
- 문제를 단순화하기 위해 Output을 stdout 하나만 남긴다.
- `Log_Level debug`로 변경해 Routing과 Plugin 초기화 로그를 확인한다.

## Apple Silicon에서 실행되지 않는다

- 공식 Image는 Multi-architecture Image를 제공하므로 일반적으로 별도 설정 없이 적합한 Image가 선택된다.
- 사용하는 Version Tag가 현재 Architecture를 지원하는지 Image Manifest를 확인한다.

```bash
docker buildx imagetools inspect \
  cr.fluentbit.io/fluent/fluent-bit:latest
```

# 운영 설정으로 확장하기 전에

- Local에서 정상 출력됐다고 바로 운영 준비가 끝난 것은 아니다.
- 실제 환경에 적용하기 전 아래 항목을 추가로 확인해야 한다.
  - Memory와 File System Buffer
  - Destination 장애 시 Retry와 Backoff
  - Buffer가 가득 찼을 때의 동작
  - Multi-line Log와 Timestamp Parser
  - 민감 정보 제거 Filter
  - TLS와 인증 정보 관리
  - Fluent Bit 자체 CPU와 Memory 제한
  - Input, Output, Retry, Drop Metric Monitoring

# 정리

- Docker를 사용하면 Mac에 Fluent Bit Binary를 직접 설치하지 않고도 Pipeline을 빠르게 테스트할 수 있다.
- Dummy Input과 stdout Output으로 Process 및 Plugin 동작을 먼저 확인한다.
- Configuration File을 Mount해 Input, Filter, Output의 Tag와 Match가 올바른지 검증한다.
- HTTP Server를 활성화하면 Build 정보, Uptime, Health와 Plugin Metric을 확인할 수 있다.
- Dummy 테스트가 끝나면 Tail Input과 실제 Parser를 연결해 운영 설정에 가까운 형태로 확장한다.
- 재현 가능한 검증과 배포를 위해 실제 사용 단계에서는 Container Image Version을 고정하는 것이 좋다.

# 참고자료

- [Fluent Bit - Download and install](https://docs.fluentbit.io/manual/installation/downloads)
- [Fluent Bit - Docker](https://docs.fluentbit.io/manual/installation/downloads/docker)
- [Fluent Bit - Classic configuration files](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode)
- [Fluent Bit - Dummy input](https://docs.fluentbit.io/manual/data-pipeline/inputs/dummy)
- [Fluent Bit - Record modifier filter](https://docs.fluentbit.io/manual/data-pipeline/filters/record-modifier)
- [Fluent Bit - Standard output](https://docs.fluentbit.io/manual/data-pipeline/outputs/standard-output)
- [Fluent Bit - Monitoring](https://docs.fluentbit.io/manual/administration/monitoring)
