---
layout: post
title:  "Bootstrap 사용하기"
date:   2018-08-08 09:00:00 +0900
categories:
 - html/css
tags: 
 - bootstrap
---
# 1. Bootstrap
- 웹사이트 제작시에 많이 사용 되는 요소들을 모아놓은 오픈소스
- 반응형 웹페이지를 손쉽게 만들 수 있다.
- 수많은 유, 무료 테마

# 2. 사용해보기
## 1) js, css
- cdn 링크 : http://getbootstrap.com/docs/4.1/getting-started/introduction/ 참고

![image](https://user-images.githubusercontent.com/13219787/61306503-b4155a80-a827-11e9-8259-489468e33f02.png)

- 다운로드 : http://getbootstrap.com 참고

# 3. 샘플
## 1) BUTTON
- http://getbootstrap.com/docs/4.1/components/buttons/
- 샘플코드
```html
<button type="button">기본버튼</button>

<button type="button" class="btn">BS 버튼</button>

<button type="button" class="btn btn-primary">Primary</button>
<button type="button" class="btn btn-secondary">Secondary</button>
<button type="button" class="btn btn-success">Success</button>
<button type="button" class="btn btn-danger">Danger</button>
<button type="button" class="btn btn-warning">Warning</button>
<button type="button" class="btn btn-info">Info</button>
<button type="button" class="btn btn-light">Light</button>
<button type="button" class="btn btn-dark">Dark</button>

<button type="button" class="btn btn-link">Link</button>

<button type="button" class="btn btn-primary btn-lg">Primary</button>
<button type="button" class="btn btn-success btn-md">Success</button>
<button type="button" class="btn btn-secondary btn-sm">Secondary</button>

<button type="button" class="btn btn-outline-primary">Primary</button>
<button type="button" class="btn btn-outline-secondary">Secondary</button>
<button type="button" class="btn btn-outline-success">Success</button>
<button type="button" class="btn btn-outline-danger">Danger</button>
<button type="button" class="btn btn-outline-warning">Warning</button>
<button type="button" class="btn btn-outline-info">Info</button>
<button type="button" class="btn btn-outline-light">Light</button>
<button type="button" class="btn btn-outline-dark">Dark</button>

<button type="button" class="btn btn-primary btn-lg btn-block">Block level button</button>
<button type="button" class="btn btn-secondary btn-lg btn-block">Block level button</button>
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61306598-e32bcc00-a827-11e9-92fc-4e9d07139b6a.png)

## 2) input
- http://getbootstrap.com/docs/4.1/components/input-group/
- 샘플소스
```html
기본 <input type="text">

<input type="text" class="form-control" placeholder="GEUN.kr">


<div class="input-group mb-3">
    <div class="input-group-prepend">
        <span class="input-group-text" id="addon1">@</span>
    </div>
    <input type="text" class="form-control" placeholder="Username" aria-describedby="addon1">
</div>

<div class="input-group mb-3">
    <input type="text" class="form-control" placeholder="Username" aria-describedby="addon2">
    <div class="input-group-append">
        <span class="input-group-text" id="addon2">@geun.kr</span>
    </div>
</div>
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61306613-e9ba4380-a827-11e9-84d0-544d6a0d7e90.png)

## 3) NavBar
- https://getbootstrap.com/docs/4.1/components/navbar/
- 샘플코드
```html
<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="#">GEUN.kr</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
            aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item active">
                <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#">BLOG</a>
            </li>
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true"
                   aria-expanded="false">
                    Language
                </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="dropdown-item" href="#">JAVA</a>
                    <a class="dropdown-item" href="#">PHP</a>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" href="#">JAVASCRIPT</a>
                </div>
            </li>
            <li class="nav-item">
                <a class="nav-link disabled" href="#">Disabled</a>
            </li>
        </ul>
        <form class="form-inline my-2 my-lg-0">
            <input class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search">
            <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
        </form>
    </div>
</nav>
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61306765-1706f180-a828-11e9-9432-eb9911ff8383.png)

## 4) Table
- https://getbootstrap.com/docs/4.1/content/tables/
- 샘플소스

```html
<table>
    <thead>
    <th>Firstname</th>
    <th>Lastname</th>
    <th>Email</th>
    </thead>
    <tbody>
    <tr>
        <td>Mary</td>
        <td>Moe</td>
        <td>mary@example.com</td>
    </tr>
    <tr>
        <td>July</td>
        <td>Dooley</td>
        <td>july@example.com</td>
    </tr>
    </tbody>
</table>

<table class="table table-striped table-bordered">
    <thead>
    <th>Firstname</th>
    <th>Lastname</th>
    <th>Email</th>
    </thead>
    <tbody>
    <tr>
        <td>Mary</td>
        <td>Moe</td>
        <td>mary@example.com</td>
    </tr>
    <tr>
        <td>July</td>
        <td>Dooley</td>
        <td>july@example.com</td>
    </tr>
    <tr>
        <td>Mary</td>
        <td>Moe</td>
        <td>mary@example.com</td>
    </tr>
    <tr>
        <td>July</td>
        <td>Dooley</td>
        <td>july@example.com</td>
    </tr>
    </tbody>
</table>

```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61306775-1c643c00-a828-11e9-864a-1e446ffcbc7c.png)

## 5) Pagination
- https://getbootstrap.com/docs/4.1/components/pagination/
- 샘플소스

```html
<ul class="pagination">
    <li class="page-item"><a class="page-link" href="#">Previous</a></li>
    <li class="page-item"><a class="page-link" href="#">1</a></li>
    <li class="page-item"><a class="page-link" href="#">2</a></li>
    <li class="page-item"><a class="page-link" href="#">3</a></li>
    <li class="page-item"><a class="page-link" href="#">4</a></li>
    <li class="page-item"><a class="page-link" href="#">5</a></li>
    <li class="page-item"><a class="page-link" href="#">Next</a></li>
</ul>
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61306788-1ff7c300-a828-11e9-9d01-7f9eb7f80d94.png)

## 6) Modal
- https://getbootstrap.com/docs/4.1/components/modal/
- 샘플소스

```html
<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#exampleModal">
    Launch demo modal
</button>

<!-- Modal -->
<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                ...
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>
            </div>
        </div>
    </div>
</div>
```

- 결과


![image](https://user-images.githubusercontent.com/13219787/61306793-2423e080-a828-11e9-9bda-23582a1713b1.png)

## 7) containers
- https://getbootstrap.com/docs/4.0/layout/overview/#containers
- 샘플소스

```html
<div class="container">

</div>
```
- 결과

![image](https://user-images.githubusercontent.com/13219787/61306810-2a19c180-a828-11e9-8f8a-22770161b5b2.png)

- 샘플소스

```html
<div class="container-fluid">

</div>
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/61306822-2dad4880-a828-11e9-8611-531f99ebbc1d.png)


## 8) Grid 시스템 
- https://getbootstrap.com/docs/4.1/layout/grid/
- 참고 : http://shoelace.io/ 
- 브라우저 크기에 따라 최대 12개의 컬럼을 어떻게 배치할 건지에 대한 정의
- 샘플코드

```html
<!-- Control the column width, and how they should appear on different devices -->
<div class="row">
    <div class="col-sm-6" style="background-color:yellow;">50%</div>
    <div class="col-sm-6" style="background-color:orange;">50%</div>
</div>
<br>

<div class="row">
    <div class="col-sm-4" style="background-color:yellow;">33.33%</div>
    <div class="col-sm-4" style="background-color:orange;">33.33%</div>
    <div class="col-sm-4" style="background-color:yellow;">33.33%</div>
</div>
<br>

<!-- Or let Bootstrap automatically handle the layout -->
<div class="row">
    <div class="col-sm" style="background-color:yellow;">25%</div>
    <div class="col-sm" style="background-color:orange;">25%</div>
    <div class="col-sm" style="background-color:yellow;">25%</div>
    <div class="col-sm" style="background-color:orange;">25%</div>
</div>
<br>

<div class="row">
    <div class="col" style="background-color:yellow;">25%</div>
    <div class="col" style="background-color:orange;">25%</div>
    <div class="col" style="background-color:yellow;">25%</div>
    <div class="col" style="background-color:orange;">25%</div>
</div>
```

#### PC
![image](https://user-images.githubusercontent.com/13219787/61306841-31d96600-a828-11e9-9a84-c69b57326927.png)

#### 태블릿
![image](https://user-images.githubusercontent.com/13219787/61306852-36058380-a828-11e9-92f4-f2bba69c133b.png)

#### 폰
![image](https://user-images.githubusercontent.com/13219787/61306859-3a31a100-a828-11e9-929b-ca337e28f075.png)

---

#### 추가적으로 아래 사이트를 가시면 커스텀한 Bootstrap compenent를 사용할 수 있습니다.
 - https://bootsnipp.com/