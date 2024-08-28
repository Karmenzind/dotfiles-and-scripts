# 🐝 dotfiles and scripts for my Linux/Win

> The ArchLinux installation scripts has been migrated to [this repo](https://github.com/Karmenzind/arch-installation-scripts) and is no longer maintained.

|[简体中文](./README_CN.md)|

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
      <td align="center" colspan=2>Vim / Neovim (compatible with vscode-neovim)</td>
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

> Check [file tree](./TREE.md)

## TOC

<!-- vim-markdown-toc GFM -->

* [:gear: usage](#gear-usage)
    * [apply all configurations](#apply-all-configurations)
    * [(Neo)Vim configuration and setup](#neovim-configuration-and-setup)
    * [install recommanded apps](#install-recommanded-apps)
        * [Linux](#linux)
        * [Windows](#windows)
* [:toolbox: toolbox scripts](#toolbox-toolbox-scripts)
    * [manage Aria2 and auto update bt-trackers](#manage-aria2-and-auto-update-bt-trackers)
    * [fetch advertisement domain list for Chinese users](#fetch-advertisement-domain-list-for-chinese-users)
* [:eyes: screenshots](#eyes-screenshots)
* [:bulb: create your own Dotfile repo](#bulb-create-your-own-dotfile-repo)

<!-- vim-markdown-toc -->

## :gear: usage

Firstly, **clone** this repo.

### apply all configurations

To apply everything in form of creating symbolic links for them (there will be prompt and backup before overwriting files):

```bash
python3 symlink.py
```

script parameters：
-  -h                 show this help message and exit
-  -i, --interactive  Let me determine each file
-  -d, --delete       remove all symlink files
-  --nogui            only for terminal apps
-  --vimonly          only for vim related apps

### (Neo)Vim configuration and setup

Here are two sets of **full-featured** configuration for Vim and Neovim (compatible with vscode-neovim). Spent years optimizing them. There are many plugin differences, but the basic behaviors and keybindings are pretty much the same. Mainly for everyday **Python/Golang/Java/Javascript/Typescript** development, as well as whipping up **VimL/Lua/Bash** scripts.

Simply run:

```bash
bash scripts/setup_vim.sh
```

This script will take care of everything included:

- ensure Vim/Neovim installed
- created symlinks for configuraion files
- setup plugin and the manager
- install related apps (lsp, linters, fixers, fuzzy finders, etc.)

Or if you only need the configuration files, run symlink.py with `vimonly` specified:

```bash
python3 symlink.py --vimonly
```

Launch Vim/Neovim and the plugin setup will start automatically.

> Syncing Vim configurations directory under **root** might run into issues. I prefer not to create unique configuration for root user. FYI, I will create symlinks for .vimrc and .vim unser /root, sharing the same files with normal user.

### install recommanded apps

These are the apps I use for pretty much everything – work, development, and everyday life.

#### Linux

[This script](./scripts/install_apps.sh) supports both Arch Linux-based and Debian/Ubuntu-based distributions.

```bash
bash scripts/install_apps.sh
```

#### Windows

```bash
./dotfiles-and-scripts/scripts/setup.ps1
```

## :toolbox: toolbox scripts

> the description about some scripts that are no longer maintained can [be found here](./scripts/deprecated/README.md)

### manage Aria2 and auto update bt-trackers

- [myaria2](./local_bin/myaria2)

Function:

- launch, restart, stop, check status, check log
- update bt-tracker（from ngosang/trackerslist) periodically. Or via `update` subcommand
- backup old log files
- other trivials

Better combine with cron.

More details can be found in comments of the script.

### fetch advertisement domain list for Chinese users

- [update-adblock-list](./scripts/tools/update-adblock-list.sh)

Mainly for Pi-hole use. Alternatively you can add domain lists directly to Pi-hole's adlists, but Pi-hole updates often get stuck (possibly due to the performance of older Raspberry Pi models). So, I decided to create a manual handling script instead.

I've mixed together domain lists from a bunch of popular repos, got rid of duplicates, and set it to run weekly in crontab. After that, just add local file link to Pi-hole.

## :eyes: screenshots

- i3 Desktop on ArchLinux:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/float.png)
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/desktop.png)

- (N)Vim:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/vim.png)

- Windows Terminal & pwsh7:
    ![](https://raw.githubusercontent.com/Karmenzind/i/master/dotfiles-and-scripts/winterminal.png)

## :bulb: create your own Dotfile repo

You can fork this repo and symlink your configuration files with [symlink.py](./symlink.py).
