---
layout: post
title:  "Spring Interceptor에서 redirect 체크하는 방법"
date:   2017-03-19 09:00:00 +0900
categories:
 - spring
tags: 
 - java
 - spring
---

# 1. Spring Interceptor에서 redirect 체크
- 아래와 같은 경우 등

```java
return "redirect:/testPage";
```

# 2. 소스

```java

/**
 * Request Checker
 *  - Redirect
 * 
 * @param modelAndView
 * @return
 */
private boolean isRedirect(ModelAndView modelAndView) {
   return modelAndView.getView() instanceof RedirectView || modelAndView.getViewName().startsWith("redirect:");
}
```
