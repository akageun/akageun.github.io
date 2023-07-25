---
layout: post
title:  "[About Cassandra] Cassandra Internal - 1"
date:   2023-07-25 09:00:00 +0900
categories:
- database
tags:
- cassandra
---

- Cassandra 내부 특징 등에 대해서 하나씩 살펴 볼려고 한다.
- 

# LSM Tree
- 

## bloom filter
- [링크](./2023-07-23-bloom-filter-01.html)

# Gossip Protocol
## Gossip Protocol 이란?
- 분산 환경에서 메시지를 전달하는 커뮤니케이션 방식 중 하나
- broadcast 해주는 master node 없이 각 node 가 tcp/udp 를 기반으로 메타데이터를 주고 받으면서 데이터를 전송함.
  - 서로 주기적으로 health check 를 함.
    - peer to peer (p2p) 통신
    - 신뢰성 보장 안함.

# Cassandra 에서 사용하는 이유
- 