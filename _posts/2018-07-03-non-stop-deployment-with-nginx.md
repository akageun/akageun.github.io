---
layout: post
title:  "NGINX 활용한 무중단 배포! 자동화 삽질기."
date:   2018-07-03 00:00:00 +0900
#categories: ["nginx", "deployment"]
---

- 개인 프로젝트에서 nginx를 웹서버로 사용하고 있다. 그 뒤에는 2대의 WAS를 사용하고 있고, nginx upstream 기능을 사용하여 로드 밸런싱을 했다. 그러다 보니 배포시에 아래 upstream 내 server를 주석처리하고 nginx 를 reload 하고 다 배포하고 또 주석 처리하고 nginx reload하고.... 다 처리하고 다시 reload하고... 휴.... 반복 해야 한다. 

- upstream.conf

```sh
upstream project_was {
    least_conn;
    server 127.0.0.1:8081 weight=1;
    server 127.0.0.1:8080 weight=1;
}
```

- 생각보다 이 작업이 시간도 많이 걸리고 사람이 작업을 하다 보니, 실수가 종종 나오곤 했다. 좋은 방법이 없나 고민을 하기 시작했다!

> 매일 반복적으로 처리하는 업무의 경우, 최대한 자동화를 진행해야 보다 쾌적한 하루를 보낼 수 있다.

# 1. 해결해보자.
 - Nginx Plus를 구매!
 - https://www.nginx.com/pricing
 - 비싸다.......

# 2. Nginx Upstream 파일을 만들자!

#### 위 upstream.conf 파일도 어찌 보면 단순 텍스트 파일이다.
- 배포할 서버를 제외하고 Argument로 활성화 시킬 서버를 넣고 위 파일을 새롭게 생성한다.

###### Argument
```sh
USE_HOST_INFO_STR=$1
```

###### 파일 생성
```sh
HOSTS=(${USE_HOST_INFO_STR//,/' '})

SERVER_TEXT_TMPL='server HOST weight=1;'
UPSTM_NM_TEXT_TMPL='upstream UPSTM_NM '

UPSTM_NM="tmp_upstream"
BASIC_NGINX_CONF_PATH="/etc/nginx/"
UPSTREAM_CONF_FILE_NM=$UPSTM_NM".conf"

RTN_CONF_STR="${UPSTM_NM_TEXT_TMPL/UPSTM_NM/$UPSTM_NM} { \n"
RTN_CONF_STR+=" least_conn; \n "
for host in ${HOSTS[@]}
do
RTN_CONF_STR+="${SERVER_TEXT_TMPL/HOST/$host} \n"
done
RTN_CONF_STR+="} \n"

echo -e $RTN_CONF_STR > $BASIC_NGINX_CONF_PATH$UPSTREAM_CONF_FILE_NM
```

# 3. nginx -t 명령어로 conf파일 valid 체크를 한다.
- 잘못된 내용이 들어갈 경우를 대비한 로직이다.

```sh
if nginx -t ; then
    echo "=======OK========"
    systemctl reload  nginx.service
else
    echo "=======ERROR========"
    exit -1;
fi
```

# 4. 전체파일

```
#!/bin/sh

USE_HOST_INFO_STR=$1

function create_conf_file
{
    HOSTS=(${USE_HOST_INFO_STR//,/' '})

    SERVER_TEXT_TMPL='server HOST weight=1;'
    UPSTM_NM_TEXT_TMPL='upstream UPSTM_NM '

    UPSTM_NM="tmp_upstream"
    BASIC_NGINX_CONF_PATH="/etc/nginx/"
    UPSTREAM_CONF_FILE_NM=$UPSTM_NM".conf"

    RTN_CONF_STR="${UPSTM_NM_TEXT_TMPL/UPSTM_NM/$UPSTM_NM} { \n"
    RTN_CONF_STR+=" least_conn; \n "
    for host in ${HOSTS[@]}
    do
    RTN_CONF_STR+="${SERVER_TEXT_TMPL/HOST/$host} \n"
    done
    RTN_CONF_STR+="} \n"

    echo -e $RTN_CONF_STR > $BASIC_NGINX_CONF_PATH$UPSTREAM_CONF_FILE_NM
}

function valid_check
{
    if nginx -t ; then
        echo "=======OK========"
        systemctl reload  nginx.service
    else
        echo "=======ERROR========"
        exit -1;
    fi
}

create_conf_file
valid_check
```


# 5. 느낀점
- 위 작업을 하면서 쉘 스크립트 작성은 오래 걸리지 않았다. 그러나 프로젝트를 진행하면서 배포를 자동화 해 놓으니 너무 너무 편했다. 

# 6. 결론!
- 반복적인 작업을 자동화하는 습관이 필요하다.
- 조금만 머리를 쓰면 몸이 편하다!
- 한번 배포할 때 30초에서 1분 정도 소비되던 반복 작업을 빼니, 좀 더 프로젝트에 집중 할 수 있었다.


*** 참고로 위에 스크립트를 업무에 가져다 쓰실 경우 sleep을 충분히 주시기 바랍니다. ^_^ ***