---
layout: post
title:  "Javascript replaceAll 사용하기"
date:   2018-03-08 00:00:00 +0900
#categories: ["nginx", "deployment"]
---

- 자바스크립트에서는 replaceAll이 없다. 그래서 다른 방법으로 사용해야한다.
# 1. 기존 replace

```javascript
var str = "TEST : Sample TEST text";
var replaceStr = str.replace("TEST","Test"); // TEST라는 텍스트를 Test으로 변경
console.log("replaceStr : ", replaceStr);
```

- 결과값
    - 첫번째 조건만 변경하고 멈춘다.
> replaceStr :  Test : Sample TEST text

# 2. replaceAll 사용하기
#### string prototype 메소드 추가해서 사용하기
- searchStr을 구분자로 분리(split)한 다음, replacement라는 연결자로 연결(join)하는 형태

```javascript
/**
 * String prototype replaceAll 추가
 *  - searchStr을 구분자로 분리(split)한 다음, replacement라는 연결자로 연결(join)하는 형태
 *
 * @param searchStr : 바꾸려는 String
 * @param replacement : 바꾸어질 String
 */
String.prototype.replaceAll = function(searchStr, replacement) {
    return this.split(searchStr).join(replacement);
}

var protoTypeTestStr = "TEST : Sample TEST text";
var protoTypeTestRtnStr = protoTypeTestStr.replaceAll("TEST", "Test");
console.log("protoTypeTestRtnStr : ", protoTypeTestRtnStr);
```
- 결과값
> protoTypeTestRtnStr :  Test : Sample Test text


#### 정규식을 활용
- 변경하려는 값과 같은 것만(g 값을 사용)

```javascript
var regexTestStr = "TEST : Sample TEST text";
var regexTestRtnStr = regexTestStr.replace(new RegExp("TEST", "g"), "Test");
console.log("regexTestRtnStr : ", regexTestRtnStr);
```

- 대소문자 구분 없이 처리(gi 값 사용)

```javascript
var regexTestTipStr = "test : Sample test text";
var regexTestTipRtnStr = regexTestTipStr.replace(new RegExp("TEST", "gi"), "Test");
console.log("regexTestTipRtnStr : ", regexTestTipRtnStr);
```

# 3. 실제 사용하는 방법
#### String prototype으로 추가

```javascript
/**
 * String prototype replaceAll 추가
 *  - 정규식으로 replaceAll 구현
 *  - ignoreCase가 true이면 대소문자 구분없이 변경한다.
 *
 * @param searchStr : 바꾸려는 String
 * @param replacement : 바꾸어질 String
 * @param ignoreCase(boolean) : 대소문자 구분여부
 */
String.prototype.rexReplaceAll = function(searchStr, replacement, ignoreCase) {
    return this.replace(new RegExp(searchStr, ignoreCase ? "gi" : "g"), replacement);
}
```

#### 실행
- 소스

```javascript
var regexProtoTestStr = "test : Sample test text";
var regexProtoTestRtnStr = regexProtoTestStr.rexReplaceAll("TEST", "Test", true);
console.log("regexProtoTestRtnStr : ", regexProtoTestRtnStr);
```

- 결과
> regexProtoTestRtnStr :  Test : Sample Test text

# 4. 전체소스
```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>JAVASCRIPT replaceAll 구현하기</title>
</head>
<body>
    <script>
        /* 자바스크립트 기본 replace 테스트 */
        var oriReplaceTestStr = "TEST : Sample TEST text";
        var oriReplaceRtnStr = oriReplaceTestStr.replace("TEST","Test"); // TEST라는 텍스트를 Test으로 변경
        console.log("oriReplaceRtnStr : ", oriReplaceRtnStr);

        /**
         * String prototype replaceAll 추가
         *  - searchStr을 구분자로 분리(split)한 다음, replacement라는 연결자로 연결(join)하는 형태
         *
         * @param searchStr : 바꾸려는 String
         * @param replacement : 바꾸어질 String
         */
        String.prototype.replaceAll = function(searchStr, replacement) {
            return this.split(searchStr).join(replacement);
        }

        var protoTypeTestStr = "TEST : Sample TEST text";
        var protoTypeTestRtnStr = protoTypeTestStr.replaceAll("TEST", "Test");
        console.log("protoTypeTestRtnStr : ", protoTypeTestRtnStr);

        var regexTestStr = "TEST : Sample TEST text";
        var regexTestRtnStr = regexTestStr.replace(new RegExp("TEST", "g"), "Test");
        console.log("regexTestRtnStr : ", regexTestRtnStr);

        /** TIP : 대소문자 구분없이 처리 **/
        var regexTestTipStr = "test : Sample test text";
        var regexTestTipRtnStr = regexTestTipStr.replace(new RegExp("TEST", "gi"), "Test");
        console.log("regexTestTipRtnStr : ", regexTestTipRtnStr);

        /**
         * String prototype replaceAll 추가
         *  - 정규식으로 replaceAll 구현
         *  - ignoreCase가 true이면 대소문자 구분없이 변경한다.
         *
         * @param searchStr : 바꾸려는 String
         * @param replacement : 바꾸어질 String
         * @param ignoreCase(boolean) : 대소문자 구분여부
         */
        String.prototype.rexReplaceAll = function(searchStr, replacement, ignoreCase) {
            return this.replace(new RegExp(searchStr, ignoreCase ? "gi" : "g"), replacement);
        }

        var regexProtoTestStr = "test : Sample test text";
        var regexProtoTestRtnStr = regexProtoTestStr.rexReplaceAll("TEST", "Test", true);
        console.log("regexProtoTestRtnStr : ", regexProtoTestRtnStr);
    </script>
</body>
</html>
```

# 5. TIP
- 정규식 추가
    - m을 추가하면 여러줄에 대해서도 처리가 가능하다.