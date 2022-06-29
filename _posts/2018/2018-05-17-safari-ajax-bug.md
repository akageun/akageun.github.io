---
layout: post
title:  "Safari 11.1 업데이트 이후 ajax 버그"
date:   2018-05-17 09:00:00 +0900
categories:
 - javascript
tags: 
 - safari
 - bugs
---
# 1. safari 11.1 update
- 기존 Safari (mac or ios)에서는 정상적으로 동작하던 ajax가 safari 11.1 버전 업데이트를 진행한 후로 오류가 발생함.
- ajax 내 error 메시지가 다음과 같다

> Failed to load resource: The operation couldn’t be completed. Protocol error

- Chrome이나 Firefox 등 최신버전에서는 문제가 없었다.

# 2. 원인 
- Webkit 버그!!!! (Webkit 빌드 r230963)
- input[type=file] 또는 formData 내에 file 

```html
<input type="file"/>
```

- ajax 내 data에 빈 파일 필드가 전송되면 발생함.
- (전 IOS 11.3에서 발생하여 수정 했습니다.)

# 3. 해결책
- https://trac.webkit.org/changeset/230963/webkit : 수정됨.
- 임시 해결책

```javascript
frmData.delete("file"); //var frmData = new FormData() 를 사용할 경우
```

or

```javascript
$("input[type=file]").each(function () {
    var tmpValue = $(this).val();
    if (tmpValue === undefined || tmpValue === "") {
        $(this).remove();
    }
});
```

