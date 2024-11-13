---
layout: post
title: "[Docker] About Dockerfile"
date: 2024-11-04 09:00:00 +0900
categories:
  - docker
tags:
  - docker
---

- `Dockerfile`이란? Docker image 를 생성하기 위한 스크립트로 단순 텍스트파일로 구성되어 있다.
- 이미지 생성을 자동화 할 수 있고 버전관리 할 수 있는 장점이 있다.

- Dockerfile `Build` vs Container `Commit`
  - Dockerfile Build
    - Image 를 생성하는데 필요한 모든 단계를 포함
    - 버전관리 가능
  - Container Commit
    - 빠르게 사용가능
    - 다른 환경에서 동일하게 생성하여 처리하기 위해서는 문서 작성 등 추가 비용이 많이들어감.
    - 일관성 등 보장되기 어려움

# Dockerfile 작성해보기

## 어떤 과정으로 작업하는가?

- `Dockerfile` 작성 -> `Build` -> `run` or `docker hub 등에 push`

![image](https://user-images.githubusercontent.com/13219787/168212227-73460ade-ad77-4d3b-beda-683c50a7c80c.png)

## 작업 단계

- Base Image 선택하기
  - 리눅스 배포판 or 필요한 모듈이 들어간 alpine 등을 선정한다.
- 필요한 파일 및 명령을 추가
  - 필요한 파일들을 옮겨놓거나 base image 에 추가할 명령어들을 실행함.
- 포트 노출이 필요할 경우, 다른 명령어를 실행해야하는 경우 등 요구사항에 맞춰서 작업

## Dockerfile Build

> docker build [option] 경로

- option
  - `-t`, `--tag` : 태그 지정 `{image name}:{tag값}
  - `-f`, `--file` : docker 파일 경로, default `./Dockerfile`
  - `-q`, `--quiet` : 처리 결과 출력 안함.
  - `--build-arg` : Dockerfile 내에 ARG 로 값 전달.

- sample
  - 명령어를 실행하는 곳에 `Dockerfile` 있음.

> docker build -t sample:v1.0 .

