---
layout: post
title:  "Java로 배워보는 BlockChain"
date:   2018-05-02 09:00:00 +0900
categories:
 - java
tags: 
 - java
 - blockchain
---

- 해당 내용은 공부하면서 간단하게 만들어본 블록체인 입니다.

# 1. Block 만들기
- BlockChain을 구성하는 Block 을 생성한다,
- Block은 BlockChain 내에서 고유한 Hash(Digital Signature)값을 가지고 있다.
- Block 내에는 이전 Block의 Hash 값과 데이터들이 포함되어 있다.

## 1) 소스코드
```java
package kr.geun.o.bc.basic;

import java.util.Date;

/**
 * Block Class
 *
 * @author akageun
 */
public class Block {

   private String hash;
   private String previousHash;

   private String data;
   private long timeStamp;

   private Block() {

   }

   /**
    * Block Constructor
    *
    * @param data
    * @param previousHash
    */
   public Block(String data, String previousHash) {
      this.data = data;
      this.previousHash = previousHash;

      this.timeStamp = new Date().getTime();
   }

   /**
    * get previousHash
    *
    * @return
    */
   public String getPreviousHash() {
      return previousHash;
   }

   /**
    * get Hash
    *  - digital signature
    *
    * @return
    */
   public String getHash() {
      return hash;
   }

   /**
    * get TimeStamp
    *
    * @return
    */
   public long getTimeStamp() {
      return timeStamp;
   }

   /**
    * get Data
    *
    * @return
    */
   public String getData() {
      return data;
   }
}

```

# 2. Hash(Digital Signature) 생성 메소드 만들기
- Sha256을 사용.

```java
package kr.geun.o.bc.basic;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * BlockChain Utils
 *
 * @author akageun
 */
public class BcUtils {

   /**
    * Hash 생성
    *
    * @param inputValues
    * @return
    */
   public static String generateHash(String... inputValues) {
      try {
         StringBuffer sb = new StringBuffer();
         for (String inputValue : inputValues) {
            sb.append(inputValue);
         }

         String input = sb.toString();

         MessageDigest digest = MessageDigest.getInstance("SHA-256");

         byte[] hash = digest.digest(input.getBytes("UTF-8"));
         StringBuffer hexString = new StringBuffer();

         for (int i = 0; i < hash.length; i++) {
            String hex = Integer.toHexString(0xff & hash[i]);
            if (hex.length() == 1) {
               hexString.append('0');
            }

            hexString.append(hex);
         }
         return hexString.toString();

      } catch (NoSuchAlgorithmException e) {
         e.printStackTrace();
         throw new RuntimeException(e);

      } catch (UnsupportedEncodingException e) {
         e.printStackTrace();
         throw new RuntimeException(e);
      }
   }
}

```

# 3. Hash 계산로직 추가.
- 위 BcUtils 를 이용하여 Block 안 Hash값을 만드는 로직을 추가해보자.
- Block 내 메소드 추가(소스코드)

```java
/**
 * Hash값 계산하기!
 *
 * @return
 */
public String calculateHash() {
   return BcUtils.generateHash(previousHash, Long.toString(timeStamp), data);
}
```

- 생성자 내에 해당 메소드 호출 추가

```java
/**
 * Block Constructor
 *
 * @param data
 * @param previousHash
 */
public Block(String data, String previousHash) {
   this.data = data;
   this.previousHash = previousHash;

   this.timeStamp = new Date().getTime();
   this.hash = calculateHash(); //추가!!
}
```

# 4. Genesis Block 호출하기!
- 첫번째 블럭 생성

```java
Block genesisBlock = new Block("이건 Genesis Block 입니다.", "0");
System.out.println("Genesis Block Hash : " + genesisBlock.getHash());
```

- 메인 메소드를 만들어 호출하면 아래와 같은 결과를 얻을 수 있다.(호출할 때마다 Hash값이 달라진다.)

> Genesis Block Hash : f57e2c72feba62234118d1356799c367a802c342156a43ac2774698bb316941e

- 몇개를 더 추가해서 출력해보면.... 아래와 같다.

```java
Block genesisBlock = new Block("이건 Genesis Block 입니다.", "0");
System.out.println("Genesis Block Hash : " + genesisBlock.getHash());

Block secBlock = new Block("이건 두번째 블럭 입니다.", genesisBlock.getHash());
System.out.println("Second Block Hash : " + secBlock.getHash());

Block thirdBlock = new Block("이건 세번째 블럭 입니다.", secBlock.getHash());
System.out.println("Hash for block 3 : " + thirdBlock.getHash());
```

> Genesis Block Hash : f57e2c72feba62234118d1356799c367a802c342156a43ac2774698bb316941e
> Second Block Hash : 082902f4d78eab658b964d9743532178073da2b9d529b00752fa5588034fb2a2
> Hash for block 3 : 97a821109da7ed12fc3263452670d42b392d71772dd70b81720a23e1d898bf15

# 5. 블록체인 만들기.
- 간단하게 static List를 만들어서 블럭들을 생성해 보자.

```java
/**
 * BlockChain 메인 클래스
 *
 * @author akageun
 */
public class BlockChain {

   public static List<Block> BLOCK_CHAIN = new LinkedList<>();

   public static void main(String[] args) {

      BLOCK_CHAIN.add(new Block("이건 Genesis Block 입니다.", "0"));
      BLOCK_CHAIN.add(new Block("이건 두번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
      BLOCK_CHAIN.add(new Block("이건 세번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));

      for (Block block : BLOCK_CHAIN) {
         System.out.println("=========");

         System.out.println("hash : " + block.getHash());
         System.out.println("previousHash : " + block.getPreviousHash());
         System.out.println("timeStamp : " + block.getTimeStamp());
         System.out.println("Data : " + block.getData());
      }

      System.out.println("=========");
   }

}

```

- 결과
```

=========

hash : 0f7e40c1f99be348a2a600f678ef6e64136d4ea6dc3d7457561e572129c628c9

previousHash : 0

timeStamp : 1532238023070

Data : 이건 Genesis Block 입니다.

=========

hash : b3a2226d4dafb77bfca41c2d792e7590df544e34450bfd5ecd69e71124f6baea

previousHash : 0f7e40c1f99be348a2a600f678ef6e64136d4ea6dc3d7457561e572129c628c9

timeStamp : 1532238023086

Data : 이건 두번째 블럭 입니다.

=========

hash : 57caa0507cbed37fbde89a4d80b2ea68450cff3698fba56856858093d8ac6982

previousHash : b3a2226d4dafb77bfca41c2d792e7590df544e34450bfd5ecd69e71124f6baea

timeStamp : 1532238023086

Data : 이건 세번째 블럭 입니다.
```

# 6. 무결성 검사
- 계산한 Hash값이 같은지, Block 내 PreviousBlock 과 실제 이전 블럭 Hash값이 같은지를 검증하는 로직
- 구현 소스

```java
/**
 * 블록 검증
 *
 *
 * @return
 */
private static boolean isValidBlockChain() {
   Block currentBlock;
   Block previousBlock;

   for (int i = 1; i < BLOCK_CHAIN.size(); i++) { //GenesisBlock 은 제외한다.
      currentBlock = BLOCK_CHAIN.get(i);
      previousBlock = BLOCK_CHAIN.get(i - 1);

      if (currentBlock.getHash().equals(currentBlock.calculateHash()) == false) { //만들어 놓은 Hash값과 계산한 Hash값이 같은지 검증!
         System.out.println("Not Equals Current Block Hash!!");
         return false;
      }

      if (currentBlock.getPreviousHash().equals(previousBlock.getHash()) == false) {
         System.out.println("Not Equals Previous Block Hash!!");
         return false;
      }

   }

   return true;
}

```

# 7. 채굴!(마이닝)
- 작업증명'(Proof-of-Work) : BlockChain의 Block Hash는 `Difficulty`에 따라 선택된  Target 데이터 규격을 만족해야 한다.
- Block Class 수정( nonce 값 추가)

```java
private int nonce;

/**
 * get nonce
 * 
 * @return
 */
public int getNonce() {
   return nonce;
}
  - Hash 값 연산하는 부분에 nonce 값 추가

/**
 * Hash값 계산하기!
 *
 * @return
 */
public String calculateHash() {
   return BcUtils.generateHash(previousHash, Long.toString(timeStamp), Integer.toString(nonce) , data);
}
  - 채굴 함수 추가

/**
 * Mining
 */
public void mineBlock() {
   char[] targetChar = new char[BlockChain.DIFFICULTY];
   Arrays.fill(targetChar, '0');
   String target = String.valueOf(targetChar);

   while (hash.substring(0, BlockChain.DIFFICULTY).equals(target) == false) {
      nonce++;
      hash = calculateHash();
   }

   System.out.println("Block Mined!!! : " + hash);
}

```

- 난이도 추가

> public static int DIFFICULTY = 5;

- 무결성 검증 코드 내 로직 추가

```java
if (currentBlock.getHash().substring(0, DIFFICULTY).equals(hashTarget) == false) {
   System.out.println("This block hasn't been mined");
   return false;
}
```

- 채굴해보기

```java
BLOCK_CHAIN.add(new Block("이건 Genesis Block 입니다.", "0"));
BLOCK_CHAIN.get(0).mineBlock();

BLOCK_CHAIN.add(new Block("이건 두번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
BLOCK_CHAIN.get(1).mineBlock();

BLOCK_CHAIN.add(new Block("이건 세번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
BLOCK_CHAIN.get(2).mineBlock();

BLOCK_CHAIN.add(new Block("이건 네번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
BLOCK_CHAIN.get(3).mineBlock();

```

 - 결과

```java

Block Mined!!! : 00000fdd8a35c69f5925051899635e1704af98bdd7da3504ed9bc36b5be30901

Block Mined!!! : 00000d8e9a9e735e8f7cbdae41458379ab8b4ac3de7826671eb10f2b7def35bd

Block Mined!!! : 000005dd4dc19710d82dda43d230ec6eabc8041af0fc0a489279802d172f8d41

Block Mined!!! : 000006ff67b1e5735d8891e3e389620f541aa3467e73471a4e2d7b11f841ed3a

=========

hash : 00000fdd8a35c69f5925051899635e1704af98bdd7da3504ed9bc36b5be30901

previousHash : 0

timeStamp : 1532240373740

Data : 이건 Genesis Block 입니다.

nonce : 465518

=========

hash : 00000d8e9a9e735e8f7cbdae41458379ab8b4ac3de7826671eb10f2b7def35bd

previousHash : 00000fdd8a35c69f5925051899635e1704af98bdd7da3504ed9bc36b5be30901

timeStamp : 1532240374917

Data : 이건 두번째 블럭 입니다.

nonce : 1603790

=========

hash : 000005dd4dc19710d82dda43d230ec6eabc8041af0fc0a489279802d172f8d41

previousHash : 00000d8e9a9e735e8f7cbdae41458379ab8b4ac3de7826671eb10f2b7def35bd

timeStamp : 1532240378568

Data : 이건 세번째 블럭 입니다.

nonce : 2130959

=========

hash : 000006ff67b1e5735d8891e3e389620f541aa3467e73471a4e2d7b11f841ed3a

previousHash : 000005dd4dc19710d82dda43d230ec6eabc8041af0fc0a489279802d172f8d41

timeStamp : 1532240383239

Data : 이건 네번째 블럭 입니다.

nonce : 504539

=========

This Blockchain is Valid : true


```

# 전체소스

## 1. Block 소스

```java

package kr.geun.o.bc.basic;

import java.util.Arrays;
import java.util.Date;

/**
 * Block Class
 *
 * @author akageun
 */
public class Block {

   private String hash;
   private String previousHash;

   private String data;
   private long timeStamp;

   private int nonce;

   private Block() {

   }

   /**
    * Block Constructor
    *
    * @param data
    * @param previousHash
    */
   public Block(String data, String previousHash) {
      this.data = data;
      this.previousHash = previousHash;

      this.timeStamp = new Date().getTime();
      this.hash = calculateHash();
   }

   /**
    * Hash값 계산하기!
    *
    * @return
    */
   public String calculateHash() {
      return BcUtils.generateHash(previousHash, Long.toString(timeStamp), Integer.toString(nonce), data);
   }

   /**
    * Mining
    */
   public void mineBlock() {
      char[] targetChar = new char[BlockChain.DIFFICULTY];
      Arrays.fill(targetChar, '0');
      String target = String.valueOf(targetChar);

      while (hash.substring(0, BlockChain.DIFFICULTY).equals(target) == false) {
         nonce++;
         hash = calculateHash();
      }

      System.out.println("Block Mined!!! : " + hash);
   }

   /**
    * get previousHash
    *
    * @return
    */
   public String getPreviousHash() {
      return previousHash;
   }

   /**
    * get Hash
    *  - digital signature
    *
    * @return
    */
   public String getHash() {
      return hash;
   }

   /**
    * get TimeStamp
    *
    * @return
    */
   public long getTimeStamp() {
      return timeStamp;
   }

   /**
    * get Data
    *
    * @return
    */
   public String getData() {
      return data;
   }

   /**
    * get nonce
    *
    * @return
    */
   public int getNonce() {
      return nonce;
   }
}

```

## 2. BcUtils

```java
package kr.geun.o.bc.basic;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * BlockChain Utils
 *
 * @author akageun
 */
public class BcUtils {

   /**
    * Hash 생성
    *
    * @param inputValues
    * @return
    */
   public static String generateHash(String... inputValues) {
      try {
         StringBuffer sb = new StringBuffer();
         for (String inputValue : inputValues) {
            sb.append(inputValue);
         }

         String input = sb.toString();

         MessageDigest digest = MessageDigest.getInstance("SHA-256");

         byte[] hash = digest.digest(input.getBytes("UTF-8"));
         StringBuffer hexString = new StringBuffer();

         for (int i = 0; i < hash.length; i++) {
            String hex = Integer.toHexString(0xff & hash[i]);
            if (hex.length() == 1) {
               hexString.append('0');
            }

            hexString.append(hex);
         }
         return hexString.toString();

      } catch (NoSuchAlgorithmException e) {
         e.printStackTrace();
         throw new RuntimeException(e);

      } catch (UnsupportedEncodingException e) {
         e.printStackTrace();
         throw new RuntimeException(e);
      }
   }
}
```

## 3. BlockChain

```java

package kr.geun.o.bc.basic;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * BlockChain 메인 클래스
 *
 * @author akageun
 */
public class BlockChain {

   public static List<Block> BLOCK_CHAIN = new LinkedList<>();

   public static int DIFFICULTY = 5;

   public static void main(String[] args) {

      BLOCK_CHAIN.add(new Block("이건 Genesis Block 입니다.", "0"));
      BLOCK_CHAIN.get(0).mineBlock();

      BLOCK_CHAIN.add(new Block("이건 두번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
      BLOCK_CHAIN.get(1).mineBlock();

      BLOCK_CHAIN.add(new Block("이건 세번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
      BLOCK_CHAIN.get(2).mineBlock();

      BLOCK_CHAIN.add(new Block("이건 네번째 블럭 입니다.", BLOCK_CHAIN.get(BLOCK_CHAIN.size() - 1).getHash()));
      BLOCK_CHAIN.get(3).mineBlock();

      for (Block block : BLOCK_CHAIN) {
         System.out.println("=========");

         System.out.println("hash : " + block.getHash());
         System.out.println("previousHash : " + block.getPreviousHash());
         System.out.println("timeStamp : " + block.getTimeStamp());
         System.out.println("Data : " + block.getData());
         System.out.println("nonce : " + block.getNonce());
      }

      System.out.println("=========");

      System.out.println("This Blockchain is Valid : " + isValidBlockChain());

   }

   /**
    * 블록 검증
    *
    *
    * @return
    */
   private static boolean isValidBlockChain() {
      Block currentBlock;
      Block previousBlock;

      char[] target = new char[BlockChain.DIFFICULTY];
      Arrays.fill(target, '0');

      String hashTarget = String.valueOf(target);

      for (int i = 1; i < BLOCK_CHAIN.size(); i++) { //GenesisBlock 은 제외한다.
         currentBlock = BLOCK_CHAIN.get(i);
         previousBlock = BLOCK_CHAIN.get(i - 1);

         if (currentBlock.getHash().equals(currentBlock.calculateHash()) == false) { //만들어 놓은 Hash값과 계산한 Hash값이 같은지 검증!
            System.out.println("Not Equals Current Block Hash!!");
            return false;
         }

         if (currentBlock.getPreviousHash().equals(previousBlock.getHash()) == false) {
            System.out.println("Not Equals Previous Block Hash!!");
            return false;
         }

         if (currentBlock.getHash().substring(0, DIFFICULTY).equals(hashTarget) == false) {
            System.out.println("This block hasn't been mined");
            return false;
         }

      }

      return true;
   }
}

```

---

## 참고 페이지
- https://medium.com/programmers-blockchain/create-simple-blockchain-java-tutorial-from-scratch-6eeed3cb03fa
- http://guruble.com/java-%EC%BD%94%EB%93%9C%EB%A1%9C-%EC%9D%B4%ED%95%B4%ED%95%98%EB%8A%94-%EB%B8%94%EB%A1%9D%EC%B2%B4%EC%9D%B8blockchain/
