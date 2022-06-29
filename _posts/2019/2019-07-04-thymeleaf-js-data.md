---
layout: post
title:  "thymeleaf에서 javascript로 데이터 전달 방법"
date:   2019-07-04 00:00:00 +0900
categories:
 - spring
tags: 
 - thymeleaf
---
- spring controller에서 전달한 데이터를 javascript 변수로 담아 사용하고 싶다.

# javascript로 데이터 전달 방법

#### controller 소스
- `testValue` 를 javascript 변수로 담아보자.

```java
@GetMapping("/")
public ModelAndView home(){
	ModelAndView mv = new ModelAndView("home");

	mv.addObject("testValue", "안녕하세요.");

	return mv;
}
```

#### javascript 소스
```html
<html xmlns:th="http://www.thymeleaf.org">
<body>

<script  th:inline="javascript">
	/*<![CDATA[*/
	var testValue = "[[${serviceCode}]]";
        alert(testValue);
	/*]]>*/
</script>
</body>
</html>
```

# Foreach 사용하는 법

```html
<script th:inline="javascript">
	/*<![CDATA[*/

	/*[# th:each="tmp : ${list}"]*/
	noti(/*[[${tmp.testValue}]]*/, /*[[${tmp.tmpValue}]]*/);
	/*[/]*/

	/*]]>*/
	
	function noti(testValue, tmpValue){
		console.log(testValue, tmpValue);
	}
</script>
```
