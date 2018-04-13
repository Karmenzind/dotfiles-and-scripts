## dotfiles and scripts 
-----

各种配置文件和脚本<br>
dotfiles and scripts for my ArchLinux

### 配置和脚本部分
-----

包含用于vim、i3wm等软件的配置<br>
和一些自己编写的工具脚本<br>
主要结构如下
> 用[这个脚本](./utils/build_trees.sh)生成

- [install.sh](./install.sh)
- [.config](./home/.config)
    - [aria2](./home/.config/aria2)
    - [compton.conf](./home/.config/compton.conf)
    - [dunst](./home/.config/dunst)
    - [fontconfig](./home/.config/fontconfig)
    - [i3](./home/.config/i3)
    - [volumeicon](./home/.config/volumeicon)
    - [xfce4](./home/.config/xfce4)
	- [.tmux.conf](./home/.tmux.conf)
- [local_scripts](./local_bin)
	- [acpyve](./local_bin/acpyve)
	- [docker_manager](./local_bin/docker_manager)
	- [myaria2](./local_bin/myaria2)
- [others](./others)
	- [bashrc_ext](./others/bashrc_ext)
	- [fcitx](./others/fcitx)
- [vim](./vim)
	- [.vim](./vim/.vim)
	- [.vimrc](./vim/.vimrc)

### 安装使用部分
-----

1. ArchLinux的不完整安装脚本

**此部分尚未完成**

如果你对**ArchLinux安装过程**和**Bash语法**非常熟悉，欢迎使用我的脚本<br>
按照安装过程顺序排列

- [install_arch](./scripts/install_arch)
    - [live_cd_part](./scripts/install_arch/live_cd_part.sh) LiveCD部分
    - [chrooted_part](./scripts/install_arch/chrooted_part.sh) chroot之后，取出LiveCD之前
    - [graphical_env_part](./scripts/install_arch/graphical_env_part.sh) 安装桌面环境，此处为i3wm
    - [common_tools_part](./scripts/install_arch/common_tools_part.sh) 安装常用软件

2. 载入我的配置 

**此部分尚未完成**

3. 我的必需/常用软件安装

加入`-y`参数，可以免确认安装

- [install_apps.sh](./scripts/install_apps.sh)

4. Vim安装

Vim比较特殊，所以单独提出来

- [install_vim](./scripts/install_vim)
    - [main.sh](./scripts/install_vim/main.sh) 按照我的vim完整安装
    - [ycm.sh](./scripts/install_vim/ycm.sh) YouCompleteMe插件编译安装

