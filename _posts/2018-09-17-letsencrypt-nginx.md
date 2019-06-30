# 1. certbot 설치하기.

```
sudo su

git clone https://github.com/certbot/certbot

cd certbot

./certbot-auto --os-packages-only

./tools/venv.sh

#certbot 인증서 발행

source ./venv/bin/activate

./venv/bin/certbot -d [*.도메인] --email [Email] --text --agree-tos --server  https://acme-v02.api.letsencrypt.org/directory --manual --preferred-challenges dns --expand --renew-by-default  --manual-public-ip-logging-ok certonly
```
- 이메일로 인증한번하고 txt도 인증해야함.

# 2. 도메인 txt 등록
- 사용중인 DNS를 이용하여 등록.

## 1) cafe 24
 
![image](https://user-images.githubusercontent.com/13219787/60397263-e5362f80-9b85-11e9-8cc2-4f4f2c7b2e70.png) 
 
## 2) route 53

![image](https://user-images.githubusercontent.com/13219787/60397264-e8c9b680-9b85-11e9-8c11-a1860bc56035.png)

# 3. nginx 설정하기.

```
server 
{
    listen       443;
    server_name  [도메인];

    ssl                  on;
    ssl_certificate /etc/letsencrypt/live/[도메인]]/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/[도메인]]/privkey.pem;
    ssl_session_timeout  5m;
    ssl_protocols  SSLv2 SSLv3 TLSv1;
    ssl_ciphers  HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers   on;

    #location 세팅
}
```

# 4. 갱신하기
- 해당 인증서는 3개월에 한번씩 갱신해줘야한다.
- 신경쓰기 귀찮으니... 알아서 될 수 있도록 cron을 등록한다.
```
sudo su

crontab -e
```

- 아래 내용을 추가한다.
```
0 1 * * * ./venv/bin/certbot renew --dry-run

0 1 * * * systemctl reload nginx
```


