#! /usr/bin/env bash

sudo pacman -S gvim

echo 'Need YouCompleteMe?(y/n)'
read ans

case ans in
    Y|y) install_ycm.sh     ;;
    *)                      ;;
esac

vim +PluginInstall

