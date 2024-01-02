# 🐝 dotfiles and scripts


> ArchLinux一键安装脚本[已经迁移至此处](https://github.com/Karmenzind/arch-installation-scripts)，不再维护

| 类别         | 🎨 成分                                                                                                                                                                                                                           |
|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 系统         | [Archlinux](https://archlinux.org)                                                                                                                                                                                             |
| GUI          | 桌面：[i3](https://i3wm.org)<br>任务栏：[polybar](https://github.com/polybar/polybar)<br>程序选择器：[rofi](https://github.com/davatorium/rofi)<br>通知：dunst<br>渲染优化：picom<br>输入法：fcitx5<br>截图工具：flameshot<br> |
| 编辑器       | Vim/Neovim                                                                                                                                                                                                                     |
| 终端         | [Alacritty](https://github.com/alacritty/alacritty) + Tmux + Zsh                                                                                                                                                               |
| 词典         | [kd](https://github.com/Karmenzind/kd)                                                                                                                                                                                         |
| 字体         | [Monaco Nerd](https://github.com/Karmenzind/monaco-nerd-fonts)                                                                                                                                                                 |
| 其他体验增强 | fzf / ranger / pistol / ag 等等                                                                                                                                                                                                |


<!-- 1.  配置文件 -->
<!--     * i3wm、Tmux、ZSH和各种系统/开发工具 -->
<!--     * Vim/NeoVim两套打磨多年的配置，内部插件有诸多差异但主要行为和快捷键基本一致，主要供日常Python/Golang开发和VimL/Lua/Bash脚本语言编写 --> <!-- 2.  安装脚本 -->
<!--     *   ArchLinux软件批量安装 -->
<!--     *   软件编译/安装脚本，如Vim-YCM插件 -->
<!-- 3.  工具脚本，如Aria2管理等 -->

<!-- <table cellspacing="0" border="0"> -->
<!-- 	<colgroup width="100"></colgroup> -->
<!-- 	<!-1- <colgroup width="1025"></colgroup> -1-> -->
<!--     <tr> -->
<!--         <td rowspan=2 align="center" valign=middle>配置文件</td> -->
<!--         <td>i3wm、Tmux、ZSH和各种系统/开发工具</td> -->
<!--     </tr> -->
<!--     <tr> -->
<!--         <td>Vim/NeoVim两套打磨多年的配置，内部插件有诸多差异但主要行为和快捷键基本一致，主要供日常Python/Golang开发和VimL/Lua/Bash脚本编写</td> -->
<!--     </tr> -->
<!--     <tr> -->
<!--         <td rowspan=2 align="center" valign=middle>自用脚本</td> -->
<!--         <td>工具类：Aria2管理；拉取国内广告屏蔽列表；部分特殊软件自动更新等</td> -->
<!--     </tr> -->
<!--     <tr> -->
<!--         <td>配置类：一键应用本仓库配置；Arch软件批量安装脚本</td> -->
<!--     </tr> -->
<!-- </table> -->


> 查看[文件目录树](./TREE.md)

## TOC

<!-- vim-markdown-toc GFM -->

* [⚙️ 用法](#-用法)
    * [一键应用所有](#一键应用所有)
    * [(Neo)Vim配置](#neovim配置)
    * [安装常用软件](#安装常用软件)
* [🧰 工具脚本](#-工具脚本)
    * [Aria2管理和自动更新bt-tracker](#aria2管理和自动更新bt-tracker)
    * [获取国内适用广告域名列表](#获取国内适用广告域名列表)
* [🖼️ 效果截图](#-效果截图)
* [💡 创建你自己的DotFile仓库](#-创建你自己的dotfile仓库)

<!-- vim-markdown-toc -->




<!-- - 桌面环境： -->
<!--     - 桌面：[i3](https://i3wm.org) -->
<!--     - 任务栏：[polybar](https://github.com/polybar/polybar) -->
<!--     - 程序选择器：[rofi](https://github.com/davatorium/rofi) -->
<!--     - 通知：dunst -->
<!--     - 渲染优化：picom -->
<!--     - 输入法：fcitx5 -->
<!--     - 截图工具：flameshot -->
<!-- - 系统：[Archlinux](https://archlinux.org) -->
<!-- - 编辑器：Vim/Neovim -->
<!-- - 终端：[Alacritty](https://github.com/alacritty/alacritty) + Tmux + Zsh -->
<!-- - 词典：[kd](https://github.com/Karmenzind/kd) -->
<!-- - 字体：[Monaco Nerd](https://github.com/Karmenzind/monaco-nerd-fonts) -->
<!-- - 其他体验增强工具：fzf / ranger / pistol / ag 等等 -->



## ⚙️ 用法

### 一键应用所有

以创建软链接的形式一键安装所有配置（现有文件会询问是否覆盖、自动备份）：

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts && cd dotfiles-and-scripts && python3 symlink.py
```

### (Neo)Vim配置

Vim/Neovim两套打磨多年的配置，内部插件有诸多差异但主要行为和快捷键基本一致，主要供日常Python/Golang开发和VimL/Lua/Bash脚本编写

用交互模式运行symlink.py：

```bash
git clone https://github.com/Karmenzind/dotfiles-and-scripts && cd dotfiles-and-scripts && python3 symlink.py -i
```

然后确认同步以下几项（不用Neovim的话可以不要后两个）：

```
home_k/.vimrc
home_k/.vim/coc-settings.json
home_k/.config/nvim/init.vim
home_k/.config/nvim/lua/config.lua
```

> 使用**root用户**同步Vim配置可能会出问题。我不喜欢给root创建配置，一般是在`/root`目录下创建`.vimrc`和`.vim`的软链接，与普通用户共用一套文件，供参考

然后启动Vim/Neovim，会自动开始安装和初始化

部分插件可能会依赖外部工具（比如`fzf`、`ctags`、`ag`等）才能正常工作，打开Vim/Neovim，在命令行模式执行`:call InstallRequirements()`

### 安装常用软件

包含了我工作开发、日常生活的绝大多数应用程序。脚本中大部分安装命令调用的是pacman和AUR工具，非ArchLinux系的发行版可能不适用

```bash
# 执行后，根据提示，选择第一项
git clone https://github.com/Karmenzind/dotfiles-and-scripts --depth=1 && bash dotfiles-and-scripts/install.sh
```

- [install_apps.sh](./scripts/install_apps.sh)

`_fonts`数组中包含了ArchWiki中推荐的所有中文环境所需字体（不含AUR）

<!-- ## ⚙️ 安装脚本部分 -->

<!-- ### Vim及插件安装 -->

<!-- Vim比较特殊，尤其是YCM经常安装失败，所以单独列出来 -->

<!-- 用脚本安装Vim和插件： -->
<!-- - [complete installation](./scripts/install_vim/main.sh) 直接按照我的Vim配置一键安装Vim和各种插件，无需其他配置 -->

<!-- 如果你已经安装了Vim，需要直接使用我的配置&插件，除了上面的脚本安装外，更简单的方法为直接执行[Usage](#usage)中提到的命令 -->


## 🧰 工具脚本

> 此处仅列出在用脚本，部分不再使用/维护的脚本说明，见[脚本目录的README](./local_bin)

### Aria2管理和自动更新bt-tracker

- [myaria2](./local_bin/myaria2)

功能：
- 启动、重启、停止、查看运行状态、查看日志
- 更新bt-tracker（从ngosang/trackerslist获取）。启动、重启时，配置周期触发更新，也可以通过`myaria2 update`主动更新
- 转存旧日志
- 其他一些简单功能

结合cron使用
配置项见脚本注释

### 获取国内适用广告域名列表

- [update-adblock-list](./scripts/tools/update-adblock-list.sh)

主要供pihole使用，其实直接在pihole的adlists中加列表域名也是可以的，但pihole的更新经常卡死（可能是旧树莓派的性能原因），所以干脆弄了个手动处理的脚本。

综合了比较流行的几个repo中的域名列表，合并去重。我是直接在crontab中weekly运行，然后直接在pihole中拉取本地文件。

## 🖼️ 效果截图

- i3 desktop:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/float.png)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/desktop.png)

- Vim:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim.png)

<!-- ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim_goyo.png) -->


## 💡 创建你自己的DotFile仓库

以下脚本用来在系统中直接应用本repo中的配置文件

- [symlink.py](./symlink.py) 以创建软连接的方式（推荐）

你可以fork这个项目，然后借助上述两种方式来同步你自己的配置文件
