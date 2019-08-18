---
layout: post
title:  "Maven 내부 Repo 만들기(Nexus install)"
date:   2017-01-17 01:00:00 +0900
categories:
 - tools
tags: 
 - maven
 - nexus
---

# 1. Nexus란?
- Maven에서 사용할 수 있는 무료 repository
- 로컬 Nexus에 Proxy를 사용하면, 빠르게 라이브러리를 다운로드 받을 수 있다.
- 회사에서 사용하는 공통 라이브러리들을 로컬 Nexus에 배포하여 회사 내부에서 손 쉽게 공유가 가능하다.
- 오픈소스 버전(Nexus OSS)과 상용 버전(Nexus Pro) 두개 버전이 있다.
- 상용버전의 경우 아티팩트 취약점 관리, SSO(single Sign On) 지원, 기술 지원 등 장점이 많다.

# 2. Nexus Install
- 다운로드 

> wget http://www.sonatype.org/downloads/nexus-latest-bundle.tar.gz

- 압축 풀기

> tar xzf ./nexus-latest-bundle.tar.gz 

- 끝

# 3. 폴더 구조
```
bin : 실행과 관련된 스크립트가 잇다.

conf : 설정 파일들이 있다.

logs : 로그가 저장된다. 파일명은 wrapper.log 다.

nexus: 어플리케이션 소스가 있다.
```

# 4. Nexus Setting
- 이동(최신 버전 설치기 때문에 버전이 다를 수 있다.)

> cd ./nexus-2.14.3-02/

- 설정 변경

> vi ./conf/nexus.properties

- 설정 값 설명
```properties
#어플리케이션 포트
application-port=8081

#어플리케이션 context 경로
nexus-webapp=${bundleBasedir}/nexus

#localhost:${application-port}/nexus로 사용할 것이냐. localhost:${application-port}/ 로 사용할 것이냐의 차이.
#뒤에 /nexus를 /로 변경하면 변경 가능하다.
nexus-webapp-context-path=/nexus
```

# 4. Nexus Run

> ./bin/nexus start

# 5. 참고 
- http://bcho.tistory.com/790
- https://www.lesstif.com/pages/viewpage.action?pageId=20775149
