#! /usr/bin/env bash

# delete the app you don't need

# --------------------------------------------
# apps
# --------------------------------------------

_basic=(
    #vim # replace with gvim in graphical env
    arch-install-scripts
    axel
    curl
    elinks
    git
    tar
    tmux
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
    fortune-mod
    cowsay
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
    zsh
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

# appearance
_themes=(
    xcursor-simpleandsoft
    ark-icon-theme
    papirus-icon-theme
)
_aur_themes=(
    vertex-themes
    paper-gtk-theme-git
    paper-icon-theme-git
)

# vim 
_required_by_vim=(
    flake8    
    autopep8
    prettier
    ack
)
_required_by_vim_aur=(
    shfmt
    #gitlint
    sqlint
    python-proselint
    python-vint
)

# pip
_py_general=()


# --------------------------------------------
# Mannualy install
# --------------------------------------------

install_yaourt() {
    which yaourt >/dev/null && return
    aur_tmp=/tmp/_my_aur
    do_install git
    local _yaourt_requirements=(package-query yaourt)

    mkdir -p $aur_tmp 
    for app in ${_yaourt_requirements[*]}; do
        cd $aur_tmp 
        git clone "https://aur.archlinux.org/${app}.git" $app
        cd $app
        makepkg -sri --noconfirm
    done
    cd ~
    rm -rf $aur_tmp
}

install_nerd_fonts() {
    local target_dir='/usr/share/fonts/nerd'
    local _tmp='/tmp/monaco-nerd-fonts'
    sudo mkdir -p $target_dir
    ls ${target_dir}/*Monaco* >/dev/null 2>&1 && echo 'Monaco Nerd Fonts already exists.' && return
    git clone https://github.com/Karmenzind/monaco-nerd-fonts $_tmp
    cd $_tmp/fonts && rm -rf *Windows* && sudo cp ./*tf $target_dir 
    cd ~
    rm -rf $_tmp
}

install_ranger_and_plugins () {
    echo "Install ranger and plugins? (Y/n)"
    check_input yn
    if [[ $ans = 'y' ]]; then
        # ranger and basic config
        do_install ranger
        ranger --copy-config=all
        # devicons
        local clonedir=/tmp/ranger_devicons
        [[ -d $clonedir ]] && rm -rf $clonedir
        git clone https://github.com/alexanderjeurissen/ranger_devicons $clonedir
        cd $clonedir
        make install
        cd ~
        rm -rf $clonedir
    fi
}

# --------------------------------------------

# official
do_install ${_basic[*]} ${_fonts[*]} ${_cli[*]} ${_desktop[*]} ${_themes[*]} ${_required_by_vim[*]}
sudo pacman -Sc 

# aur
install_yaourt  
yaourt -S -v --needed --noconfirm ${_aur[*]} ${_aur_themes[*]} ${_required_by_vim_aur[*]}
yaourt -Sc

# others
install_ranger_and_plugins
install_nerd_fonts

