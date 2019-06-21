---
layout: post
title:  "[Apache poi] 엑셀파일에 암호걸기"
date:   2018-07-13 00:00:00 +0900
categories:
 - java
tags: 
 - poi
 - excel
---

- 업무 중에 엑셀 다운로드 기능에 "암호 걸기"가 필요해짐.

# 1. pom.xml에 필요한 dependencyt 추가
```xml
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi</artifactId>
    <version>3.16</version>
</dependency>
```

# 2. 샘플
- 아래와 같이 설정해주면 잘 나온다.
```java
EncryptionInfo encryptionInfo = new EncryptionInfo(EncryptionMode.agile);
Encryptor encryptor = encryptionInfo.getEncryptor();
encryptor.confirmPassword(password);
```

- 결과

![image](https://user-images.githubusercontent.com/13219787/59898800-5f034600-942d-11e9-8720-fe49a6ff832d.png)

# 3. 전체소스
```java
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.openxml4j.opc.OPCPackage;
import org.apache.poi.poifs.crypt.EncryptionInfo;
import org.apache.poi.poifs.crypt.EncryptionMode;
import org.apache.poi.poifs.crypt.Encryptor;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.Test;

import java.io.*;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import java.util.List;

@Slf4j
public class ExcelTest {

   @Test
   public void 엑셀파일에_암호걸기() {
      final String password = "1234";
      final String savePath = "c:\\temp\\excel2.xlsx";

      List<String> tmpData = Arrays.asList("Java", "JavaScript", "Python", "GoLang");

      try (Workbook wb2 = new XSSFWorkbook();
         ByteArrayOutputStream fileOut = new ByteArrayOutputStream();
         FileOutputStream fos = new FileOutputStream(savePath);) {

         Sheet sheet1 = wb2.createSheet("Sheet1");

         //Write Excel File
         for (int i = 0; i < tmpData.size(); i++) {
            String data = tmpData.get(i);

            Row row = sheet1.createRow(i);
            Cell cell = row.createCell(0);

            cell.setCellValue(data);

         }

         wb2.write(fileOut);

         InputStream filein = new ByteArrayInputStream(fileOut.toByteArray());
         OPCPackage opc = OPCPackage.open(filein);

         POIFSFileSystem fileSystem = new POIFSFileSystem();

         EncryptionInfo encryptionInfo = new EncryptionInfo(EncryptionMode.agile);
         Encryptor encryptor = encryptionInfo.getEncryptor();
         encryptor.confirmPassword(password);

         opc.save(encryptor.getDataStream(fileSystem));
         fileSystem.writeFilesystem(fos);

         log.info("Create Excel File!!");

      } catch (IOException e) {
         log.error(e.getMessage(), e);

      } catch (InvalidFormatException e) {
         log.error(e.getMessage(), e);

      } catch (GeneralSecurityException e) {
         log.error(e.getMessage(), e);
      }

   }

}
```