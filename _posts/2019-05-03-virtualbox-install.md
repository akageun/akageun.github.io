---
layout: post
title:  "VirtualBox install"
date:   2019-05-03 00:00:00 +0900
---

# 설치 전 준비
#### Virtual Box download
- https://www.virtualbox.org/

#### Centos 7 download
- https://www.centos.org/download/
- Minimal 버전을 다운로드 한다.
- mirror 서비스(navercorp으로 다운로드 한다. 다른걸로 하셔도 됩니다.)
- http://mirror.navercorp.com/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso

#### Centos 버전관련
- Minimal ISO : 심플한 버전으로 필요한 패키지들만 들어있음.
- DVD ISO : 필요한 대부분의 패키지들이 포함되어 있음. 일반유저에게 추천하지만, 용량이 크다.

# 설치
## VirtualBox 설치
- 따라하면 손쉽게 가능하다.

![image](https://user-images.githubusercontent.com/13219787/59287495-b6c2e400-8cac-11e9-9146-0988199a5875.png)

- 설치 후 실행

![image](https://user-images.githubusercontent.com/13219787/59287522-c6422d00-8cac-11e9-9f42-9ac3aa4fdd1d.png)

## VirtualBox 내에 Centos 설치
#### 머신설정
- 새로만들기 클릭

![image](https://user-images.githubusercontent.com/13219787/59287555-d5c17600-8cac-11e9-91c0-0e67cfe03787.png)
 
- 메모리 설정 : (2기가)

![image](https://user-images.githubusercontent.com/13219787/59287571-deb24780-8cac-11e9-938c-3cfa3ff82805.png) 

###### 하드디스크 설정 : (8기가)

![image](https://user-images.githubusercontent.com/13219787/59287589-ee319080-8cac-11e9-816e-fe6ae11d1454.png)

- 가상 디스크 설정

![image](https://user-images.githubusercontent.com/13219787/59287619-fb4e7f80-8cac-11e9-8af8-99f6f93f65b3.png)

- 할당

![image](https://user-images.githubusercontent.com/13219787/59287648-09040500-8cad-11e9-8cb7-6dde5c2b12e3.png)


- 위치설정

![image](https://user-images.githubusercontent.com/13219787/59287664-128d6d00-8cad-11e9-8b3e-158622765bee.png)
 

#### ISO 파일 설정
- 생성한 가상머신 선택 -> 설정 -> 저장소 -> 비어있음 -> 속성(디스크모양 클릭) -> 조금 전 다운받은 Centos ISO 파일 선택

![image](https://user-images.githubusercontent.com/13219787/59287691-2042f280-8cad-11e9-98c2-2364021c3c55.png)


#### 시작
- 시작버튼 클릭

![image](https://user-images.githubusercontent.com/13219787/59287731-39e43a00-8cad-11e9-8b94-ac2fcce61656.png)

- 한국어 대신 영어로 설치(디버깅할 때 편함)

![image](https://user-images.githubusercontent.com/13219787/59287750-45376580-8cad-11e9-83f6-c2f1548a0014.png)


- 자판은 한국어 추가!

![image](https://user-images.githubusercontent.com/13219787/59287784-56807200-8cad-11e9-90eb-77cf17736ff7.png)
 
![image](https://user-images.githubusercontent.com/13219787/59287828-6ac46f00-8cad-11e9-9941-68a34d391b75.png)

- 네트워크 설정

![image](https://user-images.githubusercontent.com/13219787/59287842-74e66d80-8cad-11e9-8bd4-49a8efb259ab.png)

- 파티션 설정

![image](https://user-images.githubusercontent.com/13219787/59287873-8465b680-8cad-11e9-9ba9-ac4979c0f4a6.png)

- ROOT 설정 및 유저 생성

![image](https://user-images.githubusercontent.com/13219787/59287892-90517880-8cad-11e9-83fb-894acb3e9f3e.png)
 
- 리붓하고 root로 로그인!

![image](https://user-images.githubusercontent.com/13219787/59287939-a2cbb200-8cad-11e9-9137-4b5c803dbe32.png)


- 개발자 도구 설치

> sudo yum group install "Development Tools"

## 참고
#### CentOS 7 최소설치시 ifconfig가 없다고 나올때
- ifconfig 입력시

> -bash: ifconfig: command not found

- CentOS 7 버전부터는 ifconfig에서 ip 라는 명령어로 대체
- ifconfig 관련 설치

> yum -y install net-tools
