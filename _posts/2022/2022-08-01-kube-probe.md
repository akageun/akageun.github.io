---
layout: post
title:  "[Kubernetes] Pod 를 진단하는 Probe"
date: 2022-08-01 09:00:00 +0900
categories:
- kubernetes
tags:
- kube
---

# Kubernetes Pod 를 진단하는 Probe
- 주기적으로 수행하여 pod 를 진단하는 걸 `probe` 라고 한다.
- https://kubernetes.io/ko/docs/concepts/workloads/pods/pod-lifecycle/

## 체크 메커니즘
- 현재까지는 4가지를 제공하고 있음

#### exec
- 명령어를 통해 상태코드 0으로 종료되면 성공으로 판단.

```yml
...
  exec: 
    command:
      - cat
      - /tmp/healthy
```

#### grpc
- 원격 프로시저를 호출
- status 가 `SERVING` 이면 진단 성공
- https://grpc.github.io/grpc/core/md_doc_health-checking.html

#### httpGet
- 지정한 포트 및 경로에서 컨테이너 ip 주소로 GET 요청하여 진단
- response status 가 200 이상 400 미만이면 진단 성공

```yml
...
  httpGet:
    path: /health
    port : 80
```

#### tcpSocket
- 컨테이너 ip 주소에 대하 TCP 검사를 수행하여 진단.
- port 가 활성화 되어 있다면 진단 성공

```yml
...
  tcpSocket:
    port: 8080
```

## Probe 결과
- `Success` : 진단 통과
- `Failure` : 진단 실패
- `Unknown` : 진단 자체가 실패, kubelet 이 추가 체크를 수행

## Probe 종류
#### `livenessProbe` : 컨테이너가 살아있는지 점검
- Probe 검증이 실패할 경우 kubelet 이 해당 컨테이너를 내리고 `컨테이너가 재시작` 된다.
- 만약 설정하지 않으면 기본 상태가 `Success`.
- 컨테이너 프로세스가 어떤 이슈 상황(`Unhealthy`)에서 `재시작`을 `Always` 또는 `OnFailure` 와 같은 정책에 따라 자동적으로 수행시키기를 원할 때 사용하면 좋음.

- 예시

```yml
livenessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 5
```

#### `readinessProbe` : 컨테이너가 서비스 가능한 상태인지 점검
- `livenessProbe` 와 다르게 컨테이너가 비정상일 수도 있지만, Config 를 로딩하거나 많은 데이터 로딩, 외부 서비스를 호출할 경우 일시적으로 서비스가 불가능할 수 있음.
- Probe 검증이 실패한다면, endpoint controller가 pod 에 연관된 모든 서비스들의 endpoint 에서 pod 의 ip 주소를 제거
- 초기 지연 이전의 상태는 `Failure` 이고 설정하지 않으면 기본 상태는 `Success`.
- Probe 가 성공할 경우에만 트래픽을 전송하기를 원할 때 사용.

```yml
readinessProbe:
  httpGet:
    path: /health
    port: 80
```

#### `startupProbe` : 컨테이너가 시작되었는지 점검
- 해당 probe가 설정되면 성공할 때까지 다른 probe 는 활성화 되지 않음.
- 실패한다면 kubelet이 컨테이너를 죽이고 `컨테이너가 재시작(정책에 따라)` 된다.
- 설정하지 않으면 기본 상태는 `Success`.

```yml
startupProbe:
  httpGet:
    path: /health
    port: 80
```

## Probe 세부 설정
- `initialDelaySeconds` : 초기 지연 시간
- `periodSeconds` : 대기 초
- `timeoutSeconds` : 타임아웃 초
- `successThreshold` : 성공 임계 값
- `failureThreshold` : 실패 임계 값

---
- kubelet : 클러스터의 모든 머신에서 실행되며 Pod 및 컨테이너 시작 등의 작업을 수행하는 구성 요소

## 참고링크
- https://bcho.tistory.com/1264
- https://medium.com/finda-tech/kubernetes-pod%EC%9D%98-%EC%A7%84%EB%8B%A8%EC%9D%84-%EB%8B%B4%EB%8B%B9%ED%95%98%EB%8A%94-%EC%84%9C%EB%B9%84%EC%8A%A4-probe-7872cec9e568
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/