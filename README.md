# 🐝 dotfiles and scripts 

> ArchLinux一键安装脚本[已经迁移至此处](https://github.com/Karmenzind/arch-installation-scripts)，不再维护

<!-- 1.  配置文件 -->
<!--     * i3wm、Tmux、ZSH和各种系统/开发工具 -->
<!--     * Vim/NeoVim两套打磨多年的配置，内部插件有诸多差异但主要行为和快捷键基本一致，主要供日常Python/Golang开发和VimL/Lua/Bash脚本语言编写 --> <!-- 2.  安装脚本 -->
<!--     *   ArchLinux软件批量安装 -->
<!--     *   软件编译/安装脚本，如Vim-YCM插件 -->
<!-- 3.  工具脚本，如Aria2管理等 -->

<table cellspacing="0" border="0">
	<colgroup width="100"></colgroup>
	<!-- <colgroup width="1025"></colgroup> -->
    <tr>
        <td rowspan=2 align="center" valign=middle>配置文件</td>
        <td>i3wm、Tmux、ZSH和各种系统/开发工具</td>
    </tr>
    <tr>
        <td>Vim/NeoVim两套打磨多年的配置，内部插件有诸多差异但主要行为和快捷键基本一致，主要供日常Python/Golang开发和VimL/Lua/Bash脚本语言编写</td>
    </tr>
    <tr>
        <td rowspan=2 align="center" valign=middle>自用脚本</td>
        <td>工具类：Aria2管理；拉取国内广告屏蔽列表；部分特殊软件自动更新等</td>
    </tr>
    <tr>
        <td>配置类：一键应用本仓库配置；Arch软件批量安装脚本</td>
    </tr>
</table>


> 查看[文件目录树](./TREE.md)

## TOC

<!-- vim-markdown-toc GFM -->

* [🔶 成分介绍](#-成分介绍)
* [🎨 用法简述](#-用法简述)
    * [一键应用所有配置](#一键应用所有配置)
    * [只要(Neo)Vim配置](#只要neovim配置)
    * [安装常用软件（仅ArchLinux）](#安装常用软件仅archlinux)
* [⚙️ 安装脚本部分](#-安装脚本部分)
    * [软件批量安装](#软件批量安装)
    * [Vim及插件安装](#vim及插件安装)
        * [YouCompleteMe编译安装](#youcompleteme编译安装)
        * [Vim插件涉及依赖安装](#vim插件涉及依赖安装)
* [🔌 工具脚本部分](#-工具脚本部分)
    * [Aria2管理&自动更新bt-tracker](#aria2管理自动更新bt-tracker)
    * [获取国内适用的广告屏蔽域名列表](#获取国内适用的广告屏蔽域名列表)
* [🖼️ 配置效果截图](#-配置效果截图)
* [🖊️ 我用的字体](#-我用的字体)
* [💡 创建你自己的DotFile仓库](#-创建你自己的dotfile仓库)

<!-- vim-markdown-toc -->

## 🔶 成分介绍

- 桌面环境：i3wm
- 编辑器：Vim/Neovim
- 终端：Alacritty + Tmux
- 任务栏：polybar
- 程序选择器：rofi

## 🎨 用法简述

### 一键应用所有配置

以创建软链接的形式一键安装所有配置（同名文件会提示+自动备份，请放心执行）：

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts && cd ./dotfiles-and-scripts && python3 symlink.py
```

如果想创建自己的dotfile仓库，[参考下文](#创建你自己的dotfile仓库)

### 只要(Neo)Vim配置

如果只需要[Vim配置](./home_k/.vimrc)，Unix环境直接运行以下命令，等待自动安装完成
```bash
wget https://raw.githubusercontent.com/Karmenzind/dotfiles-and-scripts/master/home_k/.vimrc -O ~/.vimrc && vim 
```

> 也可以用[脚本安装](#vim及插件安装)

> 使用**root用户**安装我的配置可能会出问题。我不喜欢给root用户单独配置，采用的做法是在`/root`目录下创建`.vimrc`和`.vim`的软链接，与普通用户共用一套配置，供参考。如果要**直接**给root用户安装配置，请自行研究解决方案。

### 安装常用软件（仅ArchLinux）

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts --depth=1 && bash ./install.sh
```

然后选择第一项

## ⚙️ 安装脚本部分

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

#### YouCompleteMe编译安装

> 22年开始已经不再用YouCompleteMe，目前在Neovim中使用内置LSP和cmp相关插件，在Vim中使用coc。此处仅供参考

- [compile and install YouCompleteMe](./scripts/install_vim/ycm.sh) YouCompleteMe插件编译安装

[通过install.sh](#usage)**选择第四项单独安装YouCompleteMe插件**时，需要注意：
1.  阅读ycm.sh的开头部分
2.  修改ycm.sh中的ycm插件安装地址
3.  如果为Arch系统，直接选择任意一种方式安装；如果非Arch系统，选择`official way`可以直接安装，如果选择`my way`方式，需要手动安装python、cmake和clang，然后修改ycm.sh中的`libclang.so`地址

> `official way`是采用ycm自带安装脚本编译安装，`my way`是用我写的命令编译安装。如果用`my way`安装时`git clone`速度太慢，可以手动修改ycm.sh中的git repo地址（脚本注释中提供了国内源）

#### Vim插件涉及依赖安装

部分插件依赖外部工具（比如`fzf`、`ctags`、`ag`等）。按照上述步骤安装Vim以及插件之后，打开Vim，在命令行模式运行：
```
# 依赖系统中的`pip`和`npm`，需自行安装
call InstallRequirements()
```
安装过程中注意观察窗口日志提示。

## 🔌 工具脚本部分

> 此处仅列出在用脚本，部分不再使用/维护的脚本说明，见[脚本目录的README](./local_bin)

### Aria2管理&自动更新bt-tracker

- [myaria2](./local_bin/myaria2)

功能：
- 启动、重启、停止、查看运行状态、查看日志
- 更新bt-tracker（从ngosang/trackerslist获取）。启动、重启时，配置周期触发更新，也可以通过`myaria2 update`主动更新
- 转存旧日志
- 其他一些简单功能

结合cron使用
配置项见脚本注释

### 获取国内适用的广告屏蔽域名列表

- [update-adblock-list](./scripts/tools/update-adblock-list.sh)

主要供pihole使用，其实直接在pihole的adlists中加列表域名也是可以的，但pihole的更新经常卡死（可能是旧树莓派的性能原因），所以干脆弄了个手动处理的脚本。

综合了比较流行的几个repo中的域名列表，合并去重。我是直接在crontab中weekly运行，然后直接在pihole中拉取本地文件。

## 🖼️ 配置效果截图

- i3 desktop:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/float.png)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/desktop.png)

- Vim:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim.png)
    <!-- ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim_goyo.png) -->

## 🖊️ 我用的字体

点这里：[Monaco Nerd](https://github.com/Karmenzind/monaco-nerd-fonts)

## 💡 创建你自己的DotFile仓库

以下脚本用来在系统中直接应用本repo中的配置文件

- [symlink.py](./symlink.py) 以创建软连接的方式（推荐）

你可以fork这个项目，然后借助上述两种方式来同步你自己的配置文件
