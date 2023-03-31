---
layout: post
title:  "[Kubernetes] kubernetes 란?"
date: 2022-08-01 09:00:00 +0900
categories:
- kubernetes
tags:
- kube
---

# kubernetes 란?
## 모든 리소스는 오브젝트다.
- 컨테이너의 집합인 : `Pods`
- 컨테이너의 집합을 관리하는 컨트롤러 : `Replica Set`
- 사용자 : `Service Account`
- 노드 : `Node`

#### 이외에도..
- 아래 명령어를 통해 많은 오브젝트 종류를 확인 할 수 있다.
> kubectl api-resources

#### 각 오브젝트의 설명을 보고 싶을 경우
> kubectl explain pod

#### kubectl
- 쿠버네티스에 접근해서 API 를 사용하기 위한 명령어 도구.

# Local 에서 사용해보기
## mac 에서 kubernetes 사용하기
- 아래와 같이 설치하여 사용 할 수 있다.
  <img width="764" alt="image" src="https://user-images.githubusercontent.com/13219787/162373722-3b399db1-2bce-4d7a-95ab-25dea65e41c1.png">

- 아래 명령어로 동작을 확인 할 수 있다.

> kubectl version --output=yaml

> kubectl version --short

## minikube
- 멀티 노드를 사용하는 기능은 제공하지 않지만, minikube를 사용하게 되면 로컬에서 쉽게 테스트 해볼 수 있다.
- https://minikube.sigs.k8s.io/docs/start/