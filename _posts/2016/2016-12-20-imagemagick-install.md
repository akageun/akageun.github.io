---
layout: post
title:  "ImageMagicK 설치"
date:   2016-12-20 09:00:00 +0900
categories:
 - linux
tags: 
 - imagemagic_k
---

# 0. ImageMagicK란?
- 이미지를 손 쉽게 자르고 붙이고 할 수 있게 도와주는 오픈소스.

# 1. Install 전 확인
> sudo rpm -qa | grep ImageMagick
> sudo yum list installed ImageMagick

# 2. Install 
> sudo yum list ImageMagick

# 3. 설치확인
> convert | head -2
