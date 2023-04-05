

## 部分不再维护的脚本说明

### Docker服务管理（archived）

- [docker_manager](./local_bin/docker_manager)

方便一堆用Docker容器需要管理的场景<br>
配合cron使用


### Python虚拟环境快速切换（archived）

> 已经停止维护，请使用conda/pyenv/virtualenvwrapper

- [acpyve](./local_bin/acpyve)

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
