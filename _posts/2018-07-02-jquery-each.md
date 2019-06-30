---
layout: post
title:  "[Jquery] .each에서 break, continue 구현하기."
date:   2018-07-02 00:00:00 +0900
categories:
 - javascript
tags: 
 - jquery
---

![image](https://user-images.githubusercontent.com/13219787/60397128-845a2780-9b84-11e9-9a20-4189f4726164.png)

# 1. Jquery Each 
- API 문서 바로가기
- 쉽게 말해 반복문이다.

# 2. Break, Continue란?
- break 는 반복문을 중지하는 기능
- continue 는 해당하는 반복구간을 건너뛰는 기능

# 3. Jquery each에서는??
## 1) 요약
- break는 return false;
- continue는  return true;

## 2) 샘플
- 소스

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
</head>
<body>

<ul>
    <li>1</li>
    <li>2</li>
    <li>3</li>
    <li>4</li>
    <li>5</li>
    <li>6</li>
</ul>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
<script>
    $("ul li").each(function(index) {

        var tmpTxt = $(this).text();

        if (tmpTxt == "1") {
            console.log("Continue value "+ tmpTxt);
            return true;

        } else if (tmpTxt == "5") {
            console.log("Break value "+ tmpTxt);
            return false;
        }

        console.log("value "+ tmpTxt);

    });


</script>
</body>
</html>
```

- 결과( <li>6</li>에 해당하는 value값은 출력되지 않는다.)

![image](https://user-images.githubusercontent.com/13219787/60397133-8ae89f00-9b84-11e9-8cc1-f3c368ae82cd.png)