#! /usr/bin/env bash
# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Last Modified: 2024-01-18 16:18:16

cd $(dirname $0)
repo_dir=$PWD

distro=$(cat /etc/os-release | grep '^ID=' | sed 's/ID=//')

source ./scripts/utils/commonrc

echo_run "What do you want to do? (default=1)"

cat <<EOF

1)   install recommended apps
2)   setup Vim/Neovim and configuration files
3)   symlink all configuration files
EOF
check_input 123
case $ans in
    1)
        source ./scripts/install_apps.sh
        source ./scripts/setup_vim.sh
        ;;
    2) source ./scripts/setup_vim.sh ;;
    3) python3 symlink.py ;;
    *) echo "No action." ;;
esac

echo_ok 'DONE :)' $cyan
