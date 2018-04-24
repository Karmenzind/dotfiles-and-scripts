#! /usr/bin/env bash

# delete the app you don't need
source ../utils/commonrc

_basic=(
    axel
    curl
    elinks
    git
    tar
    tmux
    vim
    wget
)

# basic Chinese fonts
_fonts=(
    adobe-source-code-pro-fonts
    adobe-source-han-sans-cn-fonts
    adobe-source-han-serif-cn-fonts
    opendesktop-fonts 
    otf-fira-mono
    ttf-anonymous-pro
    ttf-arphic-ukai
    ttf-arphic-uming 
    ttf-fira-mono
    ttf-freefont
    ttf-gentium
    ttf-hack
    ttf-hannom
    ttf-inconsolata
    ttf-linux-libertine
    wqy-bitmapfont
    wqy-zenhei
)

_cli=(
    #conky
    arandr
    aria2
    compton
    cronie
    docker
    dunst
    feh
    go
    mlocate
    neofetch
    nginx
    npm
    p7zip
    python2
    python2-pip
    python3
    python3-pip
    rabbitmq
    ranger
    screenfetch
    shadowsocks
    tig
    unrar
    youtube-dl
)
_desktop=(
    xfce4-terminal
    chromium
    fbreader
    libreoffice
    thunar 
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-volman
    thunderbird
    volumeicon
)

_aur=(
    #wewechat
    acroread
    acroread-fonts
    apvlv
    crossover
    electronic-wechat
    teamviewer
    wps-office
)

# $1 install cmd
# $2 apps
#install_apps () {
#    cmd=$1    
#    while [[ -n "$2" ]]; do
#        $cmd $2      
#        shift
#    done
#}

[[ "$1" == '-y' ]] && tag='--noconfirm'

sudo pacman -Syu -v --needed $tag ${_basic[*]} ${_fonts[*]} ${_cli[*]} ${_desktop[*]}
pacman -Sc $tag
# yaourt -S -v --needed $tag ${_aur[*]}
# yaourt -Sc
