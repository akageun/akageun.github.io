---
layout: post
title:  " [webpack 물고 뜯고 맛보기!!] 1. Webpack 이란?"
date:   2019-06-19 00:00:00 +0900
categories:
 - front
tags: 
 - webpack
 - es6
---

![676C4C78-1052-416C-935B-FB8DF625126A](https://user-images.githubusercontent.com/13219787/59485647-931cbb00-8eb1-11e9-95a6-94c017a73a48.png)

# 시작하기 전에...
- vue나 react 등을 사용하려면 webpack은 없어서는 안될 존재가 되었다.
- 설정값이 너무 많다. 
- 제대로 알고 사용해야하고 싶어졌다.
- 그래서 작성하기 시작한, *물고 뜯고 맛보기* 시리즈를 시작한다.

# 사전에 필요한 준비물.
- node
- npm or yarn

# webpack 이란?
- javascript 등 front 에서 사용되는 코드를 모듈단위로 관리하는 모듈시스템을 가능하게 해주는 도구
- js 모듈 또는 css, 이미지 등 필요한 assets을 찾아서 브라우저가 인식할 수 있는 번들로 빌드하는 *모듈 번들러*

## 간단하게 사용해보기
- Default package.json init

> npm init -y

- npm 설치

> npm install --save-dev webpack

- webpack 실행

> webpack

- 변경 내용에 맞춰서 자동으로 빌드

> webpack --watch

- 특정 config 파일로 동작
    - (webpack.config.js 의 경우 추후 설명할 예정)

> touch webpack.config.js

```javascript
const webpack = require('webpack');

module.exports = {
  mode: 'development', /** 실환경일때 production 로 할경우 알아서 최적화 해줌. */
  entry: { /** app이면 결과물이 app.js로 나오고, zero면 zero.js로 나옴. */
    app: '', 
  },
  output: {
    path: 'dist', /** output으로 나올 파일이 저장될 경로 */
    filename: '[name].js', /** [hash], [chunkhash] 도 있음. */
    publicPath: '/', /** publicPath는 파일들이 위치할 서버 상의 경로 */
  },
  module: { /** babel 등을 사용하는 곳 */

  },
  plugins: [ /** 부가적인 기능 */

  ],
  optimization: { /** 최적화 관련 플러그인 */

  },
  resolve: {
    modules: ['node_modules'],
    extensions: ['.js', '.json', '.css'],
    alias: { /** 별칭 기능 */
    
    }
  },
};
```

> webpack --config webpack.config.js

