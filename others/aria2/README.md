下载工具

管理脚本myaria2

目前简陋了点，可以一条命令实现：
- 更新bt-tracker（从ngosang/trackerslist获取）。原理参考了解决Aria2 BT下载速度慢没速度的问题。启动、重启时，如果距离上次更新超过四小时（可配置），会触发更新，也可以通过命令主动更新
- 启动、重启、停止、查看运行状态、查看日志

被动功能（可配置）包括：
- 转存旧日志，方便DEBUG
- 运行命令时打开浏览器管理页面

暂时就这些了……
配置项见脚本注释
欢迎反馈


TODO:
-   脚本：自动同步trackerlist并写入配置、重启
-   脚本：定时唤醒硬盘同步文件

*reference*:
-   [trackerslist](https://github.com/ngosang/trackerslist)
-   [解决Aria2 BT下载速度慢没速度的问题](http://www.senra.me/solutions-to-aria2-bt-metalink-download-slowly/)
-   [配置详解](http://www.senra.me/aria2-conf-file-parameters-translation-and-explanation/)
-   [AriaNG——高颜值的Aria2 WebUI](http://www.senra.me/ariang-a-beautiful-aria2-webui-front-end/)
-   [Aria2+Plex实现支持离线下载的小型私人视频云盘](http://www.senra.me/aria2-and-plex-build-your-own-cloud-video-streaming-service/)
-   [下载工具系列——Aria2 (几乎全能的下载神器)](http://www.senra.me/awesome-downloader-series-aria2-almost-the-best-all-platform-downloader/)
-   [下载神器——Aria2，打造你自己的离线下载服务器](http://www.senra.me/download-artifact-aria2-create-your-own-offline-download-server/)

