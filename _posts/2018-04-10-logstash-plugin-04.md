---
layout: post
title:  "[LOGSTASH] 04. Logstash Plugin 01"
date:   2018-04-10 09:00:00 +0900
categories:
 - elastic
tags: 
 - logstash
---

# 1. Twitter
#### 1) input 소스

```
input {  
    twitter {
        consumer_key => "CONSUMER_KEY_GOES_HERE"
        consumer_secret => "CONSUMER_SECRET_GOES_HERE"
        oauth_token => "ACCESS_TOKEN_GOES_HERE"
        oauth_token_secret => "ACCESS_TOKEN_SECRET_GOES_HERE"
        keywords => ["test","sample"]
        full_tweet => true
    }
}
```

#### 2) 참고링크
- https://www.elastic.co/guide/en/logstash/current/plugins-inputs-twitter.html

# 2. Json_Line
#### 1) 설치

> bin/logstash-plugin list json_line
> ./bin/logstash-plugin install logstash-codec-json_lines

#### 2) 소스
```
output {
  stdout { codec => json_lines }
}
```

#### 3) 참고링크
- https://www.elastic.co/guide/en/logstash/current/plugins-codecs-json_lines.html#plugins-codecs-json_lines
- https://github.com/logstash-plugins/logstash-codec-json_lines

# 3. RSS
#### 1) 설치
> ./logstash-plugin install logstash-input-rss

#### 2) 소스

```
input {
        rss {
                interval => 300
                url => "https://rss.itunes.apple.com/api/v1/kr/ios-apps/top-grossing/all/100/explicit.rss"
        }
}
```
