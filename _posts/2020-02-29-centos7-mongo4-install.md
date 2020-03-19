---
layout: post
title:  "mongodb install in centos 7"
date:   2020-02-29 09:00:00 +0900
categories:
 - database
tags: 
 - mongo
 - linux
---
# mongodb install in centos 7
- mongodb 4.2 를 설치할 예정

## mongodb 설치
- repo를 추가해주자.

> sudo vi /etc/yum.repos.d/mongodb-org.repo

- 아래 내용을 복사해서 붙여넣는다.

```
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
```
#### 추가가 잘되었는지 확인!
> yum repolist

- 결과

> mongodb-org-4.2/7                       MongoDB Repository                    10

#### yum 설치
> sudo yum install -y mongodb-org

> Complete! # 와 같이 로그가 찍히면 완료!

## 명령어 익히기
#### 몽고디비 시작하기
> sudo systemctl start mongod

#### 몽고디비 정지
> sudo systemctl stop mongod

#### 몽고디비 리로드
> sudo systemctl reload mongod

#### 몽고디비 상태체크
> sudo systemctl status mongod

#### 서버가 리부팅 되었어도 자동으로 mongodb를 자동 실행시킬 수 있게 하는 명령어
> sudo systemctl enable mongod

#### 몽고디비 로그 확인
- `-f` 옵션을 통해 실시간으로 로그를 볼 수 있다.

> sudo tail -f /var/log/mongodb/mongod.log

## 설정 변경
- 설정파일을 찾아서 vi 로 연다.

> sudo vi /etc/mongod.conf

#### port 변경
- 기본으로 사용하는 `27017` 는 너무 많이 알려져 있으므로, 안전하게 다른 포트로 변경할 수 있다.

#### 외부접속 오픈
- 기존 설정은 `bindIp: 127.0.0.1` 와 같이 되어 있다. 내부에서만 접근 가능하므로, 모든 곳에서 접근가능하게 하고 싶을 경우에는 `bindIp: 0.0.0.0` 으로 변경하면됨.

- 추가적으로 방화벽도 오픈
```
firewall-cmd --permanent --zone=public --add-port=27017/tcp
firewall-cmd --reload
```

## cli 로 몽고접속하기
> mongo 

- `db.version()` 을 통하여 설치버전 확인. 4.2.1로 원하던 버전을 정상 설치했다.

> db.version()

> 4.2.1

## 관리자 계정생성
- mongodb를 시작할 때 경고문구가 뜬다. 그걸 없애보자.
- `mongo` 명령어를 사용하여 몽고에 접속한다.
- admin 계정에 접속한다.

> use admin

> switched to db admin # 이렇게 로그가 찍힘.

```
db.createUser(
  {
    user: "newAdmin", 
    pwd: "changeThisValue", 
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```

- 결과

```
Successfully added user: {
	"user" : "newAdmin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}
```

- 위 role 과 관련된 상세내용은 [링크](https://docs.mongodb.com/manual/tutorial/manage-users-and-roles/)를 통해 확인하자.

#### config 파일을 열자
> vi /etc/mongo.conf

- `security` 앞에 #(주석)을 제거하고 옵션을 추가하자

```
security:
 authorization: enabled
``` 

> sudo systemctl restart mongod 

- 재시작 후 `mongo` 를 접속하면 경고문구가 사라진 것을 볼 수 있다.

## 사용자 계정 생성
#### 사용할 DB
> use test_db

#### 유저 생성
```
db.createUser(
  {
    user: "testUser",
    pwd: "q1w2e3r4",
    roles: [ { role: "readWrite", db: "test_db" } ]
  }
)
```

- 아래와 같이 insert하게 되면 collection이 추가함.

> db.test_collection.insert({ some_key: "some_value" })

- 아래 명령어로 검색할 수 있다.

> db.test_collection.find();

#### 쉘로 접속하고 싶을 경우
> mongo --port 27017 -u 'testUser' -p 'q1w2e3r4' --authenticationDatabase 'test_db'

# 추가로 설치한 mongo DB 를 지우고 싶을 경우
#### 몽고디비 정비
> sudo service mongod stop

#### Packages 제거.
> sudo yum erase $(rpm -qa | grep mongodb-org)

#### Data 관련 내용 삭제
> sudo rm -r /var/log/mongodb
> sudo rm -r /var/lib/mongo

---
## 참고링크
- [공식사이트](https://www.mongodb.com/)
- https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/
