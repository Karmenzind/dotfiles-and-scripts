#! /usr/bin/env bash
# https://github.com/Karmenzind/

clear
cd `dirname $0`
repo_dir=$PWD

source ./scripts/utils/commonrc

cat << EOF

What do you want to do? (default=1)
1   install recommended apps
2   install Vim/Neovim and my configuration
3   symlink configuration files
EOF
check_input 12
case $ans in
    1) source ./scripts/install_apps.sh     ;;
    2) source ./scripts/install_vim/main.sh ;;
    3) python symlink.py                    ;;
    *) echo "No action."                    ;;
esac

cecho '\nDONE:)' $cyan

