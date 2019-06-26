---
layout: post
title:  "try-catch-resources"
date:   2018-04-11 00:00:00 +0900
categories:
 - java
tags: 
 - java
---
# 1. try-catch-resources
- try (...) 안에 선언된 입출력 스트림 등의 리소스 객체의 'close()' 메소드를 호출해줌. 자원관리를 잘 해줌.
- java 7 에서 추가된 기능.

# 2. 소스 비교
## 1) 1.6 이전

```java
FileInputStream fs = null;
try {
   fs = new FileInputStream("file.txt");

} catch (IOException e) {
   System.out.println(e.getMessage());
} finally {
   if (fs != null) {
      try {
         fs.close();
      } catch (IOException e1) {
         System.out.println(e1.getMessage());
      }
   }
}
```

## 2) 1.7 이상
- 단, 인터페이스인 java.lang.AutoCloseable를 구현해야 사용가능함.
- 귀찮은 finally 안에 소스를 안만들어도 된다. 

```java
try (FileInputStream fs = new FileInputStream("file.txt");) {

} catch (IOException e) {
   System.out.println(e.getMessage());
}
```

- 커스텀하게 구현할 수도 있다.

```java
public class CustomFileInputStream implements AutoCloseable {

   @Override
   public void close() throws Exception {

   }
}
```

# 3. Close 동작 확인

## 1) 정상 동작시에 Close 메소드 호출 여부 확인

#### (1) 샘플 소스 확인
- 실행 시킬 Main Class
```java
public class Sample {

   public static void main(String[] args) throws Exception {

      try (CustomFileInputStream cfs = new CustomFileInputStream()) {
         System.out.println("Try 안에 호출 잘 됩니다.");

      } catch (Exception e) {
         System.out.println("에외가 발생했습니다.");

      }

      System.out.println("완료!");
   }

}
```

- Custom한 Class

```java
/**
 * Custom 메소드
 *
 * @author akageun
 */
public class CustomFileInputStream implements AutoCloseable {

   @Override
   public void close() throws Exception {
      System.out.println("Close 메소드가 호출 되었습니다.");
   }
}
```


#### (2) 결과

![image](https://user-images.githubusercontent.com/13219787/60100754-5d22e500-9795-11e9-9e18-f700e0c7d7d2.png)

## 2) 예외가 발생 했을 때 Close 메소드 호출 여부 확인

#### (1) 샘플 소스 확인
- 실행 시킬 Main Class

```java
public class Sample {

   public static void main(String[] args) throws Exception {

      try (CustomFileInputStream cfs = new CustomFileInputStream()) {
         System.out.println("Try 안에 호출 잘 됩니다.");
         throw new RuntimeException("테스트 예외 호출 ");


      } catch (Exception e) {
         System.out.println("에외가 발생했습니다. " + e.getMessage());

      }

      System.out.println("완료!");
   }

}
```

- Custom한 Class는 위에 Class와 동일한걸로 사용

#### (2) 결과

![image](https://user-images.githubusercontent.com/13219787/60100768-61e79900-9795-11e9-8eff-94845f2a5660.png)