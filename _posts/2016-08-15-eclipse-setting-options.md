---
layout: post
title:  "[Eclipse] 초기 Setting - Option 편!"
date:   2016-08-15 00:00:00 +0900
categories:
 - tools
tags: 
 - eclipse
 - java
---

# 1. 빠르게 로그 선언
- ~/ preferences -> java -> editor -> templates -> new

> Name : LOG

> Pattern : private static final Logger LOG = LoggerFactory.getLogger(${enclosing_type}.class);

- 사용법 LOG 입력 후 자동완성하면 위 pattern이 입력된다.

![image](https://user-images.githubusercontent.com/13219787/60030303-b3cce800-96dd-11e9-9a86-47b146851a7e.png)



# 2. 로그 출력양 조절
- 로그 출력양 제한 해제
- ~/ preferences -> Run/Debug -> Console
- Limit console output 해제

![image](https://user-images.githubusercontent.com/13219787/60030349-c810e500-96dd-11e9-956e-9afc3a71796f.png)

# 3. 소스를 좀 더 명확하게 보자!
- ~/ preferences -> java -> editor -> Syntax Coloring -> Java -> Classes
- Enable 클릭, Color 변경(원하는 색상), Bold처리
 
![image](https://user-images.githubusercontent.com/13219787/60030391-d9f28800-96dd-11e9-9e20-9e8d8d5e22c4.png)

# 4. javadoc 선언 수정
- ~/ preferences -> java -> Code Style -> Code Templates -> Comments -> Overriding methods Edit
- override 메소드에 자동주석을 할 경우

![image](https://user-images.githubusercontent.com/13219787/60030445-ebd42b00-96dd-11e9-9e01-7cdf5dc60251.png)

- 원하는 형태의 주석으로 수정해야함.

# 5. ${user}를 활용해보자
- 자동주석을 할 경우 @author 에 시스템 유저명이 들어간다. 시스템 유저명과 주석 @author명을 다르게 하고 싶을 경우 eclipse.ini에 아래 소스 추가
- -Duser.name="유저명"

# 6. lombok.jar 사용하기
- lombok 홈페이지
- 실행시켜서 사용할 sts 선택
- eclipse.ini에 추가된 것을 확인 할 수 있다.

# 7. 힙 메모리 실시간 보기
- ~/ preferences -> General -> Show heap status 클릭

![image](https://user-images.githubusercontent.com/13219787/60030518-0f977100-96de-11e9-8b21-842feb016263.png)

# 8. 이클립스 메모리 늘리기
- eclipse.ini 에 아래 소스 추가

> -Xms1024m
> -Xmx2048m
> -XX:MaxPermSize=512m

# 9. template 수정
- HTML 스크립트 선언 내 기본 주석 삭제
```
<script type="text/javascript">
<!--

//-->
</script>
```

![image](https://user-images.githubusercontent.com/13219787/60030589-36ee3e00-96de-11e9-912f-3d342c5597d3.png)

- JAVA Method 내 기본 주석

> // ${todo} Auto-generated method stub
> ${body_statement}

![image](https://user-images.githubusercontent.com/13219787/60030621-43729680-96de-11e9-88db-3957efe9ba7b.png)




