---
layout: post
title:  "how to install gradle on windows"
date:   2019-05-30 09:00:00 +0900
categories:
 - tools
tags:
 - gradle
 - java
---

# java 설치 확인
- 아래 명령어를 통해 설치여부를 확인 할 수 있고, 없다면 jdk 설치관련 문서를 참고
- Groovy는 Gradle 내에 포함되어 있으므로, 기존 설치되어 있는 Groovy는 무시됨

> java -version

# Download
- https://gradle.org/releases/
- binary-only 나 complete 둘 중 아무거나 받아도 됨

# 설치
- 다운받은 파일 압축을 푼다.
- **C:\Gradle** 폴더를 만든 뒤 압축 푼 내용을 이동합니다.
- **C:\Gradle\gradle-5.2** 형태가 될 겁니다.

# 환경설정
- `시스템 환경 변수 편집` 를 검색하여 실행 합니다.
- **환경변수** -> **시스템 환경변수** -> **새로만들기**
- 변수 이름에 **GRADLE_HOME** 을 넣고 변수 값에 앞서 만든 폴더(**C:\Gradle\gradle-5.2**)를 넣습니다.
- **시스템 환경변수** -> **Path** 내에 `%GRADLE_HOME%\bin` 를 추가 합니다.

# 확인
- 아래 명령어를 입력해서 버전 정보가 나오면 정상 설치된 겁니다.

> gradle -v 


## 참고사항
- 이미 열려있던 터미널은 닫고 새로 터미널을 열어 확인하세요. 
