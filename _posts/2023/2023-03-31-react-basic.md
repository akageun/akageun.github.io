---
layout: post
title:  "[React.js] 살짝 찍어 맛보기"
date:   2023-03-31 09:00:00 +0900
categories:
- front
tags:
- react
---

- https://ko.reactjs.org/docs/getting-started.html

## React.js 란?
- Component 기반
- 여러 화면에서 재사용 가능하도록 제공

## JSX
- javascript에 XML을 추가하여 확장한 문법

## 시작하기
- 프로젝트 생성을 위한 설치(-g 는 글로벌설치)
> npm install -g create-react-app

- 프로젝트 생성
> create-react-app ${projectName}

- 실행
> cd ${projectName}
> npm run start

- http://localhost:3000/

## 파일 구조
- index.js 를 시작으로 내부에 app.js 를 import 하여 화면 구성

## props
- 단방향
  - 부모에서 자식으로 내려주기만 가능
  - 읽기전용.
- index.js 에서 아래와 같이 수정해보자

```javascript
<App subject="React Test" />
```

- app.js 에서 function 을 수정해보자

```javascript
function App(props) {
  console.log("props : ", props)
//...
}
```

- 결과

> props :  {subject: 'React Test'}

## state
- 컴포넌트별로 상태관리가 가능

> const [ 데이터, 데이터변경함수 ] = useState(초기값(생략가능));

```javascript
import {useState} from 'react';

export default function App() {
    const [count, setCount] = useState(0); //array, object 사용 가능

    const handleClick = () => {
        setCount(count + 1);
    };
    return (
        <div className="App">
            <div>
                <div>
                    <h3>버튼 클릭 수 : {count}</h3>
                    <button onClick={handleClick}>
                        Click Me
                    </button>
                </div>
            </div>
        </div>
    );
}
```

## Component
### 함수형 컴퍼넌트 (Stateless Functional Component)
- 기본적인 js function 으로 생성하는 방식

```javascript
import React from 'react';

function SampleComponent(props) {
	return <h1>Hello, {props.subject}</h1>;
}

export default SampleComponent;
```

### Class 컴퍼넌트
- properties, state, life cycle 함수가 필요한 구조에서 사용됨.

```javascript
import React, {useState} from 'react';

class Sample extends React.Component {
    constructor(props) { //생성자
        super(props);
    }

    componentDidMount() { // life cycle
    }

    render() {
        return <div>Hello, {this.props.subject}</div>;
    }
}

export default Sample;
```


## 이벤트 처리
- Component 내에서 Dom 이벤트를 사용할 경우

> JSX내에서 'on + 이벤트명'

- 문법은 `camelCase` 를 사용한다.
- 함수로 이벤트 핸들러를 전달한다.

```javascript
onClick="functionName()"  // 잘못된 호출
onClick={functionName} //정상
```

- 기본동작 방지
  - false 리턴이 아니라 이벤트 방지처리를 해줘야함.

```javascript
const functionName = (e)=> {
  e.preventDefault(); 
}
```