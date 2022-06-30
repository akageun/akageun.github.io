---
layout: post
title:  "[다시보기 Mysql] 2. Storage Engine & Transaction"
date:   2022-06-25 09:00:00 +0900
categories:
- database
tags:
- mysql
---

# Storage Engine
- 데이터를 직접적으로 다루는 역할을 하고 엔진마다 동작 원리가 다르다.
  - 그래서 각 엔진마다 transaction, 성능 등 다르게 동작한다.
- Mysql 스토리지 엔진은 Plugin 방식으로 구현되어 있고, 아래 명령어로 종류를 확인 할 수 있다.

> SHOW ENGINES;


- Table 생성시에 ENGINE 선택

```sql
CREATE TABLE a (no INT) ENGINE = INNODB;
```

- 현재 생성된 Table 의 엔진 확인

```sql
SHOW TABLE STATUS
```

## 관련 링크
- https://dev.mysql.com/doc/refman/8.0/en/storage-engines.html
- http://asuraiv.blogspot.com/2017/07/mysql-storage-engine.html
- https://nomadlee.com/mysql-%EC%8A%A4%ED%86%A0%EB%A6%AC%EC%A7%80-%EC%97%94%EC%A7%84-%EC%A2%85%EB%A5%98-%EB%B0%8F-%ED%8A%B9%EC%A7%95/

# Transaction 이란?
- 쪼개질 수 없는 업무처리의 단위
- 안전성을 확보하기 위한 방법

# Transaction 특징
- Transaction 이 안전하게 수행된다는 것을 보장하기 위한 특징
- ACID 

#### 원자성 (Atomicity)	
- DB에 모두 반영되거나, 혹은 전혀 반영되지 않음

#### 일관성 (Consistency)
- 작업 처리 결과는 항상 일관성이 있어야함.

#### 독립성 (Isolation)	
- 동시에 두개 이상의 트랜잭션이 병행 실행되고 있을 때, 다른 트랜잭션 영향을 줄 수 없다.

#### 영구성 (Durability)	
- 트랜잭션이 성공적으로 완료 되었으면 결과는 영구적으로 반영


# Transaction 을 처리하기 위한 명령어

## Commit
- 하나의 트랜잭션 처리가 성공적으로 끝났을 때 

## Rollback
- 한개의 트랜잭션 처리가 비정상 종료되어 원자성이 깨졌을 경우에 트랜잭션을 처음부터 다시 시작하거나, 부분적으로만 연산된 결과를 다시 취소시킴


## Mysql 에서는?
```sql
START TRANSACTION;

(Transaction)

COMMIT; (or ROLLBACK;)
```

- 직접 table 을 생성하여 테스트 해보자

> use test; #database 선택

- table 생성

```sql
CREATE TABLE `test`.`temp-test` (
`no` INT NOT NULL AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
PRIMARY KEY (`no`));
```

### commit 테스트
```sql

START TRANSACTION;

insert into `test`.`temp-test` (`name`) values ('akageun');

COMMIT;
```

#### 결과
```sql
select * from `test`.`temp-test`;
```

![image](https://user-images.githubusercontent.com/13219787/176707116-59efde10-218a-4460-b392-50adc200536e.png)

### rollback 테스트
```sql

START TRANSACTION;

insert into `test`.`temp-test` (`name`) values ('akageun2');

ROlLBACK;
```

#### 결과 확인
- 위 commit 처럼 테스트 했을 때, 결과가 다르지 않음.
- `commit` 을 다시 테스트 해보자
  - PK 가 하나 증가한 상태로 입력된게 보인다. 
  
![image](https://user-images.githubusercontent.com/13219787/176707664-9bef5662-3099-4a0a-aab5-b615d807b03d.png)


# 참고사항
- MySQL의 엔진에 영향을 받음
- InnoDB 로 사용해야 Transaction 을 사용할 수 있다.