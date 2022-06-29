---
layout: post
title:  "[Vue.js] 1-1. 시작하기 : CDN 링크로 배워보자."
date:   2018-04-23 09:00:00 +0900
categories:
 - front
tags: 
 - vue
---

## 1. Vue란?
- front-end framework
- 배우기 쉽다.
- view에 최적화 되어 있다.
- MVVM(Model-View-ViewModel) 패턴을 기반으로 디자인

## 2. 간단하게 시작해보자.
- index.html 파일을 만들고, 아래 링크를 포함한 페이지를 만들어보자.

> https://unpkg.com/vue
or

> https://cdn.jsdelivr.net/npm/vue

#### 1) index.html
```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Vue.js Sample</title>
</head>
<body>

<div id="root">
    <p>{{ msg }}</p>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
<script>
    new Vue({
        el: '#root',
        data: {
            msg: 'Hello Vue.js!'
        }
    })
</script>
</body>
</html>
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/65156962-ed0dbd80-da6a-11e9-8879-7abda880da98.png)

## 3. Declarative Rendering
- 디렉티브는 vue에서 제공하는 속성, v- 로 접두어가 붙는다.

#### 1) v-if
- 조건문 사용할 때 사용.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Vue.js Sample</title>
</head>
<body>

<div id="root">
    <div v-if="type === 'LOGIN'">로그인 되었습니다.</div>
    <div v-else-if="type === 'LOGOUT'">로그아웃 되었습니다.</div>
    <div v-else> 로그인이 필요합니다.</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
<script>
    var app = new Vue({
        el: '#root',
        data: {
            type: "LOGOUT"
        }
    })
</script>
</body>
</html>
```

- template 에도 사용가능

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Vue.js Sample</title>
</head>
<body>

<div id="root">
    <template v-if="type === 'LOGIN'">
        <div>
            로그인 되었습니다.
        </div>
    </template>
    <template v-else-if="type === 'LOGOUT'">
        <div>
            로그아웃 되었습니다.
        </div>
    </template>
    <template v-else>
        <div>
            로그인이 필요합니다.
        </div>
    </template>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
<script>
    var app = new Vue({
        el: '#root',
        data: {
            type: "LOGIN"
        }
    })
</script>
</body>
</html>

```

#### 2) v-show
- 보여질지, 숨길지에 대해서 설정할 수 있는 값이다.
- 일단 뷰 렌더링이 진행되고, css로 숨길지 나타낼지를 정한다.
- 샘플코드

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Vue.js Sample</title>
</head>
<body>

<div id="root">
    <div v-show="visible">보이나?</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
<script>
    var app = new Vue({
        el: '#root',
        data: {
            visible: true
        }
    })
</script>
</body>
</html>
```

- v-if는 토글 비용이 높고 v-show는 초기 렌더링 비용이 더 높다. 자주 바꾸기를 원한다면 v-show를, 런타임 시 조건이 바뀌지 않으면 v-if를 권장한다..
- chrome 개발자 console 창에 'app.visible = false;'를 입력해보면 해당 div가 사라지는 걸 확인 할 수 있다.

#### 3) v-for
- for loop
- 목록 구현할때 많이 쓰이는 디렉티브
- 샘플 코드

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Vue.js Sample</title>
</head>
<body>

<div id="root">
    <ul>
        <li v-for="fruit in fruits" :key="fruit">{{ fruit }}</li>
    </ul>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
<script>
    new Vue({
        el: '#root',
        data: {
            fruits: ['apple', 'banana', 'orange']
        }
    })
</script>
</body>
</html>
```
- 결과

![image](https://user-images.githubusercontent.com/13219787/65156950-e54e1900-da6a-11e9-9293-48047ab89738.png)

#### 4) 기타
- v-on, v-bind, v-model 등이 있다.

---
## 참고
- https://vuejs.org/v2/guide/index.html
- https://kr.vuejs.org/v2/guide/index.html
