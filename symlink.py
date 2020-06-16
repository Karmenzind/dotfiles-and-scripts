#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
create symlink
instead of copying files with do_synch.py
"""

import os
import re
import time

CUR_TS = int(time.time())
REPO_DIR = os.path.dirname(os.path.abspath(__file__))
HOME_DIR = os.path.expanduser('~')
os.chdir(REPO_DIR)

TAB = ' ' * 4
YN = ('y', 'n')
YNI = ('y', 'n', 'i')
LINE = '\n' + '-' * 44 + '\n'

path_map = {
    "home_k": HOME_DIR,
    "local_bin": "/usr/local/bin",
}


TO_SYNC = (
    "home_k/.Xresources",
    "home_k/.agignore",
    "home_k/.config/pylintrc",
    "home_k/.config/alacritty/alacritty.yml",
    "home_k/.config/aria2/aria2.conf",
    "home_k/.config/picom.conf",
    "home_k/.config/conky/conky.conf",
    "home_k/.config/dunst/dunstrc",
    "home_k/.config/fcitx/data/punc.mb.zh_CN",
    "home_k/.config/i3/config",
    "home_k/.config/i3/conky_status.sh",
    "home_k/.config/i3/screenshot.sh",
    "home_k/.config/i3/run_oneko.sh",
    "home_k/.config/i3status/config",
    "home_k/.config/nvim/init.vim",
    "home_k/.config/rofi/config",
    "home_k/.config/shrc.ext",
    "home_k/.config/volumeicon/volumeicon",
    "home_k/.config/xfce4/terminal/terminalrc",
    "home_k/.config/mypy/config",
    "home_k/.gitconfig",
    "home_k/.tmux.conf",
    "home_k/.tmuxinator/k.yml",
    "home_k/.vim/.ycm_extra_conf.py",
    "home_k/.vim/mysnippets",
    "home_k/.vimrc",
    "home_k/.xinitrc",
    "home_k/.zshrc",
    "home_k/.eslintrc.js",
    "home_k/.stylelintrc",
    # "local_bin/acpyve",
    # "local_bin/docker_manager",
    "local_bin/myaria2",
)


def ask(choices, msg='Continue?'):
    ans = None
    msg += ' (%s) ' % '/'.join(choices)
    while ans not in choices:
        ans = input(msg)
    return ans


def proc_src(src):
    ret = src
    if 'i3/config' in src:
        # manjaro
        with open('/proc/version', 'r') as f:
            version_info = f.read().lower()
            if 'manjaro' in version_info:
                ret = src + '.manjaro'
    return ret


backup_pat = f"*_backup_{CUR_TS}"

if __name__ == "__main__":
    for src in TO_SYNC:
        pref, post = re.match(r"([^/]+)/(.*)", src).groups()
        dest = os.path.join(path_map[pref], post)

        src = proc_src(src)
        print(f"\n>>> processing: {src} -> {dest}")

        src = os.path.join(REPO_DIR, src)
        if os.path.exists(dest):
            if os.path.islink(dest):
                print(os.readlink(dest))
                if os.readlink(dest) == src:
                    print(f"{dest} exists and is already symlinked to {src}. Ignored.")
                    continue
                override_msg = f"{dest} exists and is a symlink. Override it? (file will be mv to {backup_pat})"
            else:
                override_msg = f"{dest} exists and is not a symlink. Override it? (file will be mv to {backup_pat})"
            ans = ask(YN, override_msg)
            if ans == 'n':
                continue
            os.rename(dest, dest + '_backup_{CUR_TS})')
        else:
            prdir = os.path.dirname(dest)
            if not os.path.isdir(prdir):
                os.makedirs(prdir)
        os.symlink(src, dest)
        print(f"created symlink for {src}")
