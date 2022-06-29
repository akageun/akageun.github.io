---
layout: post
title:  "Linux bash Shell directory exists check"
date:   2018-04-02 09:00:00 +0900
categories:
 - linux
tags: 
 - shellscript
---
- 간단하게 체크할 수 있음.

```shell
#!/bin/sh

BASIC_PATH=/home/test/dic

if [ ! -d "$BASIC_PATH" ]; then
        echo "THIS BASIC PATH NOT EXIST"
        mkdir -p $BASIC_PATH
fi
```