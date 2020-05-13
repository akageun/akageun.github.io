---
layout: post
title:  "[Spring data jpa] tip 시리즈! - Enum 처리 "
date:   2019-09-04 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - jpa
 - tip
 - java
 - enum
---

- Spring data jpa 를 사용하면서 얻은 팁들을 정리한 문서

# Enum 값 사용하기
- Entity 내에 enum 값을 사용할 경우, Enum.name() 와 같이 String 으로 처리하는 경우가 있다.
- enum 자체를 DB 에 넣고, 관리할 수 있는 방법이 있다.

#### 코드

###### entity    
```java
@Entity
@Table(name = "circle")
public class CircleEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //@Enumerated(EnumType.ORDINAL)
    private ColorType colorType;

    private int size;

}
```

###### repository
```java
public interface CircleRepo extends JpaRepository<CircleEntity, Long> {
}
```

###### ColorType enum
```java
public enum ColorType {
    GREY("142, 142, 147"),
    RED("255, 59, 48"),
    GREEN("76, 217, 100"),
    PURPLE("88, 86, 214"),
    LIGHTBLUE("52, 170, 220");

    private String rgb;

    ColorType(String rgb) {
        this.rgb = rgb;
    }
}
```

###### save 로직
```java
circleRepo.save(
    CircleEntity.builder()
        .colorType(ColorType.GREEN)
        .size(100)
        .build()
);
```

## @Enumerated 사용하기
- Entity class 내에 enum 위에 달아준다.

#### enum 위에 annotation이 없거나 @Enumerated(EnumType.ORDINAL) 인 경우
- `@Enumerated` 가 없을 경우 enum 순서가 들어간다. (`@Enumerated(EnumType.ORDINAL)` 를 사용해도 같다.)
- enum 값이 리팩토링 등으로 인해 순서가 바뀔 수 있으므로, 굉장히 위험하다.
- 아래는 annotation 없는 상태에서 insert 후 select 한 결과다.
       
![image](https://user-images.githubusercontent.com/13219787/64184437-696aa300-cea6-11e9-931c-82081178beec.png)

#### @Enumerated(EnumType.STRING) 
- enum.name()과 같이 enum 값 그대로 문자열로 넣을 수 있는 방법

```java
@Enumerated(EnumType.STRING)
private ColorType colorType;
```

#### 결과

![image](https://user-images.githubusercontent.com/13219787/64184251-28728e80-cea6-11e9-9dd1-eac25297e6b6.png)

## @Converter 사용하기
- enum 내에 특정 code 값을 database value 에 넣을 수도 있다.
    - 예제로 위에서 생성한 ColorType 내에 name이 아닌 rgb 값을 db에 넣고 출력해보자.

###### Converter Class
- `convertToDatabaseColumn()` : Enum -> Database Value
- `convertToEntityAttribute()` : Database Value -> Enum

```java
@Converter
public class ColorTypeConverter implements AttributeConverter<ColorType, String> {
    @Override
    public String convertToDatabaseColumn(ColorType attribute) {
        return attribute.getRgb();
    }

    @Override
    public ColorType convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }

        try {
            return ColorType.fromCode(dbData);
        } catch (IllegalArgumentException e) {
            log.error("failure to convert cause unexpected code [{}]", dbData, e);
            throw e;
        }
    }
}
```

###### Entity

```java
@Convert(converter = ColorTypeConverter.class)
private ColorType colorType;
```

#### 결과

![image](https://user-images.githubusercontent.com/13219787/64187873-51961d80-ceac-11e9-9966-54dfb45ccd07.png)


---
## 샘플 소스
- https://github.com/akageun/spring-boot-sample/tree/master/h2_jpa

## 참고소스
- http://woowabros.github.io/experience/2019/01/09/enum-converter.html
