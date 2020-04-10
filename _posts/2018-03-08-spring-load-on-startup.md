---
layout: post
title:  "[SPRING BOOT TIP] 1. spring boot starter web을 사용시 첫 호출이 느린 경우"
date:   2018-03-08 09:00:00 +0900
categories:
 - spring
tags: 
 - spring_boot
---
# 1. Goal
- Spring Boot에 `spring-boot-starter-web`를 사용 중이다.
- was가 initialization을 마친 뒤 첫 호출 시점에 dispatcherServlet이 initialization을 한다.
- was가 initialization을 할 동안 같이 dispatcherServlet이 initialization을 했으면 좋겠다.

# 2. Log
```
2018-02-14 13:43:58 [user-PC] [INFO ] o.a.c.c.C.[Tomcat].[localhost].[/]:179 - Initializing Spring FrameworkServlet 'dispatcherServlet'
2018-02-14 13:43:58 [user-PC] [INFO ] o.s.web.servlet.DispatcherServlet:489 - FrameworkServlet 'dispatcherServlet': initialization started
2018-02-14 13:43:58 [user-PC] [INFO ] o.s.web.servlet.DispatcherServlet:508 - FrameworkServlet 'dispatcherServlet': initialization completed in 17 ms
```

# 3-1. 수정
## JDK 1.8 이하
```java
@Bean
public static BeanFactoryPostProcessor beanFactoryPostProcessor() {
   return new BeanFactoryPostProcessor() {

      @Override
      public void postProcessBeanFactory(
         ConfigurableListableBeanFactory beanFactory) throws BeansException {
         BeanDefinition bean = beanFactory.getBeanDefinition(
            DispatcherServletAutoConfiguration.DEFAULT_DISPATCHER_SERVLET_REGISTRATION_BEAN_NAME);

         bean.getPropertyValues().add("loadOnStartup", 1);
      }
   };
}
```

## JDK 1.8 이상
```java
@Bean
public static BeanFactoryPostProcessor beanFactoryPostProcessor() {
   return beanFactory -> {
      BeanDefinition bean =
         beanFactory.getBeanDefinition(DispatcherServletAutoConfiguration.DEFAULT_DISPATCHER_SERVLET_REGISTRATION_BEAN_NAME);
      bean.getPropertyValues().add("loadOnStartup", 1);
   };
}
```

# 3-2. 수정(추천!)
- application.yml에 해당 내용 추가(기본으로 -1로 되어 있다.)
```yml
spring:
  mvc:
    servlet:
      load-on-startup: 1
```
- application.properties일 경우
> spring.mvc.servlet.load-on-startup=1

---
## 참고자료
- https://stackoverflow.com/questions/31322670/how-to-configure-dispatcherservlet-load-on-startup-by-spring-boot
