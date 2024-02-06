---
layout: post
title:  "Counter 기능 구현하기!(조회수 등)"
date:   2024-02-02 09:00:00 +0900
categories:
- enhanced-experience
tags:
- database

---

- 특정 컨텐츠(글)에 대한 Counter(조회수) 기능을 구현할 때 어떤 문제점이 있고, 어떤 형태로 해결해 나갈 수 있는지를 정리한 글 입니다.
  - Counter : 조회수 등을 구현한 기능

## 현재 구조
- 컨텐츠 테이블
```sql
CREATE TABLE `article` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(45) NOT NULL,
  `content` TEXT NOT NULL,
  `status` VARCHAR(45) NULL,
  `read_count` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);
```

- Mysql 구조
  - Master, Slave 구조로 되어 있음.

- status 에 여러 상태값이 존재한다. (예시를 위해 몇개만 언급한다.)
  - `NORMAL` : 일반적인 노출상황
  - `DELETE` : 글이 제거된 상황
  - `DRAFT` : 글 초안인 상황(작성자에게만 노출?)

```sql
UPDATE `artitcle` SET 
`status` = #{status}
WHERE id = #{id}
```

- 조회수 관련 동작 방식
  -  사용자가 글을 읽는다. 동기 or 비동기로 조회수를 `UPDATE` 한다.
  - 실시간으로 업데이트를 한다.
  - 이력을 저장한다.

```sql
UPDATE `artitcle` SET 
read_count = read_count + 1
WHERE id = #{id}

insert into `article_read_history` (id, article_id, user_id, read_time) values (0, 1, '1234', now());
```

- 조회수 관련해서 SELECT 하기
  - 컨텐츠 내용이랑 포함해서 조회하기 때문에 추가 처리 영역은 없다.

## 문제 상황
- Master 에 변경이 발생할 경우, Slave 로 binary log 가 전달되어 Slave 에도 적용된다.
  - Mysql MMM 구조에 대한 내용 : https://mysql-mmm.org/mmm2_guide.html
- 조회수가 많이 발생하여 binary log 가 많이 발생한다.
- 중간에 `DRAFT` 에서 `NORMAL` 로 상태 변경처리가 진행된다.
  - 이전에 처리해야할 binary log 가 많아서 모든 slave 에서 master 와 다르게 다른 상태값이 노출되어 글이 없다고 나오는 등, `복제지연`이 발생한다.
- 이로 인해 많은 서비스 품질이 떨어질 수 있다.

### 추가....
- `postgreSQL` 의 경우 mvcc 구조로 인해서 다른 이슈가 더 있음. 해당 내용은 이정도만 언급

## 대응하기.
### 같은 database 만을 이용하여 대응하기.
- 조회수와 같은 Counter 데이터에 대해서 Table 을 분리하여 Join 또는 원본 테이블을 조회하여 in query 등을 사용하여 application 에서 조립하여 응답하는 형태로 대응 할 수 있다.

```sql
//INDEX 는 고려되지 않음.
CREATE TABLE `article_counter` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_id` INT UNSIGNED NOT NULL,
  `read_count` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);
```

```sql
UPDATE `article_counter` SET 
read_count = read_count + 1
WHERE article_id = #{id}
```

- `허나 이렇게 대응하더라도 binary log 는 많이 발생한다.`
- 조회수를 올리는 영역에서 `UPDATE` 를 제거하고, 이력만 저장해 놓은 다음에, `BATCH` 를 추가하여 묶음으로 처리하는 방법을 사용할 수 있다.
  - 빠르게 대응할 수 있는 방법 중 한다.

### 외부 DB 추가하기.
#### Redis 이용하기.
- `article_id` 하나 당 키 하나를 생성하여 아래 두개 operation 을 이용하여 조회수를 처리한다.
  - `INCR` : https://redis.io/commands/incr/
  - `DECR` : https://redis.io/commands/decr/
- 조회시에는 대상 `article_id` 들을 묶어서 아래 operation 으로 묶음 조회를 한다.
  - `MGET` : https://redis.io/commands/mget/

- 장점으로는...
  - 성능이 좋다.
- 단점으로는...
  - 이기종 Database 를 이용하므로 트랜잭션이 안된다.
    - 이 부분은 이력테이블이 있기 때문에 `BATCH` 처리로 후보정 할 수 있다.
  - Redis 는 inmemory DB 이기 때문에 비용이 비싸다. 비싸게 사용할만한 데이터 인지 꼭 확인해야한다.

#### Cassandra 이용하기.
- 블로그 글 참고하기
- 참고 링크 : https://docs.datastax.com/en/cql-oss/3.x/cql/cql_using/useCounters.html

- 장점으로는...
  - Redis 에 비해 SStable 이 Disk 에 쓰여지므로, 데이터가 많을 경우 훨씬 저렴하다.
- 단점으로는...
  - 러닝커브가 있다.
  - 초기 테이블을 어떻게 설계하느냐에 따라 성능차이가 크다.
    - 1회 쿼리시에 1개 파티션만 조회 가능함
    - 필요시 코루틴 등을 통한 구조를 설계할 수 있다.

## 결론
- 데이터 처리에 있어서 해당 데이터의 가치를 먼저 생각해야한다.
  - 가치에 따른 트랜잭션처리나 서버 또는 Database 를 선택할 수 있다.
- 방법은 여러가지가 있으므로 서비스 특성에 맞춰서 사용하면 좋다.
- 간단한 예시만 들었지만, 서비스가 점점 잘되어 가는 상황이라면 미리 준비해 놓는걸 추천한다.