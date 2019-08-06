---
layout: post
title:  "[jdk 8]Stream GroupBy 사용하기."
date:   2019-08-06 09:00:00 +0900
categories:
 - java
tags: 
 - jdk8
---
- 데이터를 그룹핑해서 Map으로 리턴함.
- `groupingBy()` : Thread safe 하지 않음.

```java
Lists.newArrayList()
	.stream()
	.collect(Collectors.groupingBy(o -> o));
```

- `groupingByConcurrent()` : Thread safe 함.

```java
Lists.newArrayList()
	.stream()
	.collect(Collectors.groupingByConcurrent(o -> o));
```

## Sample 소스
#### model
```java
@Getter
@Setter
@Builder
private static class Temp {
	private String group;
	private String uuid;
}
```

#### Test
```java
@Test
public void listSample() {
	List<Temp> list = Arrays.asList(
		Temp.builder().group("A").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group("A").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group("B").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group("C").uuid(UUID.randomUUID().toString()).build()
	);

	list.stream()
		.collect(Collectors.groupingBy(Temp::getGroup))
		.forEach((key, value) -> {
			log.info("key :{}, value : {}", key, value.size());
		});
}
```

#### 결과
```
key :A, value : 2
key :B, value : 1
key :C, value : 1
```

## Null값이 있는 GroupBy Key!
- key 값에 null 이 있을 경우 아래와 같이 exception 발생함

```
Caused by: java.lang.NullPointerException: element cannot be mapped to a null key
    at java.util.Objects.requireNonNull(Objects.java:228)
    at java.util.stream.Collectors.lambda$groupingBy$45(Collectors.java:907)
    at java.util.stream.ReduceOps$3ReducingSink.accept(ReduceOps.java:169)
    at java.util.ArrayList$ArrayListSpliterator.forEachRemaining(ArrayList.java:1374)
    at java.util.stream.AbstractPipeline.copyInto(AbstractPipeline.java:481)
    at java.util.stream.AbstractPipeline.wrapAndCopyInto(AbstractPipeline.java:471)
    at java.util.stream.ReduceOps$ReduceOp.evaluateSequential(ReduceOps.java:708)
    at java.util.stream.AbstractPipeline.evaluate(AbstractPipeline.java:234)
    at java.util.stream.ReferencePipeline.collect(ReferencePipeline.java:499)
```

#### 대안코드
```java
@Test
public void listSample() {
	List<Temp> list = Arrays.asList(
		Temp.builder().group("A").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group("A").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group("B").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group("C").uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group(null).uuid(UUID.randomUUID().toString()).build(),
		Temp.builder().group(null).uuid(UUID.randomUUID().toString()).build()
	);

	list.stream()
		.collect(
			Collectors.toMap(
				Temp::getGroup,
				x -> {
					List<Temp> subList = new ArrayList<>();
					subList.add(x);
					return subList;
				},
				(left, right) -> {
					left.addAll(right);
					return left;
				},
				HashMap::new
			)
		)
		.forEach((key, value) -> {
			log.info("key :{}, value : {}", key, value.size());
		});
}
```

#### 결과
```
key :null, value : 2
key :A, value : 2
key :B, value : 1
key :C, value : 1
```
---
## 참고링크
- https://stackoverflow.com/questions/47868865/nullpointerexception-element-cannot-be-mapped-to-a-null-key
