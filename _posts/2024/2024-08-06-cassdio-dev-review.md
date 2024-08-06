---
layout: post
title:  "Cassdio 개발 후기"
date:   2024-08-06 09:00:00 +0900
categories:
- project
tags:
- cassandra
- cassdio
- opensource
---
- 이번에 새롭게 OpenSource 를 개발한 후기에 대해서 짧게 작성해보려고 한다.
- OpenSource Link : https://github.com/hakdang/cassdio
  - 관심있으시다면 `Star` 부탁드립니다!!

# 시작하게 된 이유
- Cassandra 를 사용하고 있는데, 쓸만한 Web Console 이 없었다.
    - 최신 버전을 지원하거나, Javascript Error 등으로 사용이 불편한 부분이 많았다.
    - Pull Request 로 수정을 요청하기에는 유지보수가 잘 안되고 있는 것 같아서 고민이 많았다.
- Intelli J 에서 Cassandra Driver 를 이용하여 접근할 수 있지만, 이렇게 된다면 접근관리 등 여러 불안요소가 많아서 안전 장치가 있는 도구를 만들고 싶었다.
- 회사에서 과제로 보고하고 진행할까 고민 했지만, 다수가 참여할 수 있게 공개하고 카산드라 생태계에 기여하고 싶은 생각에 개인 프로젝트로 진행하기로 생각했다.
- 주변에 관심 있어하는 친구들을 모아서, 퇴근 이후에 개발을 진행하기 시작했다.

# 목표를 설정하자
- 기본적인 기능들을 빠르게 개발해 보자.
    - 기본에 대한 정의는 우리가 Cassandra 를 접근하여 사용할 수 있는 기능들을 목록화 했다.
        - 쿼리를 입력하여 실행 할 수 있는 장치를 마련한다.
        - 쿼리를 입력하지 않아도 테이블이나 내부 데이터를 손쉽게 확인 할 수 있게 한다.
        - 이 외에도 몇가지 모니터링 장치 등을 목록으로 작성했다.
- 초기 버전 이후에 추가할 기능들에 대해서는 `issue` 로 등록해 놓고, 다른 개발자들의 참여를 유도해보자.
    - 이부분은 아직 영어로 작성하지 못했지만, 내용을 보강하여 외국 개발자들도 참여 할 수 있도록 milestone 을 정리하여 마치 기획서처럼 정리할 예정이다.

# 옆집 탐방
- 무조건 시작하기 보다는 일단 옆집들은 어떻게 하는지 분석했다.

## 탐색 대상 정하기
- Cassandra-Web : https://github.com/avalanche123/cassandra-web
    - 기존에 사용했던 Cassandra Web Console 프로젝트
    - 여기서 제공하고 있는 기능들을 목록화 했고, 기본 기능으로 개발하기로 했다.
        - Driver 에서 여러 정보들을 제공하고 있다는걸 확인했다.
            - 최대한 Driver 에서 제공해주는 기능을 통해서 Console 페이지를 구성하기로 했다.
                - 이렇게 해야 Driver 에 따라 지원 버전 등을 잘 정리할 수 있기 때문....
    - 비슷한 프로젝트로 참고한 Web Console : https://github.com/orzhaha/cassandra-web
- Reaper : https://github.com/thelastpickle/cassandra-reaper
    - Cassandra Repair 등을 처리할 수 있는 도구
- Kafka-Ui : https://github.com/provectus/kafka-ui
    - Java 로 개발되어있고, 비슷한 형태를 가지고 있어서 운영 방식 등을 참고함.
- Tadpole : https://sites.google.com/site/tadpolefordb/home?authuser=0
    - 인증권한에 대한 장치
    - 엔터프라이즈 모델도 있어서 여러가지 운영 방식 등을 참고 했다.

# 시작하기
- 개발 language 라던가 어떤 형태를 사용할 것인지를 논의 했다.

## Backend 에 대한 고민
### JDK 선정하기
- Java 를 이용하기로 했고 JDK version 에 대해서는 고민이 많았다.
- 현재 Cassandra JDK 버전 지원 정책
    - 3.x : JDK 1.8
    - 4.0 : JDK 1.8, JDK 11
    - 4.1 : JDK 1.8, JDK 11
    - 5.0 : JDK 11, JDK 17
- JDK 11 버전을 이용하여 개발하는게 좋아보이지만, virtual thread 등 새로운 것들을 사용해보고 싶었다.
    - 초기 개발에서는 virtual thread 기능을 시도하지 않았고, 추후 기능들에 대해서 사용해보려고 한다.
- 해당 Webconsole 에 대해서 사용하게 된다면, Cassandra 서버에 기생하여 설치하기 보다는 옆에 따로 띄우는 경우가 더 많을 것 같다고 생각해서 Cassandra version 과는 다르게 우리가 해보고 싶은 version 으로 진행했다.

### 데이터베이스에 대한 고민
- 초기에 다른 프로젝트들을 참고하다보니, 단일 database 에 대해서만 운영할 수 있도록 개발 되어있었다.
- Multi Cluster 를 운영할 수 있게 한다면 장점이 있을 것 같아서 내부 Database 를 도입하여 운영할 수 있도록 목표를 설정했다.

#### 1안) Cassandra 를 이용하여 Multi Cluster 를 지원하자!!
- Cassandra Web Console 이니까, Cassandra 를 이용하여 클러스터 정보를 조회/저장/수정/삭제 등을 할 수 있게 하면 어떨까? 라는 고민을 시작함.
- 처음 Web Console 을 동작시켰을 때는 등록된 Cassandra 정보가 없으니 입력을 받아야겠다.
    - 이 설정을 프로퍼티로 받을까?
    - 그럼 처음 실행시키기 위한 작업이 추가되니, 진입장벽이 생기네....
    - 일단 실행 시키고 입력 받자!!
- 입력 받을려고 하니 저장 공간이 필요해짐.
- 파일로 저장하자. 음............ 이건 아닌거 같단 생각이 들었다.

#### 2안. File DB 를 두어 심플하게 관리하자.
- 1안을 검토하던 중 파일로 접속정보를 저장하여 관리하려고 하니, 그럴바에는 File DB 를 쓰는게 더 효율적일 것 같다고 생각했다.
- Sqlite, H2 등등 많은걸 검토했지만, 일단 초기에는 심플하게 가기위해 `[mapDB](https://jankotek.gitbooks.io/mapdb/content/)`라는걸 사용하게 됨.
    - SQL 을 작성 안해도 되서.... 너무 좋음.
- 다음 milestone 등에서 여러 기능들이 추가되게되면, 그때 다른 DB 를 검토하기로 함.
    - 빠른 개발을 위해 결정!

## Frontend 에 대한 고민
- 업무에서 Front 관련 작업을 많이 하지 않아서, 어떤걸 사용해도 공부가 많이 필요했다.
- 레퍼런스가 많은 `React` 를 이용하여 도움을 받기로 했다.

### css framework
- 예전 Bootstrap 으로 운영툴을 개발해 봤서 익숙한 걸 이용하여 빠르게 개발하기로 함.
- https://getbootstrap.com/

### Query Editor
- Javascript 로 Text Editor 등을 만들어서 쿼리를 직접 입력하여 실행할 수 있는 도구를 만들려고 했다.
- 직접 `textarea` 나 div 등에 `contenteditable ` 옵션을 부여하여 한땀한땀 도전하려고 했다.
    - 프로토타이핑을 해봤으나, 이번 프로젝트의 목표만큼의 개발 비용이 소요될 것 같다는 판단이 들었다.
    - 관련 오픈 소스를 검색해보다가 `React Ace` 라는 프로젝트를 찾게되었고, 도입 했다.
        - 이로인해 개발 비용이 많이 감소했다.

## 테스트에 대한 고민
### Cassandra 지원 버전
- docker compose 를 이용하여 test case 를 각 버전별 cassandra cluster 에 요청하여 지원하는지를 검증!
    - CI 를 강화하여 Unit Test 부터 Integ Test 까지 보강해나갈 예정.

![image](/assets/postimage/img.png)

## Readme 꾸미기
- 스크린샷 제작 : https://ezgif.com/
- icon 제작 : https://www.canva.com/create/icons/

## 결론
- 불편한걸 어떻게 하면 해소할 수 있을까를 고민했고,
- 목표를 설정하고, milestone 을 나눠서, 첫 버전을 명확하게 만들었다.
- 바퀴부터 한땀한땀 만들기보다는 일단 달릴 수 있게 만들어서 집단 지성을 이용하여 운영될 수 있게 기반을 만드는게 먼저다!
- 개발은 언제나 재미나다!!!!
