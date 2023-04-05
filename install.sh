#! /usr/bin/env bash
# https://github.com/Karmenzind/

clear
cd `dirname $0`
repo_dir=$PWD

source ./scripts/utils/commonrc

cat << EOF

What do you want to do? (default=1)
1   install recommended apps (ArchLinux only)
2   install Vim and Neovim and my configuration (ArchLinux only)
3   install Vim Plugin: YouCompleteMe
EOF
check_input 123
case $ans in
    1) source ./scripts/install_apps.sh     ;;
    2) source ./scripts/install_vim/main.sh ;;
    3) source ./scripts/install_vim/ycm.sh  ;;
    *) echo "No action."                    ;;
esac

cecho '\nDONE:)' $cyan
