#! /usr/bin/env bash

no_root

sudo pacman -S gvim --needed 

# --------------------------------------------
# colors
# --------------------------------------------

color_dir=~/.vim/colors

colors_url=('https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim'
            'https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim')

mkdir -p $color_dir
for u in ${colors_url[*]}
do
    fname="$color_dir/`echo $colors_url | sed 's/.*\///g'`"
    [[ ! -e $fname ]] && axel $u -o $color_dir
done

# --------------------------------------------
# plugins
# --------------------------------------------

restore_my_vim () {
    cp $repo_dir/vim/.vimrc ~/.vimrc
    cat << EOF
PlugInstall will start right now.
If it fails on YouCompleteMe,
you may need to execute install.sh
and try 'install Vim Plugin: YouCompleteMe' 
EOF
    read -p "Type any key to continue" whatever
    vim +PlugInstall +qall
}

echo "Do you want to use my .vimrc? (Y/n)"
check_input yn
if [[ $ans = 'y' ]]; then
    restore_my_vim
fi
