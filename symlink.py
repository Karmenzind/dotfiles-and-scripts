#!/usr/bin/env python
# Github: https://github.com/Karmenzind/dotfiles-and-scripts
"""
apply everything in form of
creating symbolic links for them
(there will be prompt and backup before overwriting files)
"""

from __future__ import annotations, print_function, unicode_literals

import sys

if sys.version_info.major < 3:
    print("[✘] Python3 is required.")

import argparse
import datetime
import getpass
import os
import platform
import sys
import time
import warnings
from collections import defaultdict
from pathlib import Path
from typing import List, Set

rec = defaultdict(list)

PLATFORM_VERSION = SYSTEM_VERION_NO = ""
if sys.platform == "linux":
    osname = "linux"
    with open("/proc/version", "r") as f:
        PLATFORM_VERSION = f.read().lower()
elif sys.platform == "win32":
    osname = "win"
elif sys.platform == "darwin":
    osname = "mac"
    SYSTEM_VERION_NO = platform.mac_ver()[0]
else:
    osname = "unknown"
    warnings.warn("Not tested on this platform: %s" % sys.platform)

new_linked = rec["new"]

CUR_TS = int(time.time())
CUR_TIME = datetime.datetime.now().strftime("%Y%m%d_%H%M")

REPO_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
HOME_DIR = Path(os.path.expanduser("~"))
SRC_HOME = Path("home_k")
os.chdir(REPO_DIR)

TAB = " " * 4
YN = ("y", "n")
YNI = ("y", "n", "i")
LINE = "\n" + "-" * 44 + "\n"

TO_SYNC: Set[Path] = {
    SRC_HOME / ".vim",
    SRC_HOME / ".vimrc",
    SRC_HOME / ".condarc",
    SRC_HOME / ".gitconfig",
    SRC_HOME / "isort.cfg",
    SRC_HOME / "pycodestyle",
    SRC_HOME / "pylintrc",
    SRC_HOME / "ripgreprc",
    SRC_HOME / ".config/nvim/init.lua",
    SRC_HOME / ".config/mypy",
    SRC_HOME / ".config/ripgreprc",
    SRC_HOME / ".config/alacritty/alacritty.toml",
    Path("others/powershell/profile.ps1"),
}

if osname == "win":
    def get_ps_profile_path(all_users=False):
        import subprocess
        ps_args = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
        if all_users:
            powershell_command = f"pwsh {ps_args} $PROFILE.AllUsersCurrentHost"
        else:
            powershell_command = f'pwsh {ps_args} $PROFILE'
        result = subprocess.run(
            powershell_command, stdout=subprocess.PIPE, text=True, shell=True)
        return result.stdout.strip()

    TO_SYNC.update([
        SRC_HOME / ".config/alacritty/win.toml",
        Path("others/powershell/profile.ps1"),
    ])
    PATH_MAP = {
        SRC_HOME: HOME_DIR,
        SRC_HOME / ".config": HOME_DIR / ".config",
        SRC_HOME / ".vim": HOME_DIR / "vimfiles",
        SRC_HOME / ".vimrc": HOME_DIR / "_vimrc",
        SRC_HOME / ".config/nvim": HOME_DIR / "AppData\\Local\\nvim",
        SRC_HOME / ".config/alacritty/alacritty.toml": HOME_DIR / "AppData\\Roaming\\alacritty\\alacritty.toml",
        SRC_HOME / ".config/alacritty/win.toml": HOME_DIR / ".alacritty_extra.toml",
        Path("others/powershell/profile.ps1"): get_ps_profile_path(),
    }
elif osname == "mac":
    TO_SYNC.update([
        SRC_HOME / ".config/fish",
        SRC_HOME / ".config/ranger",
        SRC_HOME / ".config/mypy",
        SRC_HOME / ".config/alacritty/mac.toml",
    ])
    PATH_MAP = {
        SRC_HOME: HOME_DIR,
        Path("others/powershell/profile.ps1"): HOME_DIR / ".config/powershell/profile.ps1",
        SRC_HOME / ".config/alacritty/mac.toml": HOME_DIR / ".config/alacritty/extra.toml",
    }
else:  # linux like
    TO_SYNC.update([
        Path("home_k"),
        Path("local_bin"),
        Path("others/powershell/profile.ps1"),
    ])
    PATH_MAP = {
        SRC_HOME: HOME_DIR,
        Path("local_bin"): Path("/usr/local/bin"),
        Path("others/powershell/profile.ps1"): HOME_DIR / ".config/powershell/profile.ps1",
        SRC_HOME / ".config/alacritty/linux.toml": HOME_DIR / ".config/alacritty/extra.toml",
        # Path("others/powershell/profile.ps1"): HOME_DIR / ".config/powershell/Microsoft.PowerShell_profile.ps1"
    }


# dirs
SYMLINK_AS_DIR = [
    SRC_HOME / ".vim/mysnippets",
]

EXCLUDED = [
    SRC_HOME / ".config/alacritty/alacritty.yml",
    SRC_HOME / ".config/fontconfig",
    SRC_HOME / ".config/fctix",
    SRC_HOME / ".vim/.ycm_extra_conf.py",
    Path("local_bin/acpyve"),
    Path("local_bin/docker_manager"),
]

GUI_PATTERNS = [
    "alacritty",
    "picom",
    "conky",
    "dunst",
    "fcitx",
    "fcitx5",
    "i3",
    "i3status",
    "polybar",
    "volumeicon",
    "deadd",
    "rofi",
    "xfce4",
    "fontconfig",
    ".Xresources",
    ".xinitrc",
]


def ask(choices, msg="≫  continue?"):
    ans = None
    msg += " (%s) " % "/".join(choices)
    while ans not in choices:
        ans = input(msg)
    return ans


def display(p: Path):
    ret = str(p)
    if osname == "win":
        return ret

    repo_dir = str(REPO_DIR)
    if ret.startswith(repo_dir):
        return ret.split(repo_dir, maxsplit=1)[1].lstrip("/")

    home_dir = str(HOME_DIR)
    if ret.startswith(home_dir):
        return "~" + ret.split(home_dir, maxsplit=1)[1]


def validate(src: Path) -> bool:
    ret = True
    src_str = str(src)

    for suffix in [".md", ".swp"]:
        if src_str.endswith(suffix):
            return False

    if args.nogui:
        for p in GUI_PATTERNS:
            if p in src_str.split(os.sep):
                return False

    if Path(src) in EXCLUDED:
        return False

    if osname == "linux":
        if "i3/config" in src_str:
            if "manjaro" in PLATFORM_VERSION:
                ret = src_str.endswith(".manjaro")
            else:
                ret = not src_str.endswith(".manjaro")

    return ret


def ensure_pardir(filepath):
    to_pardir = os.path.dirname(filepath)
    if not os.path.exists(to_pardir):
        os.makedirs(to_pardir, exist_ok=True)


backup_pat = f"*.backup_{CUR_TIME}"
__processed = set()


def do_symlink(from_: Path, to_: Path):
    if (from_, to_) in __processed:
        return
    __processed.add((from_, to_))

    from_ = REPO_DIR / from_

    # A file can be a symlink as well as nonexisted on Win. Fuck Windows
    if os.path.islink(to_):
        existed_link_to = os.path.realpath(
            to_) if sys.platform == "win32" else os.readlink(to_)
        if existed_link_to == str(from_):
            if args.delete:
                os.remove(to_)
                rec["del"].append(to_)
                print(f"[✔] removed symlink: {to_}")
                return

            print(f"[✔] {display(to_)} is already symlinked to {display(from_)}.")
            return

        override_msg = f"{display(to_)} exists and is a symlink (-> {existed_link_to!r}). Override it? (file will be mv to {backup_pat})"
    else:
        if os.path.exists(to_):
            override_msg = f"{display(to_)} exists and is not a symlink. Override it? (file will be mv to {backup_pat})"
        else:
            override_msg = ""

    if args.delete:
        return

    print(f"\n≫  processing: {display(from_)} -> {display(to_)}")
    if args.interactive and ask(YN) == "n":
        print("Ignored.")
        return

    if override_msg:
        ans = ask(YN, override_msg)
        if ans == "n":
            return

        bakname = str(to_) + f".backup_{CUR_TIME}"
        if fake:
            print("[fake] rename: %s -> %s" % (to_, bakname))
        else:
            os.rename(to_, bakname)

    if fake:
        print("[fake] symlink: %s -> %s" % (from_, to_))
    else:
        try:
            os.symlink(from_, to_)
            new_linked.append(to_)
            print(f"[✔] created symlink for {from_}")
        except Exception as e:
            print(f"[✘] Error occurred: {e}")


def accessible(p):
    if osname == "linux":
        if not str(p).startswith("/home") and not getpass.getuser() == "root":
            return False
    return True


def get_mapped(p: Path) -> Path:
    if p in PATH_MAP:
        return PATH_MAP[p]

    parts = str(p).split(os.sep)
    if len(parts) == 1:
        raise AssertionError(f"{p} not in PATH_MAP")

    for i in range(len(parts) - 1, 0, -1):
        left = Path(os.sep.join(parts[:i]))
        if left in PATH_MAP:
            return PATH_MAP[left] / os.sep.join(parts[i:])

    raise AssertionError(f"Mapping {p} failed")


def main():
    if args.delete:
        print("≫  This action will delete all symlinks")
        if ask(YN) == "n":
            print("Canceled.")
            return

    for item in TO_SYNC:
        mapped: Path = get_mapped(item)
        if not accessible(mapped):
            print("[⚠ Warn] root or sudo is required to symlink %s" % item)
            continue

        if os.path.isfile(item):
            ensure_pardir(mapped)
            do_symlink(item, mapped)
            continue

        for from_dir, _, subfiles in os.walk(item):
            from_dir = Path(from_dir)
            to_dir = get_mapped(from_dir)

            if from_dir in EXCLUDED:
                print("≫  Ignored excluded dir: %s" % from_dir)
                continue

            if from_dir in SYMLINK_AS_DIR:
                do_symlink(from_dir, to_dir)
                continue

            if not os.path.isdir(to_dir):  # not exist
                if fake:
                    print("[fake] create dir:", to_dir)
                else:
                    os.makedirs(to_dir, exist_ok=True)

            for filename in subfiles:
                src = from_dir / filename
                if not validate(src):
                    print("≫  Ignored invalid/excluded: %s" % src)
                    continue

                do_symlink(src, to_dir / filename)

    if new_linked:
        print("[✔]  New created links:")
        for i in new_linked:
            print("\t", i)

    if rec["del"]:
        print("[✔]  Deleted links:")
        for i in rec["del"]:
            print("\t", i)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="created symlinks for configuration files in this repo")
    parser.add_argument("--fake", action="store_true", help="only preview what will happen")
    parser.add_argument("-i", "--interactive", action="store_true", help="let me determine each file")
    parser.add_argument("-d", "--delete", action="store_true", help="remove all symlink files")
    parser.add_argument("--nogui", action="store_true", help="only for terminal apps")
    parser.add_argument("--vimonly", action="store_true", help="only for vim related")
    args = parser.parse_args()
    fake = args.fake

    if args.vimonly:
        TO_SYNC = {
            SRC_HOME / ".vim",
            SRC_HOME / ".vimrc",
            SRC_HOME / ".config/nvim/init.lua",
            # linters/fixers?
        }

    main()
