一些自己的脚本

#### `acpyve` 激活Python虚拟环境

方便一堆虚拟环境需要切换的场景<br>

Usage:
在脚本或环境变量中设置虚拟环境存放目录，然后
```bash
k 16:04:00 > ~ $ . acpyve
Pick one virtual environment to activate:

1  General_Py2
2  General_Py3

Input number: 2

Activating General_Py3...
/home/k

DONE :)

(General_Py3) k 16:04:16 > ~
$ 

```

#### `myaria2` 下载工具aria2管理脚本

- 启动、重启、停止、查看运行状态、查看日志
- 更新bt-tracker（从ngosang/trackerslist获取）。启动、重启时，配置周期触发更新，也可以通过`myaria2 update`主动更新
- 转存旧日志
- 其他一些简单功能

结合cron使用
配置项见脚本注释

Reference:
-   [trackerslist](https://github.com/ngosang/trackerslist)
-   [解决Aria2 BT下载速度慢没速度的问题](http://www.senra.me/solutions-to-aria2-bt-metalink-download-slowly/)
-   [配置详解](http://www.senra.me/aria2-conf-file-parameters-translation-and-explanation/)
-   [AriaNG——高颜值的Aria2 WebUI](http://www.senra.me/ariang-a-beautiful-aria2-webui-front-end/)
-   [Aria2+Plex实现支持离线下载的小型私人视频云盘](http://www.senra.me/aria2-and-plex-build-your-own-cloud-video-streaming-service/)
-   [下载工具系列——Aria2 (几乎全能的下载神器)](http://www.senra.me/awesome-downloader-series-aria2-almost-the-best-all-platform-downloader/)
-   [下载神器——Aria2，打造你自己的离线下载服务器](http://www.senra.me/download-artifact-aria2-create-your-own-offline-download-server/)

#### `docker_manager` 本地Docker服务项目管理

方便一堆用Docker容器需要管理的场景<br>
配合cron使用

