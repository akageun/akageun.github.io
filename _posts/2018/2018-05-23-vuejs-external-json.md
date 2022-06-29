---
layout: post
title:  "[Vue.js] How to use external Json File"
date:   2018-05-23 09:00:00 +0900
categories:
 - front
tags: 
 - javascript
---

# 1. Json 파일 import 하기.
```javascript
  import externalJsonFile from './externalJsonFile.json'
  export default{
    data(){
      return{
        jsonFile: externalJsonFile
      }
    }
  }
```

# 2. 가져다 쓰기
```html
<ul v-for="tmp in jsonFile">
  <li>{{tmp}}</li>
</ul>
```

