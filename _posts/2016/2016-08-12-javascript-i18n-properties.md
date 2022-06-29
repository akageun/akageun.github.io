---
layout: post
title:  "외부 javascript 파일에 다국어 적용하기(i18n.properties 사용)"
date:   2016-08-12 09:00:00 +0900
categories:
 - javascript
tags: 
 - i18n
---

# 1. 개요
- 글로벌 서비스를 진행하는 웹 페이지의 경우 다국어를 적용해야한다.
- 그러나 모든 처리를 서버 사이드에서 진행하기에는 굉장히 부담이 크다.
- 특히나 외부 javascript 파일의 경우 더욱 골치가 아프다.
- 그래서 간단히 사용할 수 있는 자바스크립트 모듈 "i18n"을 소개하려고 한다.
- Github URL : https://github.com/jquery-i18n-properties/jquery-i18n-properties

# 2. 간단한 설명
- 기본 jquery lib는 무조건 import해야함.
- jquery-i18n-properties에서 .js 파일을 다운로드함
- 소스에 추가

![image](https://user-images.githubusercontent.com/13219787/59450491-4bac1580-8e44-11e9-97de-6f52a2e38a99.png)

- 소스 사용은 아래 Example을 참고하시기를
- i18n 명칭이 약간 이상해서 검색해봄
- 국제화는 때로 줄여서 그저 "I18N"이라고도 표기하는데, 그 의미는 이 용어의 영어 표기에서 첫 글자인 "I"자와 마지막 글자인 "N"의 사이에 18글자가 들어가 있다는 의미이다.​
    - 출처 : http://www.terms.co.kr/internationalization.html

- 아래는 github README.md 내에 포함된 자료를 복사 붙여넣기 한거다. 

- Messages.properties: # This line is ignored by the plugin 
```properties
msghello = Hello msgworld = World 
msg_complex = Good morning {0}!
```

- Messages_pt.properties:

```properties
# We only provide a translation for the 'msg_hello' key
msg_hello = Bom dia
```

- MessagesptPT.properties:

```properties
#We only provide a translation for the 'msg_hello' key
msg_hello = Olá
```

- Now, suppose these files are located on the bundle/ folder. One can invoke the plugin like below:

```javascript
$.i18n.properties({
     name:'Messages', 
     path:'bundle/', 
     mode:'both',
     language:'pt_PT', 
     callback: function() {
         // We specified mode: 'both' so translated values will be
         // available as JS vars/functions and as a map
         // Accessing a simple value through the map
         jQuery.i18n.prop('msg_hello');

         // Accessing a value with placeholders through the map
         jQuery.i18n.prop('msg_complex', 'John');

         // Accessing a simple value through a JS variable
         alert(msg_hello +' '+ msg_world);

         // Accessing a value with placeholders through a JS function
         alert(msg_complex('John'));
     } 
});​​
```









