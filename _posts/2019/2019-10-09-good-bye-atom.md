---
layout: post
title:  "Good Bye ATOM!! "
date:   2019-10-09 09:00:00 +0900
categories:
 - mac
tags: 
 - atom
 - tools
---

- atom 을 사용하다보면, 하나씩 plugin 을 설치하게되고, 그러다보면 굉장히 무거워진다.
- 답답해서 vsCode 로 넘어갔는데, 굉장히 쾌적함을 느끼고 사용하고 있다.
- 기존에 사용하던 atom 에 대한 모든 정보를 지워버리고 싶었음.....

```
rm -rf ~/.atom
rm -rf /usr/local/bin/atom
rm -rf /usr/local/bin/apm
rm -rf /Applications/Atom.app
rm -rf ~/Library/Preferences/com.github.atom.plist
rm -rf "~/Library/Application Support/com.github.atom.ShipIt"
rm -rf "~/Library/Application Support/Atom"
rm -rf "~/Library/Saved Application State/com.github.atom.savedState"
rm -rf ~/Library/Caches/com.github.atom
rm -rf ~/Library/Caches/Atom
```

---
## 참고링크
- https://discuss.atom.io/t/how-do-i-uninstall-atom-on-macos/56064
