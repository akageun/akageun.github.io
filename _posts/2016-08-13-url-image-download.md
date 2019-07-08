---
layout: post
title:  "URL IMAGE DOWNLOAD"
date:   2016-08-13 09:00:00 +0900
categories:
 - java
tags: 
 - java
---

# 1. ImageIO 를 활용해서 이미지 다운로드
- 간단하게 URL을 호출해서 이미지를 로컬에 다운받을 수 있다.

```java
String imgUrl = "http://img.naver.net/static/www/u/2013/0731/nmms_224940510.gif"; //Image URL
String savePath = "/Users/kimhyeonggeun/dev_folder/image/"; //저장 경로

try {
    URL url = new URL(imgUrl);
    String fileName = imgUrl.substring(imgUrl.lastIndexOf('/') + 1, imgUrl.length()); // 이미지 파일명 추출
    String ext = imgUrl.substring(imgUrl.lastIndexOf('.') + 1, imgUrl.length()); // 이미지 확장자 추출
    BufferedImage img = ImageIO.read(url);

    System.out.println("fileName : " + fileName);
    System.out.println("ext : " + ext);
    ImageIO.write(img, ext, new File(savePath + fileName));

} catch (Exception e) {
    System.out.println(e.getMessage() + "/" + e);
}
```