---
layout: post
title:  "[Chrome Extension 개발기] 2. extension 기본"
date:   2022-05-19 09:00:00 +0900
categories:
- project-series
tags:
- chrome
- chrome-extension
---
# Chrome Extension
- https://developer.chrome.com/docs/extensions/mv3/manifest/


## Extension 구조
![image](https://user-images.githubusercontent.com/13219787/168610790-10114ad8-0e36-47a0-a7bb-a25d21f0beeb.png)

- 추가로 option.html 도 있다.

## `manifest.json` 만들기
- app 의 이름이나 설명, 아이콘들을 선언해 놓는 곳
- https://developer.chrome.com/docs/extensions/mv3/manifest/#overview

```json
{
  "name": "Test Extension",
  "description": "My First Chrome Extension",
  "version": "0.1.0",
  "manifest_version": 3
}
```

## 개발 및 테스트...
- `chrome://extensions/` 에 접근해서 unpack 된 파일을 올려서 테스트 가능하다.
  <img width="522" alt="image" src="https://user-images.githubusercontent.com/13219787/168611207-e58db7aa-422a-4395-b4d2-466799fc604b.png">


## background
- Browser 의 이벤트에 반응하여 동작.
- service worker
- 아래는 app 이 설치되었을 때 호출되는 listener 다.
- `default` 로 사용할 config나 이런 것들을 동작시킬 수 있는 곳.

#### manifest.json
```json
"background": {
  "service_worker": "background.js"
},
```

#### background.js
```javascript
chrome.runtime.onInstalled.addListener(() => {
 alert("설치 되었습니다.")
});
```

## option or popup
- html, javascript 등을 사용하여 페이지를 작성할 수 있음.
- popup : 아이콘을 누르면 보이는 팝업창
- option : `옵션` or `설정`을 누르면 보이는 페이지

#### popup manifest.json
```json
{
  "action": {
    "default_popup": "popup.html"
  }
}
```

#### option manifest.json
```json
{
  "options_page": "options.html"
}
```

#### popup.html or option.html
- 일반적인 html 파일, javascript, Css 를 호출하여 사용 가능.

## icon
- 사이즈 별로 입력해서 assets 와 같은 폴더를 생성하여 추가하면 끝!