#! /usr/bin/env bash

clear
cd `dirname $0`
repo_dir=$PWD

source ./scripts/utils/commonrc

arch_choice() {
    cat << EOF
What part are you in? (default=1)
1   livecd part
2   chrooted part
3   general recommendations part
4   graphical environment part
EOF
    check_input 1234
    case $ans in 
        1) source ./scripts/install_arch/livecd_part.sh        ;;
        2) source ./scripts/install_arch/chrooted_part.sh      ;;
        3) source ./scripts/install_arch/general_rec_part.sh   ;;
        4) source ./scripts/install_arch/graphical_env_part.sh ;;
        *) echo "No action."                                   ;;
    esac
}

cat << EOF
What do you want to do? (default=1)
1   install ArchLinux
2   install recommended apps
3   install Vim
4   install Vim Plugin: YouCompleteMe
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
