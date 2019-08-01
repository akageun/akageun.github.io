---
layout: post
title:  "[Spring Boot] Spring Boot file upload example"
date:   2016-08-22 09:00:00 +0900
categories:
 - spring
tags: 
 - spring
---

- 아래 소스는 간단한 파일업로드 기능에 ajax를 추가한 간단한 예제 코드 입니다.

# 1. JAVA Code
## 1) Controller

```java
package kr.geun.bootStartSample.www.controller;

import java.io.BufferedOutputStream;

import java.io.File;

import java.io.FileOutputStream;



import org.slf4j.Logger;

import org.slf4j.LoggerFactory;

import org.springframework.http.HttpStatus;

import org.springframework.http.ResponseEntity;

import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.RequestMapping;

import org.springframework.web.bind.annotation.RequestMethod;

import org.springframework.web.bind.annotation.RequestParam;

import org.springframework.web.multipart.MultipartFile;

@Controller
public class FileUploadController {
    private static final Logger LOG = LoggerFactory.getLogger(FileUploadController.class);

    private final String UPLOADPATH = "C:\\temp";

    /**
     * File Upload Page
     * 
     * @return
     */
    @RequestMapping(value = "/fileupload", method = RequestMethod.GET)
    public String fileUpload() {
        return "fileupload";
    }

    /**
     * File Save
     * 
     * @param uploadfile
     * @return
     */
    @RequestMapping(value = "/fileupload", method = RequestMethod.POST)
    public ResponseEntity<?> fileUpload(@RequestParam("uploadFile") MultipartFile uploadfile) {
        
        try {
            String fileNm = uploadfile.getOriginalFilename();
            String filePath = UPLOADPATH + File.separator + fileNm;

            BufferedOutputStream stream = new BufferedOutputStream(new FileOutputStream(new File(filePath)));
            stream.write(uploadfile.getBytes());
            stream.close();

        } catch (Exception e) {
            LOG.error(e.getMessage(), e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        return new ResponseEntity<>(HttpStatus.OK);
    }
}
```

## 2) Jsp
- HTML Code(fileupload.jsp)

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<script src="https://code.jquery.com/jquery-1.12.0.min.js"></script>
<form id="upload_file_frm" onsubmit="return false;">
	<table>
		<tr>
			<th>Upload File </th>
			<td>
				<input id="upload_file" type="file" name="uploadFile" accept="*" />
			</td>
			<td>
				<button id="upload_file_btn">Upload Btn</button>
			</td>
		</tr>
		<tr>	
			<td colspan="3" id="uload_result_msg"></td>
		</tr>
	</table>
</form>
```

- javascript

```javascript
<script type="text/javascript">
	$(document).ready(function(){
		$("#upload_file_btn").click(function(){
			uploadFileFunc();
		});
	});

	function uploadFileFunc(){
		$.ajax({
			url:"/fileupload",
			type: "POST",
			data: new FormData($("#upload_file_frm")[0]),
			enctype: 'multipart/form-data',
	        processData: false,
	        contentType: false,
	        cache: false,
	        success: function () {
	            $("#uload_result_msg").text("File Upload Success");
	        },
	        error: function () {
	            $("#uload_result_msg").text("File Upload Error");
	        }
		});
	}

</script>
```