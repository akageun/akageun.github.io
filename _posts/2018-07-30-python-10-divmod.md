---
layout: post
title:  "10진수 n진수로 변환하기."
date:   2018-07-30 00:00:00 +0900
categories:
 - python
tags: 
 - python
---
# 1. 기본

| | 범위 | 예시 |
| :---: | -------------------: |:---------------:|
| 10진수          | 0 - 9        | 0,  1, 2, 3, 4 .... 8, 9, 10 ... |
| 16진수(Hex)     | 0 ~ 9, A ~ F | 0,  1, 2 .... 9, A, B ... F, 10, 11 .... 19, 1A, 1B |
| 8진수(Octal)    | 0 ~ 7        | 0, 1, 2 .... 6, 7, 10, 11 .... |
| 2진수(Binary)   | 0, 1         | 0, 1, 10, 11, 100, 101 |

# 2. Python 으로 구현해보기
## 1) 내장함수로 구현해보기

- 소스 코드
```python
if __name__ == "__main__":
    num_10 = 236

    num_2 = bin(num_10)  # 접두어 "0b"가 붙음
    num_8 = oct(num_10)
    num_16 = hex(num_10)

    print("10 -> 2 : ", num_2)
    print("10 -> 8 : ", num_8)
    print("10 -> 16 : ", num_16)
    print("=================")

    # int(x, base=10)
    print("2 -> 10 : ", int(num_2, 2))
    print("8 -> 10 : ", int(num_8, 8))
    print("16 -> 10 : ", int(num_16, 16))
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/60100597-03221f80-9795-11e9-8142-62755262caa0.png)

## 2) 함수 구현해보기.
- 재귀함수를 사용하여 함수 구현

```python
def convert(num, base):
    T = "0123456789ABCDEF"
    quotient, remainder = divmod(num, base)

    if quotient == 0:
        return T[remainder]
    else:
        return convert(quotient, base) + T[remainder]


if __name__ == "__main__":
    num_10 = 236

    print(convert(num_10, 2))
    print(convert(num_10, 8))
    print(convert(num_10, 16))

    print("=================")
    print(int(convert(num_10, 2), 2))
    print(int(convert(num_10, 8), 8))
    print(int(convert(num_10, 16), 16))
```

- 실행결과

![image](https://user-images.githubusercontent.com/13219787/60100603-07e6d380-9795-11e9-8a8f-6a89e6f4ae4f.png)

# 3. 전체 소스
```python
def convert(num, base):
    T = "0123456789ABCDEF"
    quotient, remainder = divmod(num, base)

    if quotient == 0:
        return T[remainder]
    else:
        return convert(quotient, base) + T[remainder]


if __name__ == "__main__":
    num_10 = 236

    num_2 = bin(num_10)  # 접두어 "0b"가 붙음
    num_8 = oct(num_10)
    num_16 = hex(num_10)

    print("10 -> 2 : ", num_2)
    print("10 -> 8 : ", num_8)
    print("10 -> 16 : ", num_16)
    print("=================")

    # int(x, base=10)
    print("2 -> 10 : ", int(num_2, 2))
    print("8 -> 10 : ", int(num_8, 8))
    print("16 -> 10 : ", int(num_16, 16))
    print("=================")

    print(convert(num_10, 2))
    print(convert(num_10, 8))
    print(convert(num_10, 16))

    print("=================")
    print(int(convert(num_10, 2), 2))
    print(int(convert(num_10, 8), 8))
    print(int(convert(num_10, 16), 16))

```
