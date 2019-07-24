#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
create symlink
instead of sync by do_synch.py
"""

# TODO(k): <2019-07-24> check existed symlinks

import os
import pprint
import re
import shutil
import sys
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
    "home_k/.config/compton.conf",
    "home_k/.config/conky/conky.conf",
    "home_k/.config/dunst/dunstrc,",
    "home_k/.config/fcitx/data/punc.mb.zh_CN",
    "home_k/.config/i3/config",
    "home_k/.config/i3/conky_status.sh",
    "home_k/.config/i3/screenshot.sh",
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
    # "local_bin/acpyve",
    # "local_bin/docker_manager",
    # "local_bin/myaria2",
)


def ask(choices, msg='Continue?'):
    ans = None
    msg += ' (%s) ' % '/'.join(choices)
    while ans not in choices:
        ans = input(msg)
    return ans


for src in TO_SYNC:
    pref, post = re.match(r"([^/]+)/(.*)", src).groups()
    dest = os.path.join(path_map[pref], post)
    ans = ask(YN, f"processing: {src} -> {dest}\nContinue?")
    if ans == 'n':
        continue

    src = os.path.join(REPO_DIR, src)
    if os.path.exists(dest):
        if os.path.islink(dest):
            override_msg = f"{dest} exists and is a symlink. Override it? (file will be mv to *_backup_{CUR_TS})\n"
        else:
            override_msg = f"{dest} exists and is not a symlink. Override it? (file will be mv to *_backup_{CUR_TS})\n"
        ans = ask(YN, override_msg)
        if ans == 'n':
            continue
        os.rename(dest, dest + '_backup')
    else:
        prdir = os.path.dirname(dest)
        if not os.path.isdir(prdir):
            os.makedirs(prdir)
    os.symlink(src, dest)
    print(f"created symlink for {src}")
