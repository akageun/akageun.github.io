---
layout: post
title:  "StringBuffer, StringBuilder 그리고 String"
date:   2018-07-23 09:00:00 +0900
categories:
 - java
tags: 
 - string
---
# 1. 세가지 공통점
- 문자열을 처리하는 Class

# 2. String 과 (StringBuffer, StringBuilder)의 차이점
- 메모리 상에서 처리방식에서 차이점이 있다.
- String은 immutable(변경불가) 이고, StringBuffer는 mutable이다.

# 3. StringBuffer, StringBuilder 두개의 차이점
- 1) StringBuffer
    - append 메소드

```java
@Override
public synchronized StringBuffer append(Object obj) {
    toStringCache = null;
    super.append(String.valueOf(obj));
    return this;
}
```

- 2) StringBuilder
    - append 메소드

```java
@Override
public StringBuilder append(Object obj) {
    return append(String.valueOf(obj));
}
```

# 4. 결론
- 단순한 처리일 경우 String 을 사용해도 크게 문제 안됨.
- multi thread 환경에서는 StringBuffer를 사용하는게 안전하다. 그렇지 않을 경우라면 StringBuilder가 더 빠르다. 아래 소스를 참고하자.

```java
public class StrTest {

   public static void main(String[] args) {

      strBufferTest();
      strBuilderTest();
   }

   private static void strBufferTest() {
      Date start = new Date();
      StringBuffer stringBuffer = new StringBuffer();

      new Thread(() -> {
         IntStream.range(1, 10000).forEach(num -> {
            stringBuffer.append(num);
         });

      }).start();

      new Thread(() -> {
         IntStream.range(1, 10000).forEach(num -> {
            stringBuffer.append(num);
         });

      }).start();

      new Thread(() -> {
         Date end = new Date();
         long millis = end.getTime() - start.getTime();

         try {
            Thread.sleep(5000);

            System.out.println("StringBuffer length : " + stringBuffer.length());
            System.out.println("StringBuffer time(ms) :" + millis);

         } catch (InterruptedException e) {
            e.printStackTrace();
         }
      }).start();
   }

   private static void strBuilderTest() {
      Date start = new Date();
      StringBuilder stringBuilder = new StringBuilder();
      new Thread(() -> {
         IntStream.range(1, 10000).forEach(num -> {
            stringBuilder.append(num);
         });

      }).start();

      new Thread(() -> {
         IntStream.range(1, 10000).forEach(num -> {
            stringBuilder.append(num);
         });

      }).start();

      new Thread(() -> {
         Date end = new Date();
         long millis = end.getTime() - start.getTime();

         try {
            Thread.sleep(5000);

            System.out.println("StringBuilder length : " + stringBuilder.length());
            System.out.println("StringBuilder time(ms) :" + millis);

         } catch (InterruptedException e) {
            e.printStackTrace();
         }
      }).start();

   }
}
```

- 위 소스 결과

![image](https://user-images.githubusercontent.com/13219787/60099211-2bf4e580-9792-11e9-92d7-5126a3b63bb7.png)

- JDK 1.5버전 부터인지 정확하지는 않지만 String 선언시 문자열을 '+'하는 형태로 작업 할 경우 컴파일시에 StringBuilder로 변경됨.





## 참고 페이지
- https://www.slipp.net/questions/271
- https://lalwr.blogspot.com/2016/02/string-stringbuffer-stringbuilder.html