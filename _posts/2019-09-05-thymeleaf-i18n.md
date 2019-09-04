---
layout: post
title:  "Spring Boot 다국어처리 with Thymeleaf"
date:   2019-09-05 09:00:00 +0900
categories:
 - spring
tags: 
 - thymeleaf
 - i18n
 - messageSource
---

- spring boot web에서 view template 인 `thymeleaf`를 사용할 경우, 다국어처리에 대한 방법을 공유합니다.

## 라이브러리
#### pom.xml
```xml
 <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

#### gradle
```gradle
compile group: 'org.springframework.boot', name: 'spring-boot-starter-thymeleaf'
```

## configuration

#### LocaleResolver 설정
- locale을 결정하는 설정
- Session, Cookie 등의 방법으로 저장할 수 있다.(현재 설정 값)
    - `SessionLocaleResolver` : 세션을 사용
    - `CookieLocaleResolver` : Cookie 를 사용
    
- 예제는 Default 값을 `한국어`로 설정하고 Cookie를 사용하여 `THYMELEAF_LANG` 라는 cookie 명으로 사용할 예정이다.

```java
@Bean
public LocaleResolver localeResolver() {
    CookieLocaleResolver cookieLocaleResolver = new CookieLocaleResolver();
    cookieLocaleResolver.setDefaultLocale(Locale.KOREAN);
    cookieLocaleResolver.setCookieName("THYMELEAF_LANG");
    return cookieLocaleResolver;
}
```

#### locale을 변경할 수 있는 Interceptor 설정
- 특정 파라미터를 통해 locale 설정을 변경 할 수 있도록 interceptor를 등록
- `LocaleChangeInterceptor`를 사용
- `xxxx.com/xxx?lang=ko`를 호출하면 한국어로 변경, `xxxx.com/xxx?lang=en` 를 호출하면 영어로 변경됨.

```java
@Bean
public LocaleChangeInterceptor localeChangeInterceptor() {
    LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
    interceptor.setParamName("lang");
    return interceptor;
}
```

- 위에서 생성한 Bean 을 등록하자!
    - `WebMvcConfigurer`를 구현하면 해당 method를 override할 수 있다. (아래 전체 소스를 참고하자)

```java
@Override
public void addInterceptors(InterceptorRegistry registry) {
    registry.addInterceptor(localeChangeInterceptor());
}
```

#### 다국어 번들 설정
- resources 하위에 messages 라는 폴더를 만들고 아래와 같이 message 들을 넣어놓을 곳을 설정하자!
- `ReloadableResourceBundleMessageSource` 를 사용할 경우 `messageSource.setCacheSeconds(10);` 와 같이 캐시를 등록하고, 파일이 변경되면 알아서 적용되도록 사용할 수 있다.

```java
@Bean
public MessageSource messageSource(
    @Value("${spring.messages.basename}") String basename,
    @Value("${spring.messages.encoding}") String encoding
) {
    ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
    messageSource.setBasename(basename);
    messageSource.setDefaultEncoding(encoding);

    return messageSource;
}
```

- application.yml

```yaml
spring:
    messages:
        basename: messages/message
        encoding: UTF-8

```

###### message.properties
```properties
hello=안녕하세요!!
```

###### message_en.properties
```properties
hello=Hello!!
```

#### LocaleConfiguration 전체소스

```java
@Configuration
public class LocaleConfiguration implements WebMvcConfigurer {

    @Bean
    public LocaleResolver localeResolver() {
        CookieLocaleResolver cookieLocaleResolver = new CookieLocaleResolver();
        cookieLocaleResolver.setDefaultLocale(Locale.KOREAN);
        cookieLocaleResolver.setCookieName("THYMELEAF_LANG");
        return cookieLocaleResolver;
    }

    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
        interceptor.setParamName("lang");
        return interceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor());
    }

    @Bean
    public MessageSource messageSource(
        @Value("${spring.messages.basename}") String basename,
        @Value("${spring.messages.encoding}") String encoding
    ) {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename(basename);
        messageSource.setDefaultEncoding(encoding);

        return messageSource;
    }
}
```

## 사용해보기 - 1. Html 

#### attribute 로 사용해보기
```html
<h1 th:text="#{hello}"></h1>
<hr>
<h1 style="color: red;" th:text="${#messages.msg('hello')}"></h1>
<h1 style="color: red;" th:text="${#messages.msgOrNull('hello')}"></h1>
<hr>
<h1 style="color: red;" th:text="${#messages.msg('hello2')}"></h1> <!-- 없을 경우 : ??hello2_ko?? 와 같이 나옴 -->
<h1 style="color: red;" th:text="${#messages.msgOrNull('hello2')}"></h1> <!-- 없을 경우 : 아무것도 안찍힘 -->
```

#### 결과
- Default or localhost:8080?lang=ko

![image](https://user-images.githubusercontent.com/13219787/64265523-06444380-cf6e-11e9-8caa-b7358f9479e4.png)

- localhost:8080?lang=en

![image](https://user-images.githubusercontent.com/13219787/64265526-08a69d80-cf6e-11e9-84e3-50a8eb844ffb.png)

#### Tip!!
- javascript 내에 inline으로 해당 다국어를 사용할 경우! 한글이 이상하게 나온다...

```html
<script th:inline="javascript">
    const hello = [[#{hello}]];
    console.log(hello);
</script>
```

- 소스보기로 본 내용(결과는 잘 나온다!);
```
const hello = "\uC548\uB155\uD558\uC138\uC694!!";
console.log(hello);

안녕하세요!!
```

- 소스보기에서도 잘 나오게 하려면

```html
[[#{hello}]] -> "[(#{hello})]"
```

- 변경 소스

```html
const hello2 = "[(#{hello})]";
console.log(hello2);
```

## 사용해보기 - 2. java
#### MessageSource 와 LocaleResolver 를 사용!
```java
@Autowired
private MessageSource messageSource;

@Autowired
private LocaleResolver localeResolver;

log.info("LocaleResolver : {}", messageSource.getMessage("hello", new Object[]{}, localeResolver.resolveLocale(request)));
```
- 근데 `HttpServletRequest request` 를 사용해야하는 귀찮음이 있다. 조금 더 편한 방법을 찾아보자!

#### MessageSourceAccessor
###### LocaleConfigurtaion 에 추가

```java
@Bean
public MessageSourceAccessor messageSourceAccessor(
    @Qualifier("messageSource") MessageSource messageSource
) {
    return new MessageSourceAccessor(messageSource);
}
```

###### 사용
```java
@Autowired
private MessageSourceAccessor messageSourceAccessor;

log.info("messageSourceAccessor : {}", messageSourceAccessor.getMessage("hello"));
log.info("messageSourceAccessor with LocaleResolver : {}", messageSourceAccessor.getMessage("hello", localeResolver.resolveLocale(request)));
```

#### 결과

```
LocaleResolver : Hello!!
messageSourceAccessor : Hello!!
messageSourceAccessor with LocaleResolver : Hello!!
```

---
## 참고
- https://github.com/akageun/spring-boot-sample/tree/master/thymeleaf-web
- 
