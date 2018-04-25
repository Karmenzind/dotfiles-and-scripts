#! /usr/bin/env python3

import re
import os
import sys
import collections
import getpass


explicit_assigned = {
    "vim": ["~/.vimrc", "vim/.vimrc"],
    "vimdir": ["~/.vim", "vim/.vim"],
}


by_type = {
    "xdg_config_dir": [
        "conky",
        "aria2",
        "i3",
    ],
    "local_bin": [
        "acpyve",
    ],
    "home_root": [
        ".tmux.conf",
    ],
}


ingore_pattern = re.compile(
    "__pycache__"
)


def is_valid(src, dest):
    """ check before sync """
    if os.path.exists(src):
        if os.path.exists(dest):
            for func in (
                os.path.isfile,
                os.path.isdir,
            ):
                if func(src) != func(dest):
                    print("not the same type")
                    return False
    else:
        print("sys_path path doesn't exist")
        return False
    return True

def sync(src, dest):
    if is_valid(src, dest):
        pass


class Item:

    def __init__(self, name=None, sys_path=None, repo_path=None, _type=None, reverse=False):
        self.name = name
        if _type:
            self.locate_by_type()
        else:
            self.sys_path, self.repo_path = sys_path, repo_path
        if reverse:
            self.sys_path, self.repo_path = self.repo_path, self.sys_path
        # final sys_path and repo_path here

    def complete_path(self):
        self.sys_path = os.path.expanduser(self.sys_path)


    def locate_by_type(self, name, _type):
        pass




if __name__ == '__main__':
    pass


