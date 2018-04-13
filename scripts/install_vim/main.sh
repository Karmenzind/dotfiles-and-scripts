#! /usr/bin/env bash

sudo pacman -S gvim

# --------------------------------------------
# colors
# --------------------------------------------
colors_url=('https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim'
            'https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim')

color_dir=~/.vim/colors
mkdir -p $color_dir
for u in ${colors_url[*]}
do
    axel $u -o $color_dir
done

# --------------------------------------------
# plugins
# --------------------------------------------

# vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# ycm
echo 'Use script other than vundle to install YouCompleteMe?(y/n)'
read ans
case ans in
    Y|y) install_ycm.sh     ;;
    *)                      ;;
esac

# other plugins
vim +PluginInstall +qall

