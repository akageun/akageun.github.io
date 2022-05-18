---
layout: post title:  "[Chrome Extension 개발기] 3. 사용했던 API 들 "
date:   2022-05-19 09:00:00 +0900
categories:
- project-series 
tags:
- chrome
- chrome-extension

---
- 최대한 빠르게 `URL` 을 찾기 위해 방법을 찾아봤다.

## omnibox

- 입력한 `keyword` 를 주소창에 넣고 `tab` 으로 누르면 활성화 됨.
- https://developer.chrome.com/docs/extensions/reference/omnibox/

#### manifest.json

```json
{
  "omnibox": {
    "keyword": "as"
  }
}
```

#### background.js
- 아래 기능들 외의 내용은 공홈 자료를 참고하시길!

```javascript
//첫 번째 항목으로 표시되는 단일 문자열 속성
chrome.omnibox.setDefaultSuggestion({
    description: ''
});

//검색어에 따른 리스너
chrome.omnibox.onInputChanged.addListener((text, suggest) => {
    //check that the length of the text is 6 characters
    if (text.length !== 6) {
        suggest([]);
        return;
    }

    suggest([
        {
            content: `${url}`,
            deletable: true,
            description: `설명... `
        }
    ]);
});

//해당 값을 선택했을 때
chrome.omnibox.onInputEntered.addListener((text, OnInputEnteredDisposition) => {
    if (OnInputEnteredDisposition === 'currentTab') {
        chrome.tabs.create({text});
    } else {
        chrome.tabs.update({text});
    }
});
```

## storage
- https://developer.chrome.com/docs/extensions/reference/storage/
- localStorage API 와 비슷하게 사용
- 데이터는 객체로 저장할 수 있다
- 비동기처리, async await 나 promise 를 사용하여 동기처럼도 사용 가능!
- manifest.json

```json
{
  "permissions": [
    "storage"
  ]
}
```

#### local
- 최대 5MB 까지 사용 가능
  - unlimitedStorage 를 사용하면 용량제한 없이 사용 가능.
- 

```javascript
chrome.storage.local.set({
    test: 'test value'
});

chrome.storage.local.get((data) => {
    console.log(data.test);
});
```

#### sync
- storage.sync 는 Chrome과 자동으로 동기화하여 사용.
- local 과 다르게 제한이 있다.
  - https://developer.chrome.com/docs/extensions/reference/storage/#property-sync

```javascript
// 크롬 스토리지에 저장된 값 가져오기
chrome.storage.sync.get((data) => {
    console.log(data.test);
});

// 크롬 스토리지에 입력 값 저장
chrome.storage.sync.set({
    test: 'test value'
});
```

## 다운로드 기능
- 입력했던 데이터를 `export` 하기 위해 사용
- https://developer.chrome.com/docs/extensions/reference/downloads/

```json
{
  "permissions": [
    "downloads"
  ]
}
```
