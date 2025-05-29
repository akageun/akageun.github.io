---
layout: post
title:  "[AI] Ollama 사용법"
date:   2025-05-29 09:00:00 +0900
categories:
- ai
tags:
- ollama
- open-webui
- llm
- chatbot
---
- [공식 홈페이지](https://ollama.com/)
- LLM 모델 등에 대해서 로컬에서 실행시켜주는 도구

## 사용해보기
- 공홈 또는 다양한 방법으로 다운로드 할 수 있다.

> brew install ollama

- 이후 사용하려는 모델을 지정하여 실행시킨다.
  - 해당 모델이 없을 경우 다운로드 된다.
  - 사용 가능한 모델은 https://ollama.com/search 에서 확인 할 수 있다.
> ollama run llama3.2:3b
- `help`
  - 어떤 명령어들을 실행할 수 있는지? 어떻게 이용 가능한지 알려준다.
  - `ollama help
```
Large language model runner

Usage:
  ollama [flags]
  ollama [command]

Available Commands:
  serve       Start ollama
  create      Create a model from a Modelfile
  show        Show information for a model
  run         Run a model
  stop        Stop a running model
  pull        Pull a model from a registry
  push        Push a model to a registry
  list        List models
  ps          List running models
  cp          Copy a model
  rm          Remove a model
  help        Help about any command

Flags:
  -h, --help      help for ollama
  -v, --version   Show version information
```
- `chat` 과 `generate` 의 기능
  - 입력한 내용에 대해서 텍스트를 생성에 대한 공통의 기능을 가지고 있습니다.
  - `chat` 은 이전 대화내용을 이용하여 다음 답변을 이어가는 형태로 텍스트를 생성합니다. (챗봇)
  - `generate` 의 경우 입력한 프롬프트에 대해서만 답변합니다.
- `list`
  - 설치된 모델 목록을 보여줍니다.
- `serve`
  - 서버를 시작합니다.
> ollama serve          # localhost:11434 가 열린다

## api 사용해보기
- https://github.com/ollama/ollama/blob/main/docs/api.md

### `generate API`
```java
   String baseUrl = "http://localhost:11434";

    public String generate(String model, String prompt) throws IOException, InterruptedException {
        GenerateRequest request = new GenerateRequest(model, prompt, false);
        String requestBody = objectMapper.writeValueAsString(request);

        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + "/api/generate"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .timeout(Duration.ofMinutes(5))
                .build();

        HttpResponse<String> response = httpClient.send(httpRequest, 
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            GenerateResponse generateResponse = objectMapper.readValue(
                    response.body(), GenerateResponse.class);
            return generateResponse.response;
        } else {
            throw new RuntimeException("Ollama API 호출 실패: " + response.statusCode() + 
                    " - " + response.body());
        }
    }
```

### `embeddings API`
```java
    // 임베딩 생성 메서드
    public double[] embeddings(String model, String prompt) throws IOException, InterruptedException {
        EmbeddingsRequest request = new EmbeddingsRequest(model, prompt);
        String requestBody = objectMapper.writeValueAsString(request);

        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + "/api/embeddings"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .timeout(Duration.ofMinutes(2))
                .build();

        HttpResponse<String> response = httpClient.send(httpRequest, 
                HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            EmbeddingsResponse embeddingsResponse = objectMapper.readValue(
                    response.body(), EmbeddingsResponse.class);
            return embeddingsResponse.embedding;
        } else {
            throw new RuntimeException("Ollama Embeddings API 호출 실패: " + response.statusCode() + 
                    " - " + response.body());
        }
    }
``` 

## ChatGPT처럼 사용하시려면 Open-WebUI
- https://github.com/open-webui/open-webui
- ollama 를 chatgpt 처럼 이용하려면 위 오픈소스를 활용한다면 빠르게 사용 가능함.

![image](/assets/postimage/img_2.png)
