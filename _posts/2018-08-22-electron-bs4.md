---
layout: post
title:  "[Electron.js] Bootstrap 4 사용하기."
date:   2018-08-22 09:00:00 +0900
categories:
 - node
tags: 
 - electron
 - bootstrap
---

# 1. package.json 에 추가하기.

> npm install --save jquery 

>npm install --save bootstrap 

- 아래와 같은 메시지가 노출된다면.

![image](https://user-images.githubusercontent.com/13219787/60397153-cdaa7700-9b84-11e9-8850-93deeebaf692.png)

> npm install --save popper.js 

# 2. html에 import 하기

```html
<!DOCTYPE html>
<html>
<head>
   <meta charset="UTF-8">
   <title>Elctron Test</title>
   <link rel="stylesheet" href="node_modules/bootstrap/dist/css/bootstrap.css">
</head>
<body>
<a class="btn btn-info">TEST BTN</a>
<script>
    window.$ = window.jquery = require("jquery");
    window.popper = require("popper.js");
    require("bootstrap");

    require('./common.js');
</script>
</body>
</html>
```

# 3. 사용해보기.
- 결과

![image](https://user-images.githubusercontent.com/13219787/60397155-d3a05800-9b84-11e9-9ccb-06e7cac40828.png)

---
## 참고자료
- https://stackoverflow.com/questions/50317773/how-to-include-bootstrap-4-in-an-electron-app