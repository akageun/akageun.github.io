---
layout: post
title:  "[Spring Boot] embedded-redis 사용해보기."
date:   2018-04-15 09:00:00 +0900
categories:
 - spring
tags: 
 - redis
 - embedded
---

# 1. embedded-redis
- 개발 버전, 프로토 타이핑 등에서 간단하게 사용하기 편함.

# 2. pom.xml
- https://github.com/kstyrc/embedded-redis 로 사용할 예정

```xml
<!-- embedded-redis -->
<dependency>
   <groupId>com.github.kstyrc</groupId>
   <artifactId>embedded-redis</artifactId>
   <version>0.6</version>
</dependency>
```

# 3. Redis Configuration
- application.yml

```yaml
spring:
  redis:
    host: localhost
    port: 6379
    database: 0
```

- Start 및 stop 설정 필요

```java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import redis.embedded.RedisServer;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.IOException;

/**
 * Embedded Redis Configration
 *
 * @author akageun
 */
@Component
public class EmbeddedRedisConfiguration {

   @Value("${spring.redis.port}")
   private int redisPort;

   private RedisServer redisServer;

   @PostConstruct
   public void startRedis() throws IOException {
      redisServer = new RedisServer(redisPort);
      redisServer.start(); //Redis 시작
   }

   @PreDestroy
   public void stopRedis() {
      redisServer.stop(); //Redis 종료
   }

}
```

- Template 설정

```java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.jedis.JedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * Redis Configuration
 *
 * @author akageun
 */
@Configuration
public class RedisConfig {

    @Value("${spring.redis.host}")
    private String redisHost;

    @Value("${spring.redis.port}")
    private int redisPort;

    @Value("${spring.redis.database}")
    private int redisDatabase;

    /**
     * Factory
     *
     * @return
     */
    @Bean
    public JedisConnectionFactory jedisConnectionFactory() {
        JedisConnectionFactory jedisConnectionFactory = new JedisConnectionFactory();
        jedisConnectionFactory.setHostName(redisHost);
        jedisConnectionFactory.setPort(redisPort);
        jedisConnectionFactory.setDatabase(redisDatabase);
        jedisConnectionFactory.setUsePool(true);
        return jedisConnectionFactory;
    }

    /**
     * redis Template
     *
     * @return
     */
    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(new StringRedisSerializer());
        redisTemplate.setConnectionFactory(jedisConnectionFactory());

        return redisTemplate;
    }
}
```

# 4. 사용
- RedisTemplate 사용

```java
@Autowired
private RedisTemplate redisTemplate;
```

- Code

```java
redisTemplate.opsForValue().set("test", "test1111");
redisTemplate.opsForValue().get("test");
```

정말 간단하다.
