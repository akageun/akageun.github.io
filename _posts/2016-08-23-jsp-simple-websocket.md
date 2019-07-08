---
layout: post
title:  "websocket 사용 간단 채팅"
date:   2016-08-23 00:00:00 +0900
categories:
 - java
tags: 
 - websoket
---
# pom.xml
```xml
<!-- WebSocket -->
<dependency>
   <groupId>javax.websocket</groupId>
   <artifactId>javax.websocket-api</artifactId>
   <version>1.0</version>
   <scope>provided</scope>
</dependency>
```

# java source
```java
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Set;

@ServerEndpoint(value = "/websocket/chat/{clientId}")
public class ChatAnnotation {

   private static final Set<ChatAnnotation> connections = new CopyOnWriteArraySet<>();

   private String nickname;
   private Session session;

   @OnOpen
   public void start(@PathParam("clientId") String clientId, Session session) {
      this.nickname = clientId;
      this.session = session;
      connections.add(this);
   }

   @OnClose
   public void end() {
      connections.remove(this);
   }

   @OnMessage
   public void incoming(String message) {
      // Never trust the client
      String filteredMessage = String.format("%s: %s", nickname, message.toString());
      broadcast(filteredMessage);
   }

   @OnError
   public void onError(Throwable t) throws Throwable {
      //log.error("Chat Error: " + t.toString(), t);
   }

   private static void broadcast(String msg) {
      for (ChatAnnotation client : connections) {
         try {
            synchronized (client) {
               String message = "{clId:'" + client.nickname + "',msg:'" + msg + "'}";
               client.session.getBasicRemote().sendText(filter(message));
            }
         } catch (IOException e) {
            connections.remove(client);
            try {
               client.session.close();
            } catch (IOException e1) {
               // Ignore
            }
            String message = String.format("* %s %s", client.nickname, "has been disconnected.");
            broadcast(message);
         }
      }
   }

   private static String filter(String message) {

      if (message == null)
         return (null);

      char content[] = new char[message.length()];
      message.getChars(0, message.length(), content, 0);
      StringBuilder result = new StringBuilder(content.length + 50);
      for (int i = 0; i < content.length; i++) {
         switch (content[i]) {
            case '<':
               result.append("&lt;");
               break;
            case '>':
               result.append("&gt;");
               break;
            case '&':
               result.append("&amp;");
               break;
            case '"':
               result.append("&quot;");
               break;
            default:
               result.append(content[i]);
         }
      }
      return (result.toString());

   }
}
```

# jsp page
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<style type="text/css">
    .scrollup {
        position: fixed;
        bottom: 0px;
        right: 0px;
        z-index: 99999;
        text-align: right;
        padding-right: 10px;
    }
    .chat{
        list-style: none;
        margin: 0;
        padding: 0;
    }

    .chat li{
        margin-bottom: 10px;
        padding-bottom: 5px;
        border-bottom: 1px dotted #B3A9A9;
    }

    .chat li.left .chat-body{margin-left: 60px;}
    .chat li.right .chat-body{margin-right: 60px;}


    .chat li .chat-body p
    {
        margin: 0;
        color: #777777;
    }

    .panel .slidedown .glyphicon, .chat .glyphicon
    {
        margin-right: 5px;
    }

    .panel-body
    {
        overflow-y: scroll;
        height: 250px;
    }

    ::-webkit-scrollbar-track
    {
        -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
        background-color: #F5F5F5;
    }

    ::-webkit-scrollbar
    {
        width: 12px;
        background-color: #F5F5F5;
    }

    ::-webkit-scrollbar-thumb
    {
        -webkit-box-shadow: inset 0 0 6px rgba(0,0,0,.3);
        background-color: #555;
    }
</style>
<script type="text/javascript">
    var chat = {};
    chat.socket = null;
    chat.connect = (function(host) {
        if ('WebSocket' in window) {
            chat.socket = new WebSocket(host);
        } else if ('MozWebSocket' in window) {
            chat.socket = new MozWebSocket(host);
        } else {
            chatContent.append('Error: WebSocket is not supported by this browser.', 'left');
            return;
        }

        chat.socket.onopen = function () {
            chatContent.append('Info: WebSocket connection opened.', 'left');
            document.getElementById('chat').onkeydown = function(event) {
                if (event.keyCode == 13) {
                    chat.sendMessage();
                }
            };
        };

        chat.socket.onclose = function () {
            document.getElementById('chat').onkeydown = null;
            chatContent.append('Info: WebSocket closed.', 'left');
        };

        chat.socket.onmessage = function (message) {
            chatContent.append(message.data, 'right');
        };
    });
    chat.initialize = function() {
        if (window.location.protocol == 'http:') {
            //console.log(window.location.host);
            chat.connect('ws://' + window.location.host + '/websocket/chat/${login_empnm}');
        } else {
            chat.connect('wss://' + window.location.host + '/websocket/chat/${login_empnm}');
        }
    };

    chat.sendMessage = (function() {
        var message = document.getElementById('chat').value;
        if (message != '') {
            chat.socket.send(message);
            document.getElementById('chat').value = '';
        }
    });
    var chatContent = {};
    chatContent.append = (function(message,addClassNm){
        var chatContainer = document.getElementById('chat_li');
        var li = document.createElement('li');
        var span = document.createElement('span');
        span.style.wordWrap = 'break-word';


        console.log("msg : "+message);
        span.innerHTML = message;


        span.className = "pull-"+addClassNm
        li.appendChild(span);
        li.className = "clearfix ";
        li.className = li.className +" "+addClassNm;
        chatContainer.appendChild(li);

        document.getElementById('chat_body').scrollTop = document.getElementById('chat_body').scrollHeight;

        while (chatContainer.childNodes.length > 25) {
            chatContainer.removeChild(chatContainer.firstChild);
        }
    });

    chat.initialize();

    function chkMyMsg(msgJson){

    }
</script>
<div>
    <p>

    </p>
    <div id="console-container">
        <div id="console"></div>
    </div>
</div>


<div class="scrollup span4">
    <div class="row-fluid">
        <div class="box dark">
            <header>
                <h5>Chat</h5>
                <div class="toolTip">
                    <a class="btn btn-primary btn-small" data-toggle="collapse" data-parent="#accordion"
                       href="#collapseOne" style="margin-top: 5px; margin-right: 2px;">
                        Open
                    </a>
                </div>
            </header>
            <div class="body collapse" id="collapseOne">
                <div class="panel-body" id="chat_body">
                    <ul id="chat_li" class="chat"></ul>
                </div>
                <div>
                    <div class="input-group">
                        <input type="text" placeholder="type and press enter to chat" id="chat" >
                        <span class="input-group-btn">
                            <button class="btn btn-warning btn-sm" id="btn-chat">
                                Send</button>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
```

# 결과
![image](https://user-images.githubusercontent.com/13219787/60703995-2a6bb000-9f3e-11e9-983e-cb84b796a9ce.png)
