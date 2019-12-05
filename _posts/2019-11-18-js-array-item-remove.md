---
layout: post
title:  "[JS] Array 내 item 제거하기!"
date:   2019-11-18 09:00:00 +0900
categories:
 - javascript
tags: 
 - javascript
 - array
---
- javascript에서 array 내 item을 제거해야할 경우 splice()를 사용할 수 있다.
- 간단히 사용법을 알아보자

## Remove
- 아래 splice의 경우, `1번 index 부터, 3개를 제거` 한다.

```javascript
const myItems = ['java', 'javascript', 'python', 'go lang', 'swift'];
const removedItems = myItems.splice(1, 3);

console.log('myItems : ', myItems);
console.log('removedItems : ', removedItems);
```

#### 결과
> myItems : ["java", "swift"]
> removedItems : ["javascript", "python", "go lang"]

## (추가로) array 내에 item을 추가해보자
- 아래 splice 는 `2번째 index에 item을 삭제하지 않고, kotlin을 추가' 한다 입니다.

```javascript
const myItems = ['java', 'javascript', 'python', 'go lang', 'swift'];
myItems.splice(2, 0,  'kotlin');

console.log('myItems : ', myItems);
```

#### 결과
> myItems :  ["java", "javascript", "kotlin", "python", "go lang", "swift"]

---
## 참고링크
- https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Array/splice
