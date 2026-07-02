# 🐝 dotfiles and scripts for my Linux/Win

> ArchLinux一键安装脚本[已经迁移至此处](https://github.com/Karmenzind/arch-installation-scripts)，不再维护

<table>
	<colgroup align="center">
    <col width="50" align="center"></col>
    <col width="70" align="center"></col>
    <col width="180" align="center"></col>
    <col width="160" align="center"></col>
	</colgroup>
  <thead>
    <tr>
      <th colspan=2>🎨</th>
      <th>Linux</th>
      <th>Windows</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" rowspan="5" width="50">Shell</td>
      <td align="center" >Editor</td>
      <td align="center" colspan=2>Vim / Neovim （兼容vscode-neovim）</td>
      <!-- <td align="center">Shell: Vim/Neovim<br>GUI: GVim/Neovide</td> -->
    </tr>
    <tr>
      <td align="center">Terminal</td>
      <td align="center">
        <a href="https://github.com/alacritty/alacritty">Alacritty</a> + Tmux + Zsh
      </td align="center">
      <td align="center">WindowsTerminal + pwsh(<a href="ohmyposh.dev">OMPosh</a>)</td>
    </tr>
    <tr>
      <td align="center" >Font</td>
      <td align="center" colspan="2">
        <a href="https://github.com/Karmenzind/monaco-nerd-fonts">Monaco Nerd</a>
      </td align="center">
    </tr>
    <tr>
      <td align="center" >Dict</td>
      <td align="center" colspan="2"><a href="https://github.com/Karmenzind/kd">kd</a></td>
    </tr>
    <tr>
      <td align="center" >Others</td>
      <td align="center" colspan="2">fzf / fd / ranger / lf / pistol / rg  etc.</td>
    </tr>
    <tr>
      <td align="center" rowspan="7" width="50">GUI</td>
      <td align="center">Desktop</td>
      <td align="center"><a href="https://i3wm.org">i3wm</a></td>
      <td align="center" rowspan="7">-</td>
    </tr>
    <tr>
      <td align="center">Statusbar</td>
      <td align="center"><a href="https://github.com/polybar/polybar">polybar</a></td>
    </tr>
    <tr>
      <td align="center">Launcher</td>
      <td align="center"><a href="https://github.com/davatorium/rofi">rofi</a></td>
    </tr>
    <tr>
      <td align="center">Notice</td>
      <td align="center">dunst</td>
    </tr>
    <tr>
      <td align="center">Enhancement</td>
      <td align="center">picom</td>
    </tr>
    <tr>
      <td align="center">Input</td>
      <td align="center">fcitx5</td>
    </tr>
    <tr>
      <td align="center">Screenshot</td>
      <td align="center">flameshot</td>
    </tr>
  </tbody>
</table>

> 查看[文件目录树](./TREE.md)

## TOC

<!-- vim-markdown-toc GFM -->

* [:gear: 用法](#gear-用法)
    * [一键应用配置](#一键应用配置)
    * [(Neo)Vim配置和相关应用](#neovim配置和相关应用)
    * [安装常用软件](#安装常用软件)
        * [Linux](#linux)
        * [Windows](#windows)
* [:toolbox: 工具脚本](#toolbox-工具脚本)
    * [Aria2管理和自动更新bt-tracker](#aria2管理和自动更新bt-tracker)
    * [获取国内适用广告域名列表](#获取国内适用广告域名列表)
* [:eyes: 效果截图](#eyes-效果截图)
* [:bulb: 创建你自己的DotFile仓库](#bulb-创建你自己的dotfile仓库)

<!-- vim-markdown-toc -->

## :gear: 用法

首先，克隆项目到本地

### 一键应用配置

以创建软链接的形式一键安装所有配置（现有文件会询问是否覆盖、自动备份）（兼容Linux/Win）：

```bash
python symlink.py
```

支持参数：
- -i 文件逐个提示交互
- --nogui 排除桌面程序
- --vimonly 只要(Neo)Vim相关

### (Neo)Vim配置和相关应用

Vim/Neovim（兼容vscode-neovim）两套打磨多年的配置，内部插件有诸多差异但主要行为和快捷键基本一致，主要供日常 **Python/Golang/Java/Javascript/Typescript** 开发和 **VimL/Lua/Bash** 脚本编写

最简单的方式：

```bash
bash scripts/setup_vim.sh
```

如果需要配置文件，用交互模式运行symlink.py：

```bash
python symlink.py --vimonly
```

然后启动Vim/Neovim，会自动开始安装和初始化

> 使用**root用户**同步Vim配置可能会出问题。我不喜欢给root创建配置，一般是在`/root`目录下创建`.vimrc`和`.vim`的软链接，与普通用户共用一套文件，供参考


部分插件可能会依赖外部工具（比如`fzf`、`ctags`、`rg`等）才能正常工作，执行`bash scripts/setup_vim.sh`进行安装

### 安装常用软件

包含了我工作开发、日常生活的绝大多数应用程序。

#### Linux

支持Archlinux系和Debian/Ubuntu系发行版

```bash
bash scripts/install_apps.sh
```

- [install_apps.sh](./scripts/install_apps.sh)

#### Windows

```powershell
./dotfiles-and-scripts/install.ps1
```

## :toolbox: 工具脚本

> 此处仅列出在用脚本，部分不再使用/维护的脚本说明，见[脚本目录的README](./scripts/deprecated/README.md)

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

## :eyes: 效果截图

- i3 Desktop on ArchLinux:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/float.png)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/desktop.png)

- (N)Vim:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim.png)

- Windows Terminal & pwsh7:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/winterminal.png)

## :bulb: 创建你自己的DotFile仓库

以下脚本用来在系统中直接应用本repo中的配置文件

- [symlink.py](./symlink.py) 以创建软连接的方式（推荐）

你可以fork这个项目，然后借助上述两种方式来同步你自己的配置文件
