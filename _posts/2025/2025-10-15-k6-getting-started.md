---
layout: post
title:  "[K6] Javascript 로 부하 테스트 시작하기"
date:   2025-10-15 18:21:25 +0900
categories:
- performance
tags:
- k6
- performance-test
- load-test
- javascript
---

- 서비스의 성능을 개선하려면 먼저 현재 처리량과 응답 시간을 측정해야 한다.
- 이번 글에서는 오픈소스 부하 테스트 도구인 `k6`를 설치하고, 간단한 HTTP 테스트를 실행한 뒤 결과를 확인하는 방법을 정리한다.

> 부하 테스트는 반드시 테스트가 허용된 시스템에서 진행해야 한다. 운영 환경이나 외부 서비스에 사전 협의 없이 부하를 발생시키면 장애로 이어질 수 있다.

# k6 란?

- [k6](https://k6.io/)는 Grafana Labs에서 개발하는 오픈소스 부하 및 성능 테스트 도구다.
- 주요 특징은 아래와 같다.
  - Javascript 또는 Typescript로 테스트 시나리오를 작성할 수 있다.
  - CLI 기반이라 Local, Container, CI 환경에서 실행하기 쉽다.
  - HTTP, HTTP/2, WebSocket, gRPC 등 여러 Protocol을 지원한다.
  - Go로 구현된 실행 엔진이 많은 Virtual User를 구동한다.
  - 실행 중 주요 Metric을 실시간으로 확인할 수 있다.
  - Threshold를 이용해 성능 기준의 성공과 실패를 자동으로 판단할 수 있다.

- 테스트 코드는 Javascript로 작성하지만 Browser의 Javascript Runtime에서 실행되는 것은 아니다.
- 따라서 Node.js 전용 Package나 API를 그대로 사용할 수 있는 것은 아니며, k6가 제공하는 Module과 지원 범위를 확인해야 한다.

# 실행 방식

## Local

- 개인 PC, 단일 Server, Container 또는 CI Runner에서 직접 실행한다.
- 테스트 작성과 검증, 비교적 작은 규모의 부하 테스트에 적합하다.
- 한 장비에서 만들 수 있는 부하는 CPU, Memory, Network 한계의 영향을 받는다.

```bash
k6 run script.js
```

## Distributed with Kubernetes

- 단일 장비로 목표 부하를 만들기 어렵다면 [k6 Operator](https://github.com/grafana/k6-operator)를 이용할 수 있다.
- Kubernetes에 여러 Runner Pod를 생성하고 테스트를 분산 실행한다.
- 사내 Network 안에서 실행해야 하거나, 부하 생성기의 자원이 부족한 경우 유용하다.

- 다만 Runner를 늘린다고 항상 정확한 부하가 만들어지는 것은 아니다.
  - Runner Pod의 CPU와 Memory
  - Kubernetes Node의 Network 대역폭
  - 테스트 대상까지의 Network 경로
  - Test Data 중복
  - 결과 Metric의 집계 방식
- 등을 함께 확인해야 한다.

## Grafana Cloud k6

- Grafana에서 제공하는 Managed Service를 이용하는 방식이다.
- 부하 생성 인프라와 결과 저장 및 시각화를 직접 구성하는 비용을 줄일 수 있다.
- 필요한 부하 규모, 실행 지역, 보안 정책, 비용을 확인한 뒤 Local 또는 Distributed 방식과 비교하면 된다.

# Mac에서 설치하기

- Homebrew를 이용한다.

```bash
brew install k6
```

- 설치한 버전을 확인한다.

```bash
k6 version
```

- Docker를 사용한다면 공식 Image를 받을 수도 있다.

```bash
docker pull grafana/k6
```

# 첫 번째 테스트 작성하기

- `script.js` 파일을 생성한다.

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
};

export default function () {
  const response = http.get('https://test.k6.io/');

  check(response, {
    'status is 200': (res) => res.status === 200,
  });

  sleep(1);
}
```

- 실행한다.

```bash
k6 run script.js
```

- 위 예제에서 `VU`는 Virtual User를 의미한다.
- 각 VU는 `default function`을 테스트가 끝날 때까지 반복 실행한다.
- `sleep(1)`은 사용자가 다음 행동을 하기 전에 기다리는 시간을 단순하게 표현한 것이다.

## Check와 Threshold의 차이

- `check()`는 응답이 기대한 조건을 만족했는지 Metric으로 기록한다.
- Check가 실패했다고 해서 기본적으로 테스트 Process가 실패하는 것은 아니다.
- 자동화 환경에서 성능 기준을 통과했는지 판단하려면 `thresholds`를 설정해야 한다.

```javascript
export const options = {
  vus: 10,
  duration: '30s',
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
    checks: ['rate>0.99'],
  },
};
```

- 위 조건의 의미는 아래와 같다.
  - HTTP 요청 실패율이 1% 미만이어야 한다.
  - HTTP 응답 시간의 p95가 500ms 미만이어야 한다.
  - Check 성공률이 99%를 초과해야 한다.
- Threshold를 통과하지 못하면 k6가 실패 종료 코드를 반환하므로 CI에서 성능 회귀를 감지할 수 있다.

# k6 Options

- k6 Option은 세 가지 방식으로 지정할 수 있다.
  - Script의 `options` 객체
  - 환경변수
  - CLI Flag

## Script에서 선언하기

```javascript
export const options = {
  vus: 20,
  duration: '1m',
};
```

## 환경변수로 전달하기

```bash
K6_VUS=20 K6_DURATION=1m k6 run script.js
```

## CLI Flag로 전달하기

```bash
k6 run --vus 20 --duration 1m script.js
```

- 실행 시 설정을 바꿔야 한다면 환경변수나 CLI Flag가 편리하다.
- 팀에서 공통으로 관리해야 하는 기본값과 Threshold는 Script에 두는 편이 변경 이력을 관리하기 좋다.
- 여러 위치에 같은 Option이 있으면 우선순위에 따라 최종 값이 결정되므로, 실제 실행 로그에서 적용된 Scenario를 확인하는 것이 좋다.

# 단순 VU보다 Scenario 사용하기

- `vus`, `duration`만으로 시작할 수 있지만 실제 트래픽을 표현하려면 `scenarios`를 사용하는 편이 명확하다.
- Scenario는 어떤 Executor로 부하를 발생시킬지 정의한다.

```javascript
export const options = {
  scenarios: {
    ramping_load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 20 },
        { duration: '1m', target: 20 },
        { duration: '30s', target: 0 },
      ],
      gracefulRampDown: '10s',
    },
  },
};
```

- 위 Scenario는 아래 순서로 실행된다.
  - 30초 동안 VU를 0명에서 20명까지 증가
  - 1분 동안 VU 20명 유지
  - 30초 동안 VU를 0명까지 감소

## Closed Model과 Open Model

- `constant-vus`, `ramping-vus` 같은 Executor는 VU가 반복해서 요청하는 Closed Model에 가깝다.
- 응답이 느려지면 한 VU가 다음 요청을 늦게 보내므로 실제 요청 발생률도 낮아질 수 있다.
- 목표 RPS에 가까운 요청 도착률을 유지하려면 `constant-arrival-rate`, `ramping-arrival-rate` 같은 Arrival Rate Executor를 고려할 수 있다.

```javascript
export const options = {
  scenarios: {
    fixed_rate: {
      executor: 'constant-arrival-rate',
      rate: 100,
      timeUnit: '1s',
      duration: '1m',
      preAllocatedVUs: 30,
      maxVUs: 100,
    },
  },
};
```

- 목표가 동시 사용자 수인지, 초당 요청 수인지에 따라 Executor를 선택해야 한다.

# 환경별 URL과 값 전달하기

- 대상 URL이나 인증 정보 같은 값을 Script에 고정하지 않고 `__ENV`를 통해 전달할 수 있다.

```javascript
import http from 'k6/http';

const baseUrl = __ENV.BASE_URL;

export default function () {
  http.get(`${baseUrl}/health`);
}
```

```bash
k6 run -e BASE_URL=https://test.example.com script.js
```

- 인증 Token을 Script나 Git 저장소에 포함하지 않도록 주의한다.
- CI에서는 Secret 저장소를 통해 환경변수로 주입하는 것이 좋다.

# 결과 확인하기

## CLI Summary

- 테스트가 끝나면 k6가 기본 Metric을 요약해서 출력한다.
- 처음에는 아래 Metric을 중심으로 확인하면 된다.
  - `http_reqs`: 전체 HTTP 요청 수와 처리율
  - `http_req_duration`: 요청 전체 응답 시간
  - `http_req_waiting`: 서버 응답을 기다린 시간
  - `http_req_failed`: 실패한 HTTP 요청 비율
  - `iterations`: 완료한 Test Function 반복 횟수
  - `vus`, `vus_max`: 활성 VU와 최대 VU

- 평균값만 확인하면 일부 느린 요청이 가려질 수 있으므로 p90, p95, p99 같은 Percentile을 같이 확인한다.

## Web Dashboard

- k6에는 실행 결과를 실시간으로 볼 수 있는 Web Dashboard가 내장되어 있다.

```bash
K6_WEB_DASHBOARD=true k6 run script.js
```

- 기본 주소는 아래와 같다.

```text
http://127.0.0.1:5665
```

- 테스트 종료 시 HTML Report를 자동으로 생성할 수도 있다.

```bash
K6_WEB_DASHBOARD=true \
K6_WEB_DASHBOARD_EXPORT=report.html \
k6 run script.js
```

- CI처럼 Dashboard를 열 필요가 없는 환경에서는 HTML Export 여부와 Process 종료 조건을 함께 확인한다.

# 테스트할 때 주의할 점

## 부하 생성기가 병목인지 확인한다

- 테스트 대상이 아니라 k6를 실행하는 장비가 먼저 한계에 도달할 수 있다.
- 부하 생성기의 CPU, Memory, Network 사용량과 `dropped_iterations`를 같이 확인한다.
- 한 장비로 부족하다면 더 큰 장비 또는 Distributed Test를 검토한다.

## 바로 큰 부하를 주지 않는다

- 작은 Smoke Test로 Script와 응답을 먼저 검증한다.
- 부하를 단계적으로 증가시키면서 오류율과 응답 시간을 확인한다.
- 장애 시 즉시 중단할 기준과 담당자 연락 방법을 준비한다.

## 실제 사용자 행동을 반영한다

- 하나의 API만 계속 호출하면 실제 서비스와 다른 결과가 나올 수 있다.
- 로그인, 목록 조회, 상세 조회처럼 실제 사용 흐름을 Group과 Scenario로 표현한다.
- Cache 적중률에 영향을 주도록 Test Data의 분포도 현실적으로 구성한다.

## Client Metric과 Server Metric을 함께 본다

- k6 결과만으로 원인을 판단하기 어렵다.
- Application의 CPU, Memory, GC, Thread Pool, Connection Pool과 Database 및 Cache Metric을 같은 시간축으로 확인해야 한다.

# 정리

- k6는 Javascript로 Scenario를 작성하고 CLI로 실행할 수 있는 부하 테스트 도구다.
- Local에서 Script를 먼저 검증하고, 필요한 경우 k6 Operator 또는 Grafana Cloud k6로 확장할 수 있다.
- `check`는 응답 검증 결과를 기록하고, `threshold`는 테스트의 성공과 실패 기준을 만든다.
- 목표가 동시 사용자 수인지 요청 도착률인지에 따라 Scenario Executor를 선택해야 한다.
- 결과는 평균뿐 아니라 Percentile, 오류율, 부하 생성기와 Server Metric을 함께 확인해야 한다.

# 참고자료

- [Grafana k6 - Install k6](https://grafana.com/docs/k6/latest/set-up/install-k6/)
- [Grafana k6 - Write your first test](https://grafana.com/docs/k6/latest/get-started/write-your-first-test/)
- [Grafana k6 - Options](https://grafana.com/docs/k6/latest/using-k6/k6-options/)
- [Grafana k6 - Scenarios](https://grafana.com/docs/k6/latest/using-k6/scenarios/)
- [Grafana k6 - Thresholds](https://grafana.com/docs/k6/latest/using-k6/thresholds/)
- [Grafana k6 - Web dashboard](https://grafana.com/docs/k6/latest/results-output/web-dashboard/)
- [Grafana k6 - Set up distributed k6](https://grafana.com/docs/k6/latest/set-up/set-up-distributed-k6/)
- [k6 Operator](https://github.com/grafana/k6-operator)
