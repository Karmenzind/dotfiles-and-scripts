#! /usr/bin/env bash

repo_dir=$PWD
scripts_dir=./scripts

echo "What do you want to do?"
cat << EOF
1   install ArchLinux
2   install recommended apps
3   install Vim
4   install Vim Plugin: YouCompleteMe
EOF
display_array ${choices[*]}
check_input 1234

arch_choice () {
    case $ans in 
        1) ./scripts/install_arch/livecd_part.sh
            ;;
        2) ./scripts/install_arch/chrooted_part.sh
            ;;
        3) ./scripts/install_arch/general_rec_part.sh
            ;;
        4) ./scripts/install_arch/graphical_env_part.sh
            ;;
        *) echo "No action." ;;
    esac
}

case $ans in
    1)  echo "What part are you in?"
        cat << EOF
1   livecd part
2   chrooted part
3   general recommendations part
4   graphical environment part
EOF
        display_array ${install_arch_choices[*]}
        check_input 1234
        arch_choice
        ;;
    2)  ./scripts/install_apps.sh
        ;;
    3)  ./scripts/install_vim/main.sh
        ;;
    4)  ./scripts/install_vim/ycm.sh
        ;;
    *) echo "No action." ;;
esac

echo 'DONE:)'
