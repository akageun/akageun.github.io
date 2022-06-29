---
layout: post
title:  "[Basic] 약수"
date:   2018-06-03 09:00:00 +0900
categories:
 - python
tags: 
 - basic
---

# 1. 약수
-  어떤 수를 나누어 떨어지게 하는 수.

# 2. Python 소스
```python
if __name__ == "__main__":
    number = int(input("숫자를 입력해주세요. : "))

    divisors = []

    for i in range(1, number + 1):
        if number % i == 0:
            divisors.append(i)

    print(divisors)
```