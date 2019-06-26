---
layout: post
title:  "IntStream, LongStream 내 range, rangeClosed 사용해보기."
date:   2018-07-16 00:00:00 +0900
categories:
 - java
tags: 
 - string
---
# 1. X Stream
- IntStream 은 int를 지정한 범위 내에서 반복문을 동작함
- LongStream dms Long을 지정한 범위 내에서 반복문을 동작함

# 2. range, rangeclosed
- range는 endExclusive 값 전까지만 반복
- rangeClosed는 endExclusive 를 포함하여 반복

# 3. IntStream
- 소스

```java
public class IntRangeTest {

   public static void main(String[] args) {
      int startNum = 1;
      int endNum = 9;

      intRangeTest(startNum, endNum);
      System.out.println("\n");
      intRangeClosedTest(startNum, endNum);

      System.out.println("\n");
   }

   private static void intRangeTest(int startNum, int endNum) {
      System.out.print("IntRange Test 1 : ");
      IntStream.range(startNum, endNum).forEach(System.out::print);

      System.out.println();

      System.out.print("IntRange Test 2 : ");
      for (int i = startNum; i < endNum; i++) {
         System.out.print(i);
      }
   }

   private static void intRangeClosedTest(int startNum, int endNum) {
      System.out.print("IntRangeClosed Test 1 : ");
      IntStream.rangeClosed(startNum, endNum).forEach(System.out::print);

      System.out.println();

      System.out.print("IntRangeClosed Test 2 : ");
      for (int i = startNum; i <= endNum; i++) {
         System.out.print(i);
      }
   }
}
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/60099400-842be780-9792-11e9-9608-a3067ddae7f7.png)

# 4. LongStream
- 소스
```java
public class LongRangeTest {

   public static void main(String[] args) {
      long startNum = 1L;
      long endNum = 9L;

      longRangeTest(startNum, endNum);
      System.out.println("\n");
      longRangeClosedTest(startNum, endNum);

      System.out.println("\n");
   }

   private static void longRangeTest(long startNum, long endNum) {
      System.out.print("LongRange Test 1 : ");
      LongStream.range(startNum, endNum).forEach(System.out::print);

      System.out.println();

      System.out.print("LongRange Test 2 : ");
      for (long i = startNum; i < endNum; i++) {
         System.out.print(i);
      }
   }

   private static void longRangeClosedTest(long startNum, long endNum) {
      System.out.print("LongRangeClosed Test 1 : ");
      LongStream.rangeClosed(startNum, endNum).forEach(System.out::print);

      System.out.println();

      System.out.print("LongRangeClosed Test 2 : ");
      for (long i = startNum; i <= endNum; i++) {
         System.out.print(i);
      }
   }
}
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/60099415-8aba5f00-9792-11e9-8a40-ecc640e77770.png)