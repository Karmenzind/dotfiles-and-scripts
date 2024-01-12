

## 部分不再维护的脚本说明

### YouCompleteMe编译安装

> 22年开始已经不再用YouCompleteMe，目前在Neovim中使用内置LSP和cmp相关插件，在Vim中使用coc。此处仅供参考

- [compile and install YouCompleteMe](./install_vim/ycm.sh) YouCompleteMe插件编译安装

[通过install.sh](#usage)**选择第四项单独安装YouCompleteMe插件**时，需要注意：
1.  阅读ycm.sh的开头部分
2.  修改ycm.sh中的ycm插件安装地址
3.  如果为Arch系统，直接选择任意一种方式安装；如果非Arch系统，选择`official way`可以直接安装，如果选择`my way`方式，需要手动安装python、cmake和clang，然后修改ycm.sh中的`libclang.so`地址

> `official way`是采用ycm自带安装脚本编译安装，`my way`是用我写的命令编译安装。如果用`my way`安装时`git clone`速度太慢，可以手动修改ycm.sh中的git repo地址（脚本注释中提供了国内源）

### Docker服务管理（archived）

- [docker_manager](./docker_manager)

方便一堆用Docker容器需要管理的场景<br>
配合cron使用


### Python虚拟环境快速切换（archived）

> 已经停止维护，请使用conda/pyenv/virtualenvwrapper

- [acpyve](./acpyve)

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
