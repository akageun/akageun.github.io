---
layout: post
title:  "AmazonS3Client, deprecated!!!"
date:   2018-05-12 09:00:00 +0900
categories:
 - java
tags: 
 - aws
 - java
 - sdk
---
# 1. 기존 메소드

```java
AmazonS3 s3Client = new AmazonS3Client(new BasicAWSCredentials(accessKey, secretKey));
```

- 해당 메소드 수석을 참고하면 아래와 같다.

```java
/**
 * Constructs a new Amazon S3 client using the specified AWS credentials to
 * access Amazon S3.
 *
 * @param awsCredentials
 *            The AWS credentials to use when making requests to Amazon S3
 *            with this client.
 *
 * @see AmazonS3Client#AmazonS3Client()
 * @see AmazonS3Client#AmazonS3Client(AWSCredentials, ClientConfiguration)
 * @deprecated use {@link AmazonS3ClientBuilder#withCredentials(AWSCredentialsProvider)}
 */
@Deprecated
public AmazonS3Client(AWSCredentials awsCredentials) {
    this(awsCredentials, configFactory.getConfig());
}
```

# 2. 변경된 메소드

```java
BasicAWSCredentials creds = new BasicAWSCredentials(accessKey, secretKey);
AmazonS3 s3client = AmazonS3ClientBuilder.standard().withCredentials(new AWSStaticCredentialsProvider(creds)).build();
```


 - 리전을 추가할 경우
```java
.withRegion(Regions.valueOf("AP_NORTHEAST_2"))
```


