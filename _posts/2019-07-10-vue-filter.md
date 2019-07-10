---
layout: post
title:  "Vue에서 filter를 사용해보자."
date:   2019-07-10 09:00:00 +0900
categories:
 - front
tags: 
 - vue
---

# Vue 필터 사용해보기
## 사용하기
```vue
<!-- 중괄호 보간법 -->
{{ message | capitalize }}

<!-- v-bind 표현 -->
<div v-bind:id="rawId | formatId"></div>
```

## 로컬 선언
```javascript
new Vue({
    el: '#app',
    data: {},
    filters: {
        capitalize (value) {
            if (!value) return ''
            value = value.toString()
            return value.charAt(0).toUpperCase() + value.slice(1)
        }
    }
}
```

## 전역 선언
```vue
Vue.filter('capitalize', (value) => {
  if (!value) return ''
  value = value.toString()
  return value.charAt(0).toUpperCase() + value.slice(1)
})
```

#### 전역선언시 여러 필터를 편하게 사용하는 법
- filters.js

```javascript
import Vue from "vue"

Vue.filter("capitalize", (value) => {
  if (!value) return ''
  value = value.toString()
  return value.charAt(0).toUpperCase() + value.slice(1)
});
```

- main.js

```javascript
import Vue from 'vue'
import App from './App'
import "./filters"

new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
})
```

## 필터에 파라미터 넣기
```vue
{{ message | filterA('arg1', arg2) }}
```

## 필터 체이닝
```vue
{{ message | filterA | filterB }}
```

---
## 참고자료
- https://kr.vuejs.org/v2/guide/filters.html 
- https://stackoverflow.com/questions/47004702/how-to-add-a-bunch-of-global-filters-in-vue-js