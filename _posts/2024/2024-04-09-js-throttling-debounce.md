---
layout: post
title:  "Throttling, Debounce 에 대해서"
date:   2024-04-09 09:00:00 +0900
categories:
- javascript
tags:
- throttling
- debounce
- event

---

- DOM 이벤트나 함수의 실행 빈도를 줄여 성능 향상을 가져오기 위한 개념
- 해당 개념에 대한 대표적인 사용사례
  - Throttling 을 통한 데이터 노출
    - 스크롤을 움직일 때 수 많은 스크롤 이벤트가 발생하고, 많은 API 호출로 이어진다.
  - 검색어 입력시 자동완성
    - 한글자씩 입력 될 때마다, api 를 호출하면 의도와 무관한 요청이 자주 발생, 입력이 끝난 후 또는 중간중간 api 를 호출

## 디바운스(Debounce)
- 연속적으로 발생한 이벤트를 하나로 처리하는 방식
- 처음이나 마지막에 발생한 이벤트나 함수만을 실행함.

### 예시코드
- `clearTimeout() 을 통해 기존 `debounce` 를 취소합니다.
- `setTimeout()`으로 설정한 주기가 지나면 로직이 수행될 수 있도록 한다.
- 주기에 도달하기 전에 이벤트가 발생할 경우 이전 `debounce` 에 대한 처리를 취소하고 다시 `setTimeout()`을 하기 때문에 설정한 주기를 기다린다.

```html
<input type='text' id='inputName'/>
```

```javascript
let debounce= null; // 전역으로 선언

function scrollTest(e) {

if (debounce) {
  clearTimeout(debounce);
}

const value = e.target.value;

debounce = setTimeout(() => {
  //실제 필요한 function 실행, e.g. api 호출 등...
  console.log('debounce', value, new Date());
}, 1000); //1초 마다
} 

const nameElem = document.getElementById('inputName')

nameElem.addEventListener("input", alertWhenTypingStops)
```

## 쓰로틀링 (Throttling)
- 연속적으로 이벤트가 발생하더라도 주기에 도달할 경우만 실행

### 예시코드
- 기존 이벤트 실행값이 있으면 종료됨.
- 기존 이벤트 실행값이 없으면, `setTimeout()` 을 실행하여 특정 주기별로 실행


```html
<input type='text' id='inputName'/>
```

```javascript
let throttle = null; // 전역으로 선언 필요
 
function autoCompleteTest(e) {
if (throttle) {
  return;
}

throttle = true;

setTimeout(() => {
    const value = e.target.value;

    console.log('throttle', value, new Date());
    //실제 필요한 function 실팽
    throttle = false; //or null
  }, 500);

}

const nameElem = document.getElementById('inputName')

nameElem.addEventListener("input", alertWhenTypingStops)
```

## 두 개념의 차이점
- 시점차이
  - `debounce` 는 입력이 끝날 때까지 대기하고, `throttling`은 입력이 시작되면 일정 주기로 계속 실행됨.
  - `debounce`는 시간을 짧게 가져가고, `throttling` 은 비슷한 효과가 있지만 시점 차이가 있음.

## 라이브러리
### `throttle-debounce`
- https://github.com/niksy/throttle-debounce

### `lodash`
- https://github.com/lodash/lodash

### `RxJS`
- https://github.com/ReactiveX/rxjs
