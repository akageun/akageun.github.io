---
layout: post
title:  "[다시보기 Mysql] 3. Isolation level"
date:   2023-03-31 09:00:00 +0900
categories:
- database
tags:
- mysql
---

격리 수준 | DIRTY READ | NON-REPEATABLE READ | PHANTOM READ
| -- | -- | -- | --
READ UNCOMMITTED | O | O | O
READ COMMITTED |  | O | O
REPEATABLE READ |  |  | O(InnoDB는 발생 X)
SERIALIZABLE |  |  | 

## READ UNCOMMITTED : 커밋되지 않은 읽기
- 트랜잭션에서 변경 내용이 `COMMIT` 또는 `ROLLBACK` 여부에 상관 없이 다른 트랜잭션에서 조회됨.

- `더티 리드(Dirty Read)` : 완료가 되지 않은 작업에 대한 결과를 볼 수 있게 되는 현상

## READ COMMITTED : 커밋된 읽기
- 많이 사용되는 격리 수준
- `더티 리드` 는 발생하지 않음.
- `COMMIT` 된 데이터만 조회됨.
- `Phantom Read` 가 발생할 수 있음.

## REPEATABLE READ : 반복 가능한 읽기

## SERIALIZABLE : 직렬화 가능