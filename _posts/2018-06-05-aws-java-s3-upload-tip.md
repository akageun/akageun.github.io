---
layout: post
title:  "AWS s3 upload source Tip"
date:   2018-06-05 09:00:00 +0900
categories:
 - java
tags: 
 - aws
 - java
 - sdk
---
# 1. Content Type
- 파일명에 따라 ContentType을 설정한다.

```java
ObjectMetadata objMeta = new ObjectMetadata();
objMeta.setContentType(Mimetypes.getInstance().getMimetype(saveFileNm));
```

# 2. Content Length
- byte length를 추가한다.

```java
ObjectMetadata objMeta = new ObjectMetadata();

byte[] bytes = IOUtils.toByteArray(targetIS);
objMeta.setContentLength(bytes.length);

ByteArrayInputStream byteArrayIs = new ByteArrayInputStream(bytes);

PutObjectRequest putObjReq = new PutObjectRequest(bucketName, key, byteArrayIs, objMeta);
s3client.putObject(putObjReq);
```

- 해당 소스처리를 안할 경우 아래와 같은 warning 메시지가 뜬다.

> [WARN ] c.a.services.s3.AmazonS3Client:1714 - No content length specified for stream data.  Stream contents will be buffered in memory and could result in out of memory errors.

# 3. 임시파일로 업로드
- 서버 내 파일을 저장하지않고, 바로 S3에 업로드할 때 사용하면 좋다.

```java
File file = File.createTempFile("test", ".txt");
file.deleteOnExit();
```

