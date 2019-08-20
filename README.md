# dotfiles and scripts 

> ArchLinux安装脚本[已经迁移至此处](https://github.com/Karmenzind/arch-installation-scripts)，暂不再维护

创建这个repo是为了减少重复工作，内容包含：
1.  系统/软件配置，如Vim、i3wm、tmux等
2.  安装脚本
    *   软件编译/安装脚本，如Vim-YCM插件
3.  工具脚本
    *   工具脚本，如Docker、Aria2管理

## TOC

<!-- vim-markdown-toc GFM -->

* [用法简述](#用法简述)
    * [所有配置文件和工具脚本](#所有配置文件和工具脚本)
    * [使用我的Vim配置](#使用我的vim配置)
    * [安装常用软件（仅供ArchLinux）](#安装常用软件仅供archlinux)
* [配置文件目录](#配置文件目录)
* [安装脚本部分](#安装脚本部分)
    * [软件批量安装](#软件批量安装)
    * [Vim及插件安装](#vim及插件安装)
    * [YouCompleteMe编译安装](#youcompleteme编译安装)
    * [Vim插件涉及依赖安装](#vim插件涉及依赖安装)
* [工具脚本部分](#工具脚本部分)
    * [Python虚拟环境快速切换](#python虚拟环境快速切换)
    * [Aria2管理&自动更新bt-tracker](#aria2管理自动更新bt-tracker)
    * [本地Docker服务项目管理](#本地docker服务项目管理)
* [效果截图](#效果截图)
* [创建你自己的DotFile仓库](#创建你自己的dotfile仓库)
* [文件目录](#文件目录)

<!-- vim-markdown-toc -->

## 用法简述

通过以下方式，可以快速使用我的配置文件

### 所有配置文件和工具脚本

通过以下命令来一键安装我所有的配置文件（支持交互模式选择）。[配置文件结构见下文](#配置文件目录)。

这里提供两种方式：

**创建软连接（推荐）**

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts --depth=1
cd ./dotfiles-and-scripts
python3 symlink.py
```

**复制文件**

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts --depth=1
cd ./dotfiles-and-scripts
python3 do_synch.py apply
```

如果你想创建一个自己的dotfile仓库，[参考下文](#创建你自己的dotfile仓库)

### 使用我的Vim配置

如果只需要我的[Vim配置](./home_k/.vimrc)，Unix环境直接运行以下命令，等待自动安装完成
```bash
wget https://raw.githubusercontent.com/Karmenzind/dotfiles-and-scripts/master/home_k/.vimrc -O ~/.vimrc && vim 
```
也可以用[脚本安装](#vim及插件安装)

> 使用**root用户**安装我的配置可能会出问题。我不喜欢给root用户单独配置，采用的做法是在`/root`目录下创建`.vimrc`和`.vim`的软链接，与普通用户共用一套配置，供参考。如果要**直接**给root用户安装配置，请自行研究解决方案。


### 安装常用软件（仅供ArchLinux）

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts --depth=1
bash ./install.sh
```

然后选择第一项。

## 配置文件目录

文件跳转目录，[为避免杂乱，挪到底部](#文件目录)

> 我使用的字体: [Monaco Nerd](https://github.com/Karmenzind/monaco-nerd-fonts)

## 安装脚本部分

### 软件批量安装

- [install_apps.sh](./scripts/install_apps.sh)

`_fonts`数组中包含了ArchWiki中推荐的所有中文环境所需字体（不含AUR）

1. 自行修改脚本，根据需要添加、删除软件
2. 从install.sh进入选择`install recommended apps`

### Vim及插件安装

Vim比较特殊，尤其是YCM经常安装失败，所以单独列出来

用脚本安装Vim和插件：
- [complete installation](./scripts/install_vim/main.sh) 直接按照我的Vim配置一键安装Vim和各种插件，无需其他配置

如果你已经安装了Vim，需要直接使用我的配置&插件，除了上面的脚本安装外，更简单的方法为直接执行[Usage](#usage)中提到的命令

### YouCompleteMe编译安装

- [compile and install YouCompleteMe](./scripts/install_vim/ycm.sh) YouCompleteMe插件编译安装

[通过install.sh](#usage)**选择第四项单独安装YouCompleteMe插件**时，需要注意：
1.  阅读ycm.sh的开头部分
2.  修改ycm.sh中的ycm插件安装地址
3.  如果为Arch系统，直接选择任意一种方式安装；如果非Arch系统，选择`official way`可以直接安装，如果选择`my way`方式，需要手动安装python、cmake和clang，然后修改ycm.sh中的`libclang.so`地址

> `official way`是采用ycm自带安装脚本编译安装，`my way`是用我写的命令编译安装。如果用`my way`安装时`git clone`速度太慢，可以手动修改ycm.sh中的git repo地址（脚本注释中提供了国内源）

### Vim插件涉及依赖安装

部分插件依赖外部工具（比如`fzf`、`ctags`、`ag`等）。按照上述步骤安装Vim以及插件之后，打开Vim，在命令行模式运行：
```
# 依赖系统中的`pip`和`npm`，需自行安装
call InstallRequirements()
```
安装过程中注意观察窗口日志提示。

## 工具脚本部分

### Python虚拟环境快速切换

> 已经停止维护，请使用virtualenvwrapper

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

### Aria2管理&自动更新bt-tracker

- [myaria2](./local_bin/myaria2)

功能：
- 启动、重启、停止、查看运行状态、查看日志
- 更新bt-tracker（从ngosang/trackerslist获取）。启动、重启时，配置周期触发更新，也可以通过`myaria2 update`主动更新
- 转存旧日志
- 其他一些简单功能

结合cron使用
配置项见脚本注释

### 本地Docker服务项目管理

- [docker_manager](./local_bin/docker_manager)

方便一堆用Docker容器需要管理的场景<br>
配合cron使用


## 效果截图

- i3 desktop:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/float.png)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/desktop.png)

- Vim:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim.png)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim_goyo.png)

## 创建你自己的DotFile仓库

以下两个脚本用来在系统中直接应用本repo中的配置文件

- [symlink.py](./symlink.py) 以创建软连接的方式（推荐）
- [do_synch.py](./do_synch.py) 以复制（支持双向）的方式来更新、应用配置文件

你可以fork这个项目，然后借助上述两种方式来同步你自己的配置文件

## 文件目录

> trees are generated by [this script](./utils/build_trees.sh)

- [home](./home_k)
	- [.agignore](./home_k/.agignore)
	- [.config](./home_k/.config)
		- [alacritty](./home_k/.config/alacritty)
			- [alacritty.yml](./home_k/.config/alacritty/alacritty.yml)
		- [aria2](./home_k/.config/aria2)
			- [aria2.conf](./home_k/.config/aria2/aria2.conf)
			- [README.md](./home_k/.config/aria2/README.md)
		- [compton.conf](./home_k/.config/compton.conf)
		- [conky](./home_k/.config/conky)
			- [conky.conf](./home_k/.config/conky/conky.conf)
		- [dunst](./home_k/.config/dunst)
			- [dunstrc](./home_k/.config/dunst/dunstrc)
		- [fcitx](./home_k/.config/fcitx)
			- [data](./home_k/.config/fcitx/data)
				- [punc.mb.zh_CN](./home_k/.config/fcitx/data/punc.mb.zh_CN)
				- [README.md](./home_k/.config/fcitx/data/README.md)
		- [fontconfig](./home_k/.config/fontconfig)
			- [fonts.conf_bak](./home_k/.config/fontconfig/fonts.conf_bak)
			- [fonts.conf_bak2](./home_k/.config/fontconfig/fonts.conf_bak2)
		- [i3](./home_k/.config/i3)
			- [config](./home_k/.config/i3/config)
			- [conky_status.sh](./home_k/.config/i3/conky_status.sh)
			- [run_oneko.sh](./home_k/.config/i3/run_oneko.sh)
			- [screenshot.sh](./home_k/.config/i3/screenshot.sh)
		- [isort.cfg](./home_k/.config/isort.cfg)
		- [mypy](./home_k/.config/mypy)
			- [config](./home_k/.config/mypy/config)
		- [nvim](./home_k/.config/nvim)
			- [init.vim](./home_k/.config/nvim/init.vim)
		- [pylintrc](./home_k/.config/pylintrc)
		- [rofi](./home_k/.config/rofi)
			- [config](./home_k/.config/rofi/config)
		- [shrc.ext](./home_k/.config/shrc.ext)
		- [volumeicon](./home_k/.config/volumeicon)
			- [volumeicon](./home_k/.config/volumeicon/volumeicon)
		- [xfce4](./home_k/.config/xfce4)
			- [terminal](./home_k/.config/xfce4/terminal)
				- [terminalrc](./home_k/.config/xfce4/terminal/terminalrc)
	- [.eslintrc.js](./home_k/.eslintrc.js)
	- [README.md](./home_k/README.md)
	- [.stylelintrc](./home_k/.stylelintrc)
	- [.tmux.conf](./home_k/.tmux.conf)
	- [.tmuxinator](./home_k/.tmuxinator)
		- [k.yml](./home_k/.tmuxinator/k.yml)
	- [.vim](./home_k/.vim)
		- [mysnippets](./home_k/.vim/mysnippets)
			- [all.snippets](./home_k/.vim/mysnippets/all.snippets)
			- [django.snippets](./home_k/.vim/mysnippets/django.snippets)
			- [markdown.snippets](./home_k/.vim/mysnippets/markdown.snippets)
			- [python.snippets](./home_k/.vim/mysnippets/python.snippets)
			- [sh.snippets](./home_k/.vim/mysnippets/sh.snippets)
	- [.vimrc](./home_k/.vimrc)
		- [.ycm_extra_conf.py](./home_k/.vim/.ycm_extra_conf.py)
	- [.xinitrc](./home_k/.xinitrc)
	- [.Xresources](./home_k/.Xresources)
	- [.zshrc](./home_k/.zshrc)
