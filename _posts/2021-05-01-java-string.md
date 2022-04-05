---
layout: post
title: "Java String 에 대해서"
date: 2021-05-01 09:00:00 +0900
categories:
- java
tags:
- java
- string
---

- java.lang.String 클래스
- Java 에서 문자열을 위한 클래스
- 불변객체! (immutable)

# 1. String 다루기!
## 1-1. String 선언하기!
- 아래와 같이 선언해서 사용할 수 있다. 단, 두개는 큰 차이점을 가진다.(자세한 내용은 아래에서...)
```java
String str1 = "test String"; //리터럴 방식
String str2 = new String("test String"); // new 연산자를 이용한 선언
```

## 1-2. 문자열 합치기
- `+` 연산자를 사용하여 합치자.
```java
public class StringTest {
	public static void main(String[] args) {
		String prefixStr = "hello";
		String str = ", ";
		String postfixStr = "world!";

		String text = prefixStr + str + postfixStr;

		System.out.println(text);
	}
}
```

- 위 코드를 보면, String 은 불편이므로 새로운 객체로 text 가 생성될 것 입니다.
    - jdk 1.5 이하에서는 성능문제가 있었음.
    - 이후 개선됨. 개선된 내용을 바이트코드로 변환하여 확인해볼 수 있음.
```
javac StringTest.java
javap -v -p StringTest.java
```

## 1-3. 자주사용하는 method
#### 1-3-1. split
- 문자열을 정규식을 사용하여 특정 문자열 기준으로 분리해줌.
    - 주의할 점은 문자열이 정규식일 경우 `\`를 붙여줘야함.

```java
public String[] split(String regex) {
}
```

#### 1-3-2. equals
- 문자열 비교
- `==` 으로 비교할 수 없는 문자열 비교
    - `==` 으로도 문자열을 비교할 수는 있음. (자세한 내용은 아래에서)

#### 1-3-3. charAt(index)
- index 에 해당하는 char 를 반환

....

# 2. 문자열 비교연산자(`==`)와 `equals` 차이
- equals 는 문자열이 동일한지 확인
- 비교연산자(`==`)는 object 가 동일한지 확인

## 2-1. equals
- 모든 객체의 부모클래스인 Object 에 선언되어 있는 메소드

```java
String str1 = "test";
String str2 = "text";
String str3 = "test";

System.out.println("1. " + str1.equals(str2));
System.out.println("2. " + str2.equals(str1));
System.out.println("3. " + str1.equals(str3));

/*
 * 1. false
 * 2. false
 * 3. true
 */
```

- `String`의 `equals` 메소드를 확인해보면
    - 상단에 비교연산자(`==`)로 Object 가 같은지 확인을 먼저한다.
    - `equals` 사용시 주의할 점.
        - 인자값으로 null 이 입력될 경우 `NullPointerException` 이 발생함.
        - 문자열 비교시에 대소문자도 같이 비교하므로, 대소문자 구분이 필요없을 경우 `equalsIgnoreCase ` 를  사용하면 된다.

```java
public boolean equals(Object anObject) {
        if (this == anObject) {
            return true;
        }
        if (anObject instanceof String) {
            String anotherString = (String)anObject;
            int n = value.length;
            if (n == anotherString.value.length) {
                char v1[] = value;
                char v2[] = anotherString.value;
                int i = 0;
                while (n-- != 0) {
                    if (v1[i] != v2[i])
                        return false;
                    i++;
                }
                return true;
            }
        }
        return false;
    }
```

## 2-2. `==`
- 참조 비교

```java
String s1 = "Hello";
String s2 = "Hello";
String s3 = new String("Hello");
System.out.println(s1 == s2);
System.out.println(s1 == s3);

/**
* true
* false
**/
```

- 같은 문자열임에도 `s1`, `s2`는 같은데, `s3` 는 다르다.

# 3. String Constant Pool
- 위에서 설명한 `String` 선언 방법 중 `literal` 을 사용하게 되면, `constant pool 영역` 을 사용하게 되고, `new String()` 을 할 경우에는 heap 영역을 사용하게 된다.
    - `literal`의 경우 `String Constants Pool`에 있는지 확인 -> 있으면 반환 -> 없을 경우 `String Constants Pool`에 할당한 후 반환
    - 그렇기 때문에 `==` 을 통해서 비교를 할 경우, 같은 주소값을 가지고 있기 때문에 `s1`, `s2` 의 비교 결과가 `true` 인 것이다.
    - 추가로 `intern()` 를 호출하게되면 `s3` 역시 결과값이 `true` 로 리턴 될 것이다.
        - `intern()` 의 경우 `literal` 처럼 동작하도록 해줌.
- `String constant Pool`은 Jdk 7 이전에는 perm 영역에 저장되었으나, 이후에는 `Heap` 영역으로 옮겨졌다.
    - Jdk 6 이전에는 Permenent Generation 에 존재했었는데, 해당 영역은 사이즈가 고정되어 있어서 너무 많은 String 데이터를 사용한다면 OOM 이 발생함.
    -  `-XX:MaxPermSize={num}`을 통해서 늘릴 순 있지만, 이 또한 고정된 사이즈였다.
    - PermGen 영역은 GC 대상이 아니였으나, Heap 영역으로 들어가면서 GC 대상이 됨.
    - 추가로 jdk 8 부터는 PermGen 영역이 Metaspace로 이름이 변경되고 고정크기에서 동적크기로 메모리 구성이 변경됨.

## 3-1. String Constant Pool 구조
- HashTable 구조
- 값을 hashing 하여 key로 사용
- `StringTableSize`
    - jdk 7 의 경우 1009이고 jdk 11 의 경우 60013 크기를 가지고 있음.
    - `-XX:StringTableSize` 를 통해서 사이즈 변경 가능.
        - 사이즈는 소수를 사용해야 함. (http://java-performance.info/hashcode-method-performance-tuning/)

# 4. 왜 String은 immutable 일까?
- immutable 이란? 객체가 생성되고 내부의 상태가 변하지 않고 계속 유지되는 객체를 말함. 말 그대로 한번 할당한 값은 변경할 수 없다.

## 4-1. 장점.
- String 이 불변이기 때문에 `String Constants Pool`에서 String 을 관리할 수 있음.
    - 그렇기 때문에 메모리(Heap)를 절약할 수 있음.
        - 불변이 아니라면, 선언한 같은 문자열 String 이 계속 메모리에 할당되므로 비효율적일 수 있다.
- 보안상에 장점을 얻을 수 있다.
    - DB 접속 정보 등이 Mutable 하다면 공격들에 취약할 수 있음.
- Multi-Thread 에서 Thread-Safe 하다.
    - 값의 변경 가능성이 없음.
- Hashcode caching
    - 최초 1회만 실행.
    - 불변이기 때문에 캐싱하여 사용 가능
    - `Hash`시리즈(hashmap, hashtable, hashset) 에서 성능상 큰 이점을 볼 수 있다.

## 4-2. 단점
- 기존 String 을 수정하게 되면 그 전에 사용하던 String 객체는 GC 의 대상이 된다.
    - 변경이 많이 발생하게 되면 GC 대상이 많아짐...
    - 단점을 보완하기 위한 StringBuffer, StringBuilder 가 있음.
