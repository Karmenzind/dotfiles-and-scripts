#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
create symlink
instead of copying files with do_synch.py
"""

import os
import re
import time
import datetime

CUR_TS = int(time.time())
CUR_TIME = datetime.datetime.now().strftime("%Y%m%d_%H%M")
print("Current time: ", CUR_TIME)

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

# dirs
TO_SYNC = (
    "home_k",
    "local_bin",
)

SYMLINK_AS_DIR = [
    "home_k/.vim/mysnippets",
]

EXCLUDED = [
    "local_bin/acpyve",
    "local_bin/docker_manager",
]


def ask(choices, msg='Continue?'):
    ans = None
    msg += ' (%s) ' % '/'.join(choices)
    while ans not in choices:
        ans = input(msg)
    return ans


with open('/proc/version', 'r') as f:
    VERSION_INFO = f.read().lower()


def validate(src):
    ret = True
    if src in EXCLUDED:
        return False

    if 'i3/config' in src:
        if 'manjaro' in VERSION_INFO:
            ret = src.endswith(".manjaro")
        else:
            ret = not src.endswith(".manjaro")

    return ret


backup_pat = f"*.backup_{CUR_TIME}"


def do_symlink(from_, to_):
    from_ = os.path.join(REPO_DIR, from_)
    if os.path.exists(to_):
        if os.path.islink(to_):
            print(os.readlink(to_))
            if os.readlink(to_) == from_:
                print(
                    f"{to_} is already symlinked to {from_}. Ignored.")
                return

            override_msg = f"{to_} exists and is a symlink. Override it? (file will be mv to {backup_pat})"
        else:
            override_msg = f"{to_} exists and is not a symlink. Override it? (file will be mv to {backup_pat})"
        ans = ask(YN, override_msg)
        if ans == 'n':
            return

        os.rename(to_, to_ + f'.backup_{CUR_TIME}')

    os.symlink(from_, to_)
    print(f"created symlink for {from_}")


def main():
    """TODO: Docstring for main.
    :returns: TODO

    """
    import getpass
    for d in TO_SYNC:
        to_d = path_map[d]
        if not to_d.startswith("/home") and not getpass.getuser() == "root":
            print("[Warn] root or sudo is required to symlink %s" % d)
            continue

        for (from_dir, _, subfiles) in os.walk(d):
            if from_dir.count("/"):
                to_dir = os.path.join(to_d, from_dir.split("/", 1)[1])
                os.makedirs(to_dir, exist_ok=True)
            else:
                to_dir = path_map[d]

            if from_dir in SYMLINK_AS_DIR:
                do_symlink(from_dir, to_dir)
                continue

            for filename in subfiles:
                src = os.path.join(from_dir, filename)
                dest = os.path.join(to_dir, filename)

                if not validate(src):
                    print("\n>>> Ignored invalid: %s" % src)
                    continue

                print(f"\n>>> processing: {src} -> {dest}")

                do_symlink(src, dest)


if __name__ == "__main__":
    main()
