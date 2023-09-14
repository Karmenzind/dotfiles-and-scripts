#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
create symlink
"""

import argparse
import datetime
import getpass
import os
import sys
import time
import warnings
from pathlib import Path

if sys.platform == 'linux':
    platform = 'linux'
    with open('/proc/version', 'r') as f:
        VERSION_INFO = f.read().lower()
elif sys.platform == 'win32':
    platform = 'win'
    VERSION_INFO = None
else:
    warnings.warn("Not tested on this platform: %s" % platform)
    platform = 'unknown'
    VERSION_INFO = None

CUR_TS = int(time.time())
CUR_TIME = datetime.datetime.now().strftime("%Y%m%d_%H%M")
print("Current time: ", CUR_TIME)

REPO_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
HOME_DIR = Path(os.path.expanduser('~'))
os.chdir(REPO_DIR)

TAB = ' ' * 4
YN = ('y', 'n')
YNI = ('y', 'n', 'i')
LINE = '\n' + '-' * 44 + '\n'

TO_SYNC = {
    "linux": [
        Path("home_k"),
        Path("local_bin"),
    ],
    "win": [
        Path("home_k/.vim"),
        Path("home_k/.vimrc"),
        Path("home_k/.config/nvim"),
        Path("home_k/.config/alacritty/alacritty.yml"),
        # "home_k/.golangci.yml",
        # "home_k/.gitconfig",
        # "home_k/.agignore",
        # "home_k/.config/mypy",
    ]
}

PATH_MAP = {
    "linux": {
        Path("home_k"): HOME_DIR,
        Path("local_bin"): "/usr/local/bin",
    },
    "win": {
        Path("home_k/.vim"): HOME_DIR / "vimfiles",
        Path("home_k/.vimrc"): HOME_DIR / "_vimrc",
        Path("home_k/.config/nvim"): HOME_DIR / "AppData\\Local\\nvim",
        Path("home_k/.config/alacritty/alacritty.yml"): HOME_DIR / "AppData\\Roaming\\alacritty\\alacritty.yml",
        # "home_k/.golangci.yml",
        # "home_k/.gitconfig",
        # "home_k/.agignore",
    }
}

# dirs

SYMLINK_AS_DIR = [
    Path("home_k/.vim/mysnippets"),
]

EXCLUDED = [
    Path("home_k/README.md"),
    Path("local_bin/acpyve"),
    Path("local_bin/docker_manager"),
]


def ask(choices, msg='Continue?'):
    ans = None
    msg += ' (%s) ' % '/'.join(choices)
    while ans not in choices:
        ans = input(msg)
    return ans


def validate(src):
    ret = True
    if src in EXCLUDED:
        return False

    if platform == 'linux':
        if 'i3/config' in src:
            if 'manjaro' in VERSION_INFO:
                ret = src.endswith(".manjaro")
            else:
                ret = not src.endswith(".manjaro")

    return ret


backup_pat = f"*.backup_{CUR_TIME}"


def do_symlink(from_, to_):
    print(f"\n>>> processing: {from_} -> {to_}")
    from_ = REPO_DIR / from_
    if os.path.exists(to_):
        if os.path.islink(to_):
            existed_link_to = os.path.realpath(to_) if sys.platform == 'win32' else os.readlink(to_)
            if existed_link_to == str(from_):
                print(
                    f"{to_} is already symlinked to {from_}. Ignored.")
                return

            override_msg = f"{to_} exists and is a symlink (-> {existed_link_to!r}). Override it? (file will be mv to {backup_pat})"
        else:
            override_msg = f"{to_} exists and is not a symlink. Override it? (file will be mv to {backup_pat})"
        ans = ask(YN, override_msg)
        if ans == 'n':
            return

        bakname = to_ + f'.backup_{CUR_TIME}'
        if fake:
            print("[fake] rename: %s -> %s" % (to_, bakname))
        else:
            os.rename(to_, bakname)

    if fake:
        print("[fake] symlink: %s -> %s" % (from_, to_))
    else:
        os.symlink(from_, to_)
        print(f"created symlink for {from_}")


def main():
    """TODO: Docstring for main.
    :returns: TODO

    """
    path_conn = os.sep
    path_map = PATH_MAP[platform]
    for d in TO_SYNC[platform]:
        to_d: Path = path_map[d]
        d = Path(d)
        if platform == 'linux':
            if not str(to_d).startswith("/home") and not getpass.getuser() == "root":
                print("[Warn] root or sudo is required to symlink %s" % d)
                continue

        if os.path.isfile(d):
            to_pardir = os.path.dirname(to_d)
            if not os.path.exists(to_pardir):
                os.makedirs(to_pardir, exist_ok=True)
            do_symlink(d, to_d)
            continue

        for (from_dir, _, subfiles) in os.walk(d):
            from_dir = Path(from_dir)
            # from_dir_unix = from_dir.replace(path_conn, '/')
            if from_dir in path_map:
                to_dir = path_map[from_dir]
            else:
                sep_count = str(d).count(path_conn)
                if sep_count:
                    to_dir = os.path.join(
                        to_d, path_conn.join(str(from_dir).split(path_conn)[sep_count + 1:])
                    )
                else:
                    to_dir = os.path.join(to_d, str(from_dir).split(path_conn, 1)[1])

            if from_dir in SYMLINK_AS_DIR:
                do_symlink(from_dir, to_dir)
                continue

            if not os.path.isdir(to_dir):
                if fake:
                    print("[fake] create dir:", to_dir)
                else:
                    os.makedirs(to_dir, exist_ok=True)

            for filename in subfiles:
                src = os.path.join(from_dir, filename)
                dest = os.path.join(to_dir, filename)

                if not validate(src):
                    print("\n>>> Ignored invalid: %s" % src)
                    continue

                try:
                    do_symlink(src, dest)
                except Exception as e:
                    print("[Warn] Error occurred: %s", e)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--fake', action='store_true', help="Only preview what will happen")
    args = parser.parse_args()
    fake = args.fake

    main()
