---
layout: post
title:  "Timer 구현하기"
date:   2017-01-25 09:00:00 +0900
categories:
 - javascript
tags: 
 - javascript
---

# 1. 기능
- HTML에서 특정 시간 카운트 다운
- HTML에 카운트 되는 시간 출력

# 2. Code
## 1) HTML Source
```html
<div id="timerTxt"></div> <!-- 타이머를 노출할 Div -->
```

## 2) Javascript Source
```javascript
var timerId;
var timerSec = 3;

window.onload= function() {
	timerId = setInterval('timer()', 1000);
}

function timer() {
	var min = Math.floor(timerSec / 60)
	var sec = timerSec % 60;

	var msg = (min < 10 ? "0"+ min : min) + ":" + (sec < 10 ? "0"+ sec : sec);
	timerSec--;

	if (timerSec < 0) { /* time End*/
		msg += "<br>Timer End!"
		clearInterval(timerId);
	}

	document.getElementById("timerTxt").innerHTML = msg;
}
```

## 3) Full Source

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>타이머 샘플 소스</title>
</head>
<body>
	<div id="timerTxt"></div>

	<script type="text/javascript">
		var timerId;
		var timerSec = 3;

		window.onload= function() {
			timerId = setInterval('timer()', 1000);
		}

		function timer() {
			var min = Math.floor(timerSec / 60)
			var sec = timerSec % 60;

			var msg = (min < 10 ? "0"+ min : min) + ":" + (sec < 10 ? "0"+ sec : sec);
			timerSec--;

			if (timerSec < 0) { /* time End*/
				msg += "<br>Timer End!"
				clearInterval(timerId);
			}

			document.getElementById("timerTxt").innerHTML = msg;
		}
	</script>
</body>
</html>
```

