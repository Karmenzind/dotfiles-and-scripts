#! /usr/bin/env bash

# delete the app you don't need

# --------------------------------------------
# apps
# --------------------------------------------

_basic=(
    axel
    curl
    elinks
    git
    tar
    tmux
    #vim # replace with gvim in graphical env
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
    arandr
    aria2
    conky
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
    python-pip
    rabbitmq
    screenfetch
    scrot
    shadowsocks
    tig
    fzf
    unrar
    xclip
    xsel
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
    lxappearance
)

_themes=(
    xcursor-simpleandsoft
    ark-icon-theme
    papirus-icon-theme
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
    bmenu
)

_aur_themes=(
    vertex-themes
    paper-gtk-theme-git
    paper-icon-theme-git
)


# --------------------------------------------
# Plugins
# --------------------------------------------

install_ranger_and_plugins () {
    # ranger and basic config
    sudo pacman -S --need ranger
    ranger --copy-config=all

    # devicons
    clonedir=/tmp/ranger_devicons
    [[ -d $clonedir ]] && rm -rf $clonedir
    git clone https://github.com/alexanderjeurissen/ranger_devicons $clonedir
    cd $clonedir
    make install
    cd -
    rm -rf $clonedir
}

# --------------------------------------------

[[ "$1" == '-y' ]] && tag='--noconfirm'

# official
sudo pacman -S --needed $tag ${_basic[*]} ${_fonts[*]} ${_cli[*]} ${_desktop[*]} ${_themes[*]}
sudo pacman -Sc $tag
pacman -Sc

# aur
yaourt -S -v --needed $tag ${_aur[*]} ${_aur_themes[*]}
yaourt -Sc

install_ranger_and_plugins

