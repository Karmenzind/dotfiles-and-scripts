#! /usr/bin/env bash
# https://github.com/Karmenzind/

clear
cd `dirname $0`
repo_dir=$PWD

source ./scripts/utils/commonrc

cat << EOF
What do you want to do? (default=1)
1   install recommended apps (ArchLinux only)
2   install Vim
3   install Vim Plugin: YouCompleteMe
EOF
check_input 1234
case $ans in
    1) arch_choice                          ;;
    2) source ./scripts/install_apps.sh     ;;
    3) source ./scripts/install_vim/main.sh ;;
    4) source ./scripts/install_vim/ycm.sh  ;;
    *) echo "No action."                    ;;
esac

cecho '\nDONE:)' $cyan
