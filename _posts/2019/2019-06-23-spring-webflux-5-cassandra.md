---
layout: post
title:  "[Spring Webflux] 5. WebFlux + Cassandra 사용해보기"
date:   2019-06-23 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
 - webflux
 - reactive
 - cassandra
---
# Webflux Cassandra

# cassandra 준비
#### Keyspace 생성
```cql
CREATE KEYSPACE IF NOT EXISTS example WITH replication = {'class':'SimpleStrategy', 'replication_factor':1};

use example;
```
#### Table 생성
```cql
CREATE TABLE IF NOT EXISTS  example.webflux_test (
    key text PRIMARY KEY,
    value int,
);
```

#### 테스트 데이터 추가
```cql
INSERT INTO webtoon_push.webflux_test (key, value) values ('1', 1);
INSERT INTO webtoon_push.webflux_test (key, value) values ('2', 2);
INSERT INTO webtoon_push.webflux_test (key, value) values ('3', 3);
```

# dependencies
#### pom.xml
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-cassandra-reactive</artifactId>
</dependency>
```

#### Gradle
```gradle
dependencies {
    compile('org.springframework.boot:spring-boot-starter-data-cassandra-reactive')
}
```

## Configuration
```java
@Configuration
@EnableReactiveCassandraRepositories
public class ReactiveCassandraConfig extends AbstractReactiveCassandraConfiguration {

  @Value("${cassandra.contactpoints}")
  private String contactPoints;

  @Value("${cassandra.port}")
  private int port;

  @Value("${cassandra.keyspace}")
  private String keyspace;

  @Value("${cassandra.basepackages}")
  private String basePackages;

  @Override
  protected String getKeyspaceName() {
    return keyspace;
  }

  @Override
  protected String getContactPoints() {
    return contactPoints;
  }

  @Override
  protected int getPort() {
    return port;
  }

  @Override
  public SchemaAction getSchemaAction() {
    return SchemaAction.CREATE_IF_NOT_EXISTS;
  }

  @Override
  public String[] getEntityBasePackages() {
    return new String[]{basePackages};
  }
}
```

## Model
```java
@Builder
@Getter
@Setter
@NoArgsConstructor
@Table("webflux_test")
public class WebfluxTest {

	@PrimaryKey
	private String key;

	@Column("value")
	private int value;

	public WebfluxTest(String key, int value) {
		this.key = key;
		this.value = value;
	}
}
```

## Repository
```java
@Repository
public interface WebfluxTestRepository extends ReactiveCassandraRepository<WebfluxTest, String> {
}
```

## 실행
```java
public class CommandLineRunnerTmp implements CommandLineRunner {
	@Autowired
	private WebfluxTestRepository webfluxTestRepository;

	@Override
	public void run(String... args) throws Exception {
		WebfluxTest test1 = WebfluxTest.builder().key(UUID.randomUUID().toString() + "_" + 1).value(1).build();
		WebfluxTest test2 = WebfluxTest.builder().key(UUID.randomUUID().toString() + "_" + 2).value(2).build();
		WebfluxTest test3 = WebfluxTest.builder().key(UUID.randomUUID().toString() + "_" + 3).value(3).build();

		getList().subscribe(info -> log.info("sub 1 : {}", info));

		webfluxTestRepository.insert(Arrays.asList(test1, test2, test3));

		getList().subscribe(info -> log.info("sub 1 : {}", info));

	}

	private Flux<WebfluxTest> getList() {
		return webfluxTestRepository.findAll()
			.doOnNext(info -> log.info("info : {} ", info))
			.defaultIfEmpty(WebfluxTest.builder().value(0).build());

	}
}
```

# 흔적 지우기
## cassandra drop table
```cql
DROP TABLE example.webflux_test;
```

---
# 참고링크

- Spring 공식문서 :  https://docs.spring.io/spring-data/cassandra/docs/current/reference/html/#cassandra.reactive
