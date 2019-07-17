---
layout: post
title:  "[Eclipse] 프로젝트 내 한글 텍스트 검색하기"
date:   2016-10-18 09:00:00 +0900
categories:
 - tools
tags: 
 - eclipse
---

- 프로젝트 클릭 후 Ctrl + H 를 누릅니다. File Search탭을 클릭한 다음 아래 내용을 Containing Text 에 입력합니다.

> \"[^"\u0080-\uffff;\\n]*[\u0080-\uffff][^";\\n]*\"

- 그리고 우측 Regular expression을 클릭한 뒤 검색합니다.

![image](https://user-images.githubusercontent.com/13219787/61382404-b212d080-a8e7-11e9-9261-7186242b8425.png)




