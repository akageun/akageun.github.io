---
layout: post
title:  "BloomFilter 에 대해서"
date:   2023-07-23 09:00:00 +0900
categories:
- program
tags:
- 자료구조
- cassandra
---

- 먼저, `BloomFilter`란? `특정 집합에 어떤 값이 존재하는지 여부를 확인하는 확률적 자료구조` 다.
  - 대규모 시스템에서 중복여부를 효율적으로 처리 할 수 있는 방법 중 하나!

## 주요 특징
- 0과 1로 구성되어 있으므로 실제 데이터를 이용한 처리 보다 작은 크키로 처리가 가능
  - 이러한 부분 때문에 적은 메모리로 효율적인 작업이 가능, DB(Cassandra 등..) 등에서 많이 사용 됨.
- 언제나 정확한 값을 얻는건 아니다. `아마도 있을걸?` 과 같이 가능성을 확인하거나, `정확하게 아니다!` 를 확인 할 수있다.
  - 경우에 따라 `false positive` 가 발생한다.
  > `거짓 긍정(false positive)`란 실제 데이터가 없는데 있다고 판단 하는 경우
  - 이런 경우 db 나 실제 데이터를 조회하는 형태로 부하를 줄 일 수 있다.
- 추가된 요소들을 삭제할 수 없다.
  - 구현된 코드들을 보면 `clear()`와 같은 코드만 있고, remove 같은 메소드는 대부분 구현되어 있지 않음.

## 테스트 페이지
- http://llimllib.github.io/bloomfilter-tutorial/
- 해당 페이지를 통하여 bloomfilter 에 대해서 이해도를 올릴 수 있다!

## java 로 직접 사용해보기
- beta 로 되어있긴 하지만, 학습 목적으로는 괜찮은 것 같음

```groovy
implementation 'com.google.guava:guava:32.1.1-jre'
```

```java
import com.google.common.hash.BloomFilter;
import com.google.common.hash.Funnels;

  public static void main(String[] args) {
        int expectedInsertions = 1000;
        double falsePositiveRate = 0.01;

        // Bloom 필터 생성
        BloomFilter<String> bloomFilter = BloomFilter.create(Funnels.unencodedCharsFunnel(), expectedInsertions, falsePositiveRate);

        // 문자열 추가
        String value1 = "example1";
        String value2 = "example2";
        bloomFilter.put(value1);
        bloomFilter.put(value2);

        // 문자열 멤버십 확인
        String queryValue = "example1";
        if (bloomFilter.mightContain(queryValue)) {
        System.out.println("Bloom 필터가 " + queryValue + "을(를) 포함할 수 있습니다.");
        } else {
        System.out.println("Bloom 필터가 " + queryValue + "을(를) 포함하지 않습니다.");
        }

        queryValue = "example3";
        if (bloomFilter.mightContain(queryValue)) {
        System.out.println("Bloom 필터가 " + queryValue + "을(를) 포함할 수 있습니다.");
        } else {
        System.out.println("Bloom 필터가 " + queryValue + "을(를) 포함하지 않습니다.");
        }
  }
```

- result
  - 1, 2번째는 `아마도 있을껄?`, 3번째 결과는 `없다.`
> check : true, true, false

## 추가..
- `function_size` 가 실제 데이터 사이즈보다 작을 경우 `false positive` 발생할 확률이 높다.
  - 그럴 경우 maybe 를 검증하기 위한 비용이 추가 될 것이다.

---
## 참고페이지
- https://d2.naver.com/helloworld/749531
- https://meetup.nhncloud.com/posts/192