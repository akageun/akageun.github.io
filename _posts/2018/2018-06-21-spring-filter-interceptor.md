---
layout: post
title:  "[Spring] Filter & Interceptor"
date:   2018-06-21 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - basic
---

![image](https://user-images.githubusercontent.com/13219787/61305159-4b2ce300-a825-11e9-9c6c-40d74ab63f29.png)


# 1. Filter
```java
public interface Filter {
   void doFilter(ServletRequest request, ServletResponse response, FilterChain chain);
}
```

## 1) Filter란?
- J2EE 표준 스팩

##  2) init()
- 필터 인스턴스 초기화

##  3) doFilter()
- 전/후 처리

##  4) destroy()
- 필터 인스턴스 종료

# 2. Interceptor
- 소스

```java
public interface HandlerInterceptor {


   @Override
   public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
      throws Exception;

   @Override
   public void postHandle(
         HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView)
         throws Exception;

   @Override
   public void afterCompletion(
         HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
         throws Exception;

}
```

## 1) Interceptor란?
- Spring Framework에서 지원하는 스팩

## 2) preHandle()  
- Controller 전에 호출된다.
- return 값이 false일 경우 controller 및 다음 postHandle 역시 호출되지 않는다.
- 인증처리 등을 추가하면 좋다.
- 요청 로그를 남기기 좋다.

## 3) postHandle()
- Controller가 호출되고 난 뒤 호출된다.
- Request 값을 변경하는데 사용하면 좋다.
- View에 공통적으로 값을 추가할 때 사용하면 좋다.

## 4) afterCompletion()
- 뷰 렌더링까지 완료된 후에 호출된다.

# 3. Filter와 Interceptor 차이점
- Filter는 Dispatcher servlet 앞단에서 처리한다. Interceptor는 Controller 시작부터해서 메소드별로 라이프 사이클에 맞게 호출된다.
- Interceptor와 다르게 Filter는 web.xml에 설정을 추가한다.


