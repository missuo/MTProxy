<!--
 * @Author: Vincent Young
 * @Date: 2022-07-01 15:29:23
 * @LastEditors: Vincent Young
 * @LastEditTime: 2022-07-30 19:28:49
 * @FilePath: /MTProxy/README.md
 * @Telegram: https://t.me/missuo
 * 
 * Copyright © 2022 by Vincent, All Rights Reserved. 
-->
# MTProxy
Highly-opinionated (ex-bullshit-free) MTPROTO proxy for [Telegram](https://telegram.org).

## Intro
**If you have used MTProxy before, you must be using Version 1. At present, the scripts on the Internet are basically Version 1. And my script uses the new Version 2.**

### Differences between v1 and v2
- Configuration file incompatibility
- v2 completely removes TAG
- FakeTLS encryption is used in v2

### Updates
#### July 30th, 2022
- Support for modifying the listening port
- Support for modifying secret
- Support for updating to latest version of MTProxy

#### July 1st, 2022
- Add subscription config
- Add subscription link

## Supportability
- X86_64
- ARM_64

## Installation
**This script uses the latest release of [9seconds/mtg](https://github.com/9seconds/mtg) by default**
~~~shell
bash <(curl -Ls https://cpp.li/mtg)
~~~
**Due to the CDN cache, jsdelivr link may not be the latest.**
~~~shell
bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/MTProxy/mtproxy.sh)
~~~

## TO DO (Implemented)
- ~~Support for updating MTProxy~~
- ~~Support to modify the configuration~~

## Bug Feedback
[Issue](https://github.com/missuo/MTProxy/issues/new)

## Open Source Used
[9seconds/mtg](https://github.com/9seconds/mtg)

## LICENSE
[MIT](https://github.com/missuo/MTProxy/blob/main/LICENSE)


