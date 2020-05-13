---
layout: post
title:  "Service Instance Monitoring 하는 법"
date:   2019-08-08 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - spring_boot
 - msa
---
- 최근 msa 형태로 개발이 많이 진행되고, 각 서버에 들어가서 인스턴스 정보들을 확인하는 등 모니터링을 하는데, 번거로움이 크다.
- 이미 `spring-boot-starter-actuator` 라는 좋은 모니터링 정보들을 제공해주는데, 모아 보는 툴을 고민하던 중에
- 굉장히 좋은 툴 하나를 발견했다.(사실은 예전부터 사용했으나, 블로깅을 안해놓음)

# 여러 Spring Boot service instance 들에 대한 monitoring 방법
- 아래 설정들로 간단하게 눈으로 확인해볼 수 있다.

## spring-boot-admin-server 구축하기

#### pom.xml
```xml
<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>spring-boot-admin-starter-server</artifactId>
    <version>2.1.6</version>
</dependency>

<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>spring-boot-admin-server-ui</artifactId>
    <version>2.1.6</version>
</dependency>
```

#### application 설정(yml or properties)
- 본인이 사용할 Admin port를 설정해주세요.

```yml
server:
    port: 9905
```

#### bootstrap class 
- `Application` class 상단에 `@EnableAdminServer` 를 추가해 줍니다.

```java
@EnableAdminServer
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

#### 실행
- mvn spring-boot:run

###### 화면
- client를 띄워놓지 않아서 아직 뭐 없어보인다.

![image](https://user-images.githubusercontent.com/13219787/62628527-7018ff80-b966-11e9-9d4d-df2ac419f5ef.png)

## spring-boot-admin-client 구축하기
#### pom.xml
```xml
<!-- spring-boot-admin을 사용하기 위한 라이브러리 -->
<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>spring-boot-admin-starter-client</artifactId>
    <version>2.1.6</version>
</dependency>

<!-- 모니터링을 위한 라이브러리 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

#### application 설정(yml or properties)
```yml
spring:
    boot:
        admin:
            client:
                url: http://localhost:9905
                instance:
                    name: boot-admin-B-client

management:
    endpoints:
        web:
            exposure:
                include: '*'
```

#### 실행 후 admin 화면
- 아래와 같이 instance 들이 추가 되어 있다.

![image](https://user-images.githubusercontent.com/13219787/62630004-27af1100-b969-11e9-84cf-2e5fbd898b54.png)

- instance 를 클릭해서 들어오면 아래와 같이 여러 정보를 확인 할 수 있다.

![image](https://user-images.githubusercontent.com/13219787/62629998-22ea5d00-b969-11e9-9ef2-1d9d3e97fdb7.png)

## 로그파일 보기
- application.yml or properties에 아래와 같이 각 client 설정값에 log path 를 추가해주면, admin server 에서 손쉽게 볼 수 있다.

```yml
logging:
    file: ./logs/data-a.log
```

![image](https://user-images.githubusercontent.com/13219787/62636852-47e4cd00-b975-11e9-938c-1c11c3631d09.png)

---
# Security 적용하기
- HeapDump 등 중요한 정보들을 볼 수 있기 때문에 보안은 필수다.
- 간단하게 admin server 에 Login 을 붙일 수 있고, api 들도 base url 을 변경, auth 를 붙일 수 있다.

## Admin Server 
#### application 설정(yml or properties)
- 아래 내용을 추가한다.

```yml
spring:
    security:
        user:
            name: admin
            password: admin

```

#### pom.xml
- spring security 추가

```xml
<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>spring-boot-admin-server-ui-login</artifactId>
    <version>1.5.7</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

#### security Configuration
```java
@Configuration
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        SavedRequestAwareAuthenticationSuccessHandler successHandler
            = new SavedRequestAwareAuthenticationSuccessHandler();
        successHandler.setTargetUrlParameter("redirectTo");
        successHandler.setDefaultTargetUrl("/");

        http.authorizeRequests()
            .antMatchers("/assets/**").permitAll()
            .antMatchers("/login").permitAll()
            .anyRequest().authenticated()
            .and()
            .formLogin()
            .loginPage("/login")
            .successHandler(successHandler)
            .and()
            .logout().logoutUrl("/logout")
            .and()
            .httpBasic()
            .and()
            .csrf()
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            .ignoringAntMatchers(
                "/instances"
            );
    }
}
```

#### 실행 화면(로그인창)
- 심플하게 잘 만들어 놓은거 같다.
- 위에 설정한 것처럼 id : `admin`, password : `admin` 를 사용하면됨.

![image](https://user-images.githubusercontent.com/13219787/62635618-fa676080-b972-11e9-8ef9-81441e1b326b.png)

## Admin Client
#### application 설정(yml or properties)
```yml
server:
    port: 8809
spring:
    boot:
        admin:
            client:
                url: http://localhost:9905
                instance:
                    name: boot-admin-B-client
                    metadata:
                        user.name: ${spring.security.user.name}
                        user.password: ${spring.security.user.password}
                username: ${spring.security.user.name}
                password: ${spring.security.user.password}
    security:
        user:
            name: admin
            password: admin

management:
    endpoints:
        web:
            exposure:
                include: '*'
            base-path: /hello/admin
```

#### 추가 후 수집정보
- metadata 에 추가 되어 있다.

![image](https://user-images.githubusercontent.com/13219787/62635691-1bc84c80-b973-11e9-9dea-27450ef83122.png)

## 해당 소스들은 github 에 올라가 있습니다.
- https://github.com/akageun/hello-spring-boot-admin

---
## 참고자료
- https://github.com/codecentric/spring-boot-admin
- https://www.vojtechruzicka.com/spring-boot-admin/

