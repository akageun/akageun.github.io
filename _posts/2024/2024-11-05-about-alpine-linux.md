---
layout: post
title: "[Docker] Alpine Linux"
date: 2024-11-05 09:00:00 +0900
categories:
- docker
tags:
- docker
- linux
- alpine
---
- 알파인 리눅스는 리눅스 커널 기반으로 만들어진 리눅스 배포판 중 하나
  - MIT 라이선스
- 알파인 리눅스는 네트워크 장비 등 임베디드 환경에서 사용하기 위해 설계 됨.
  - 가볍고(대략 80MB) Base os 로 많이 사용됨.
- RedHat 계열이 아니므로 별도의 학습이 필요함.
  - 용량을 줄이기 위해 system 의 C runtime 을 교체하여 `GNU Utils` 대신 `busybox` 를 사용
    - 쉘 명령어를 실행할 때 주의가 필요함.
  - yum 등 과 같은 패키지 매니저가 아니라 apk 를 이용함.

## 기타 내용
- `busybox` : 명령어들을 모아놓은 프로그램으로 최소 사이즈로 필요 함수들을 재 구현함.
- apk
  - apk update : 패키지 저장소 목록 업데이트
  - apk search {package} : 패키지 저장소 목록에서 검색
  - apk add {package} : 패키지 설치
  - apk cache clean : 패키지 캐시 제거
  - apk stats : 패키지 등의 정보 출력
  - apk info : 현재 설치된 모든 패키지 정보 나열

---
## 참고내용
- https://wiki.alpinelinux.org/wiki/Alpine_Linux:Overview
