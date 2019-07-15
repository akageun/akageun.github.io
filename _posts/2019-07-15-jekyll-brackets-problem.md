---
layout: post
title:  "Jekyll 이중 중괄 문제 해결"
date:   2019-07-15 09:00:00 +0900
categories:
 - open source
tags: 
 - jekyll
---

## jekyll post에 vue 관련 내용을 포스팅 하던 중 문제 발생

- vue에서 {{ message }} 관련 문법을 사용.
- 표기가 제대로 되지 않는다.

- 간단하게 escape 할 수 있음

```
{% raw %}{% raw %}
  {{ ... }} {% endraw %} {% raw %}{%{% endraw %} endraw %}
```



