—
layout: post
title:  “자주 사용하는 docker 명령어 모음”
date:   2020-05-01 09:00:00 +0900
categories:
 - docker
tags: 
 - docker
 - command
—

## 프로세스 확인하기



## 삭제처리
#### 컨테이너 삭제
- container id 를 여러개 넣을 수 있다

> docket rm {container id} {container id}

#### 모든 컨테이너 삭제
> docker rm `docker ps -a -q`

#### 이미지 삭제
- image id 를 여러개 넣을 수 있다.

> docker rmi {image id} {image id}

###### 강제로 제거하기
- 해당 이미지가 사용중이거나 할 때 강제로 제거 하는 옵션 `-f`

## 로그보기
#### 명령어
> docker logs {container id}

###### 옵션 
- `-f` : 실시간으로 로그를 출력함
- `-t` : timestamp를 표시함

    > docker logs -ft {container id}

- `-tail` : 하위 n개의 로그를 출력함(tail 과 비슷한 기능을 함)

    > docker logs -tail 10 {container id}
    