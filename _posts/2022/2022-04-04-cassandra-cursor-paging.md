---
layout: post
title:  "[Cassandra] Cursor paging"
date:   2022-04-04 09:00:00 +0900
categories:
- database
tags:
- cassandra
- java
---

- Cassandra 와 같은 nosql 을 사용했을 때, 전체 row 의 갯수를 조회하여 pagination 하는 방법은 득보다 실이 큰 상황이다.
- cursor base 로 pagination 하여 최대한 사용자의 사용성을 유지하도록 변경 할 수 있다.
- 다음은 `Spring` 에서 `Cassandra` 를 사용할 때, 할 수 있는 소스 코드다.

```java
private static final String DEFAULT_CURSOR_MARK = "-1";
private static final int PAGE_SIZE = 1;

private TempData getData() {
	return getData(DEFAULT_CURSOR_MARK);
}

private TempData getData(String cursorMark) {
	CassandraPageRequest firstRequest = CassandraPageRequest.first(PAGE_SIZE); //첫번째 페이지가 아닐 경우 오류가 발생함.

	PagingState pagingState = null;
	if (!DEFAULT_CURSOR_MARK.equalsIgnoreCase(cursorMark)) {
		pagingState = PagingState.fromString(cursorMark);
	}

	CassandraPageRequest pageRequest = CassandraPageRequest.of(firstRequest, pagingState);

	Slice<TestEntity> entitySlice = testRepository.findAll(pageRequest);

	String previousCursorMark = DEFAULT_CURSOR_MARK;
	if (!entitySlice.isFirst()) {
		CassandraPageRequest p = (CassandraPageRequest) entitySlice.previousPageable();
		if (p.isPaged() && p.getPagingState() != null) {
			previousCursorMark = p.getPagingState().toString();
		}
	}

	String nextCursorMark = DEFAULT_CURSOR_MARK;
	if (!entitySlice.isLast()) {
		CassandraPageRequest p = (CassandraPageRequest) entitySlice.nextPageable();
		if (p.isPaged() && p.getPagingState() != null) {
			nextCursorMark = p.getPagingState().toString();
		}
	}

	return TempData.builder()
		.previousCursorMark(previousCursorMark)
		.entityList(entitySlice.getContent())
		.nextCursorMark(nextCursorMark)
		.build();
}
```

- `CassandraPageRequest.first`

![image](https://user-images.githubusercontent.com/13219787/161558268-17b4c908-ebb8-4074-9689-effcd056ddff.png)


- `PagingState pagingState` 을 사용할 경우 페이지 번호는 무시되므로 크게 중요하지 않다.


---
- https://shivanshugoyal0111.medium.com/pagination-in-cassandra-b7e45ec2656a