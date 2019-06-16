---
layout: post
title:  "Curl을 사용하여 URL에 대한 상세정보 알아보기"
date:   2018-08-05 00:00:00 +0900
categories:
 - linux
tags:
 - linux
---

# 1. 하고싶은 것?
- curl을 사용하여 URL의 호출  시간 및 기타 상세 정보를 보고싶음.

# 2. 명령어 샘플 보기
- 명령어
```
curl -w '\nTime_namelookup:\t%{time_namelookup}\nTime_Connect:\t\t%{time_connect}\nTime_Appconnect:\t%{time_appconnect}\nTime_Redirect:\t\t%{time_redirect}\nTime_Pretransfer:\t%{time_pretransfer}\nTime_Starttransfer:\t%{time_starttransfer}\n\nTime_Total:\t\t%{time_total}\n' -o /dev/null -s  https://akageun.github.io
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/59407893-b120e780-8ded-11e9-9b65-2adaa6d20aa4.png)

# 3. 상세값 설명

time_appconnect | SSL/SSH/기타 연결/핸드 셰이크가 원격 호스트에 완료 될 때까지 걸린 시간 (초)
-- | --
time_connect | 원격 호스트에 대한 TCP 연결이 완료 될 때까지 소요된 시간(초)
time_namelookup | namelookup이 완료될때 까지 소요된 시간(초)
time_pretransfer |  
time_redirect | 여러 리디렉션의 전체 실행 시간을 보여줍니다.
time_starttransfer |  
time_total | 전체 소요 시간

# 4. 더 많은 정보 보기
- format.json을 만든다.

```json
{
  "host": {
    "local_ip": "%{local_ip}",
    "local_port": "%{local_port}",
    "remote_ip": "%{remote_ip}",
    "remote_port": "%{remote_port}"
  },
  "connection": {
    "http_version": "%{http_version}",
    "http_code": "%{http_code}",
    "http_connect": "%{http_connect}",
    "num_connects": "%{num_connects}",
    "num_redirects": "%{num_redirects}",
    "redirect_url": " %{redirect_url}"
  },
  "file": {
    "content_type": "%{content_type}",
    "filename_effective": "%{filename_effective}",
    "ftp_entry_path": "%{ftp_entry_path}",
    "size_download": "%{size_download}",
    "size_header": "%{size_header}",
    "size_request": "%{size_request}",
    "size_upload": "%{size_upload}",
    "speed_download": "%{speed_download}",
    "speed_upload": "%{speed_upload}",
    "ssl_verify_result": "%{ssl_verify_result}",
    "url_effective": "%{url_effective}"
  },
  "time": {
    "time_appconnect": "%{time_appconnect}",
    "time_connect": "%{time_connect}",
    "time_namelookup": "%{time_namelookup}",
    "time_pretransfer": "%{time_pretransfer}",
    "time_redirect": "%{time_redirect}",
    "time_starttransfer": "%{time_starttransfer}",
    "time_total": "%{time_total}"
  }
}
```

- 명령어

> curl -w '@/path/format.json' -o /dev/null -s  https://akageun.github.io

- 결과

```json
{
   "host":{
      "local_ip":"172.30.112.192",
      "local_port":"61895",
      "remote_ip":"27.0.236.139",
      "remote_port":"80"
   },
   "connection":{
      "http_version":"1.1",
      "http_code":"400",
      "http_connect":"000",
      "num_connects":"1",
      "num_redirects":"0",
      "redirect_url":" "
   },
   "file":{
      "content_type":"text/html; charset=iso-8859-1",
      "filename_effective":"/dev/null",
      "ftp_entry_path":"",
      "size_download":"347",
      "size_header":"166",
      "size_request":"79",
      "size_upload":"0",
      "speed_download":"2330.000",
      "speed_upload":"0.000",
      "ssl_verify_result":"0",
      "url_effective":"http://blog.geun.kr/"
   },
   "time":{
      "time_appconnect":"0.000000",
      "time_connect":"0.142898",
      "time_namelookup":"0.137409",
      "time_pretransfer":"0.142976",
      "time_redirect":"0.000000",
      "time_starttransfer":"0.148800",
      "time_total":"0.148910"
   }
}
```

## 참고링크
- https://www.shellhacks.com/check-website-response-time-linux-command-line/
- https://gist.github.com/manifestinteractive/ce8dec10dcb4725b8513
- https://blog.josephscott.org/2011/10/14/timing-details-with-curl/