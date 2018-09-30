#! /usr/bin/env python3
# https://github.com/Karmenzind/

import collections
import os
import re
import shutil
import sys
from pprint import pprint

REPO_DIR = os.path.dirname(os.path.abspath(__file__))
HOME_DIR = os.path.expanduser('~')
TAB = ' ' * 4
YN = ('y', 'n')
YNI = ('y', 'n', 'i')
LINE = '\n' + '-' * 44 + '\n'

prompt = """
USAGE
    python3 %s [update|apply]

OPTIONS
    apply       copy configure files and scripts to your system
    update      copy your own files to this repo, which only works
                if there is already a file with the same name in this repo

""" % __file__


os.chdir(REPO_DIR)

path_map = {
    "home_k": HOME_DIR,
    "local_bin": "/usr/local/bin",
}

ingored_patterns = (
    re.compile(".*__pycache__.*"),
    re.compile("home_k/Pictures"),
    re.compile("README"),
)


class Status:
    """ as global counter"""
    copied = []
    not_copied = []

    def display(self):
        if self.copied:
            print(len(self.copied), 'files have been directly copied.')
            for _f, _t in self.copied:
                print('\t', _f, '-->', _t)
        # if self.not_copied:
        #     print(len(self.copied), 'files remained.')
        #     for _f, _t in self.copied:
        #         print('\t', _f, '-->', _t)


not_sync = collections.defaultdict(list)  # {reason: files}
sync_queue = []


def ask(choices, msg='Continue?'):
    ans = None
    msg += ' (%s) ' % '/'.join(choices)
    while ans not in choices:
        ans = input(msg)
    return ans


def sync(mode):
    for _f, _t in sync_queue:
        if mode == 'i':
            msg = 'Copy %s to %s?' % (_f, _t)
            ans = ask(YN, msg)
            if ans == 'y':
                copy(_f, _t)
        else:
            copy(_f, _t)


def is_ignored(path):
    for p in ingored_patterns:
        if p.search(path):
            return True
    return False


def copy(_f, _t, interactive=False):
    ok = True
    if interactive:
        msg = 'Copy %s to %s?' % (_f, _t)
        ans = ask(YN, msg)
        if ans != 'y':
            ok = False
    if ok:
        create_parent_dir(_t)
        if _t.startswith('/home'):
            shutil.copyfile(_f, _t)
        else:
            os.system('sudo cp %s %s' % (_f, _t))
        print('Copied %s to %s' % (_f, _t))

        Status.copied.append((_f, _t))
    else:
        Status.not_copied.append((_f, _t))


def create_parent_dir(path):
    """ before copy"""
    par = os.path.dirname(path)
    if not os.path.exists(par):
        print('Creating', par)
        if par.startswith('/home'):
            os.makedirs(par)
        else:
            os.system('sudo mkdir -p %s' % par)


def cmp(f1, f2):
    """ compare 2 files literally"""
    with open(f1) as f1, open(f2) as f2:
        return f1.read() == f2.read()


class Item:

    def __init__(self,
                 repo_path=None,
                 sys_path=None,
                 action=None):
        self.repo_path = repo_path
        self.sys_path = sys_path
        self.action = action
        self.both_exists = bool(
            os.path.exists(self.repo_path) and os.path.exists(self.sys_path)
        )

        if self.action == 'update':
            _f, _t = self.sys_path, self.repo_path
        elif self.action == 'apply':
            _f, _t = self.repo_path, self.sys_path
        self._f, self._t = _f, _t

    def get_sync_tuple(self):
        return self._f, self._t

    def is_valid(self):
        if self.action == 'update':
            if not os.path.exists(self.sys_path):
                not_sync["Doesn't Exist"].append(self.sys_path)
                return False

        if self.both_exists:
            if cmp(self.repo_path, self.sys_path):
                not_sync["The same"].append((self._f, self._t))
                return False

            if os.path.exists(self.sys_path):
                if not os.path.isfile(self.sys_path):
                    not_sync["Different Type"].append((self._f, self._t))
                    return False

        if self.both_exists:
            f_stat = os.stat(self._f)
            t_stat = os.stat(self._t)
            if f_stat.st_mtime < t_stat.st_mtime:
                not_sync["Override the newer"].append((self._f, self._t))
                return False

        return True


def recurse(action):
    for r, s in path_map.items():
        par_d = os.path.join(REPO_DIR, r)

        os.chdir(par_d)
        for dname, _, sub_files in os.walk('.'):
            if dname == '.':
                dname = ''
            if dname.startswith('./'):
                dname = re.match(r'\./(.*)', dname).group(1)

            for f in sub_files:
                repo_path = os.path.join(par_d, dname, f)
                sys_path = os.path.join(s, dname, f)

                if is_ignored(repo_path):
                    not_sync['Ignored Pattern'].append(repo_path)
                    continue
                item = Item(repo_path, sys_path, action)
                if item.is_valid():
                    t = item.get_sync_tuple()
                    if t:
                        sync_queue.append(t)

        os.chdir(REPO_DIR)


def main(action):
    recurse(action)
    # print('============================================')
    print('\nNot to be synchronized:')
    for t, es in not_sync.items():
        print('%s:' % (TAB + t))
        print(TAB, len(t) * '-')
        for e in es:
            if isinstance(e, (tuple, list)):
                e = '\t'.join(e)
            print(TAB*2, e)

    if sync_queue:
        print('\nTo be synchronized:')
        for _f, _t in sync_queue:
            print(TAB, _f, '-->', _t)
        ans = None
        print("\n\ty: copy all files"
              "\n\ti: ask each file before copy it"
              "\n\tn: cancel")
        ans = ask(YNI)
        if ans in ('y', 'i'):
            sync(ans)
        print(LINE)
        Status().display()

    if not_sync['Override the newer']:
        tool_ok = not os.system('command -v vimdiff > /dev/null 2>&1')
        if tool_ok:
            print('There are some files are ignored '
                  'becaulse of stat comparing.')
            ans = ask(YN, 'Edit these files with vimdiff?')
            if ans == 'y':
                for _f, _t in not_sync['Override the newer']:
                    msg = 'Edit %s and %s?' % (_f, _t)
                    ans = ask(YN, msg)
                    if ans == 'y':
                        os.system('vimdiff %s %s' % (_f, _t))


if __name__ == '__main__':
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        assert arg in ('update', 'apply')
        main(arg)
    else:
        print(prompt)
    print('DONE :)')
