---
layout: post
title:  "Spring Bean에 대하여 - 1"
date:   2020-04-30 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
---

- Spring 에서 자주 이야기하고 사용하고 있는 `@Bean` 에 대해서 알아보자.
- 설정하는 법, Lifecycle, Scope 등을 알아보자

## Bean에 대해서
- Spring IoC 컨테이너가 인스턴스화, 관리, 생성하는 자바 객체

## Bean 설정하는 법
#### 대상자를 알아서 등록하는 법 : Component Scan
- `org.springframework.context.annotation.@ComponentScan` 을 사용하여 특정 `package` 나 `class`를 지정하여 Bean을 등록할 수 있다.
     - backPackage 를 따로 지정 안할 경우 Main Bootstrap Class 하위로 스캔한다.

#### 직접 등록하는 법
- `@Bean` 을 선언하여 사용

###### java Config

```java 
@Bean
public TempBean tempBean() {
    return new TempBean();
}
```

###### xml
```xml
<bean id="..." class="...">
	<property name="" value=""/>
</bean>
```

## Bean Scope
- singleton(default로 사용), prototype

#### java Source로 이해하기
- TempBean 이라는 Class 를 만들고 두가지 Scope의 Bean 을 생성하자.

###### TempBean
```java
@Slf4j
public class TempBean implements InitializingBean, DisposableBean {

    public TempBean() {
        log.info("TempBean 생성자 호출!");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        log.info("afterPropertiesSet");
    }

    @Override
    public void destroy() throws Exception {
        log.info("destroy");
    }
}
```

###### Bean 선언하기
```java
@Configuration
public class Config {
    @Bean("tempBean1")
    public TempBean tempBean1() {
        return new TempBean();
    }

    @Bean("tempBean3")
    @Scope("prototype")
    public TempBean tempBean3() {
        return new TempBean();
    }
}
```

###### 실행하기
```java
@Slf4j
public class Application implements CommandLineRunner {

    @Autowired
    private ApplicationContext applicationContext;

    @Override
    public void run(String... args) throws Exception {
        TempBean tempBean1 = applicationContext.getBean("tempBean1", TempBean.class);
        TempBean tempBean2 = applicationContext.getBean("tempBean1", TempBean.class);
        log.info("singleton Bean : {}", tempBean1 == tempBean2);

        TempBean tempBean3 = applicationContext.getBean("tempBean3", TempBean.class);
        TempBean tempBean4 = applicationContext.getBean("tempBean3", TempBean.class);
        log.info("prototype Bean : {}", tempBean3 == tempBean4);
    }
}
```

###### 결과보기
- singleton 으로 선언할 경우 같은 인스턴스로 나오지만 `prototype` 으로 선언할 경우 매번 새로운 객체가 생성된다. 
- 로그보기

```
TempBean 생성자 호출!
afterPropertiesSet
singleton Bean : true

TempBean 생성자 호출!
afterPropertiesSet
TempBean 생성자 호출!
afterPropertiesSet
prototype Bean : false
```

## Bean life cycle
#### Java source
```java
@Slf4j
public class BeanLifeCycle implements InitializingBean, DisposableBean {

	public BeanLifeCycle() {
		log.info("BeanLifeCycle 생성자 호출!");
	}

	@PostConstruct
	public void postConstruct() {
		log.info("postConstruct");
	}

	@Override
	public void afterPropertiesSet() throws Exception {
		log.info("afterPropertiesSet");
	}

	public void initMethod() {
		log.info("initMethod");
	}

	@Override
	public void destroy() throws Exception {
		log.info("destroy");
	}

	@PreDestroy
	public void preDestroy() {
		log.info("preDestroy");
	}

	public void destroyMethod() {
		log.info("destroyMethod");
	}
}
```

#### 결과보기
```
BeanLifeCycle : BeanLifeCycle 생성자 호출!
BeanLifeCycle : postConstruct
BeanLifeCycle : afterPropertiesSet
BeanLifeCycle : initMethod
```

```
BeanLifeCycle : preDestroy
BeanLifeCycle : destroy
BeanLifeCycle : destroyMethod
```
