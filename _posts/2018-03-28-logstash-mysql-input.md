---
layout: post
title:  "[LOGSTASH] 02. Logstash Mysql input 사용하기"
date:   2018-03-28 09:00:00 +0900
categories:
 - elastic
tags: 
 - logstash
 - mysql
---

# 1. conf파일 기본 형태
```
#데이터를 가지고옴.
input {
}

#데이터를 가공함.
filter {
}

#데이터를 출력함.
output {
}
```

# 2. mysql에서 데이터 가져와서 파일로 생성해보기.
## 1) mysql-connector를 직접 다운받아, path를 지정해줘야함.
#### (1) connector 다운로드

> wget 'https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz'

 - 'https://dev.mysql.com/downloads/connector/j/' 링크를 통해서 직접 다운로드 받을 수도 있다.

#### (2) 압축풀기

> tar -xvf ./mysql-connector-java-5.1.46.tar.gz

#### (3) 파일이동
- 필요한 파일만 원하는 디렉토리로 이동

> mv ./mysql-connector-java-5.1.46/mysql-connector-java-5.1.46.jar ./lib/mysql-connector-java-5.1.46.jar

#### (4) 불필요한 파일 삭제

> rm -rf ./mysql-connector-java-5.1.46*

- pwd 명령어를 사용하면 편하게 path를 가져올수있음.

## 2) mysql로 input 사용

#### (1) plugin 확인

> bin/logstash-plugin list jdbc

- 없을 경우 install 해야한다.

> bin/logstash-plugin install logstash-input-jdbc

#### (2) input conf
```
input {
  jdbc {
    jdbc_driver_library => "~/lib/mysql-connector-java-5.1.46.jar"
    jdbc_driver_class => "com.mysql.jdbc.Driver"
    jdbc_connection_string => "jdbc:mysql://localhost:3306/database_name?useUnicode=true&characterEncoding=utf8&useSSL=false"
    jdbc_user => "user_name"
    jdbc_password => "user_password"
    statement => "SELECT 1 FROM DUAL"
  }
}
```

- 옵션설명(https://www.elastic.co/guide/en/logstash/6.2/plugins-inputs-jdbc.html)

옵션명 | 기능 | 비고
-- | -- | --
jdbc_driver_library | mysql-connector 라이브러리 위치 | 앞에서 다운받은 위치
jdbc_driver_class | 드라이버 클래스 | Mysql : com.mysql.jdbc.Driver
jdbc_connection_string | Connect String 설정 |  
jdbc_user | 계정명 |  
jdbc_password | 계정 비밀번호 |  
statement | 조회하려는 쿼리 | SELECT 1 FROM DUAL

#### (3) 간단하게 확인하기 위해 json 형태로 출력하자
```
output {
  stdout { codec => json }
}
```

#### (4) 실행 확인
- 문법확인도 함께 하려면 옵션에 -t 를 추가한다.

> bin/logstash -f ~/sample.conf

- 응답

```
[INFO ][logstash.inputs.jdbc     ] (0.041156s) SELECT 1 FROM DUAL
{"1":1,"@version":"1","@timestamp":"2018-03-22T07:44:43.471Z"}
```
