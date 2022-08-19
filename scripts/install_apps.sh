#! /usr/bin/env bash
# https://github.com/Karmenzind/

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
    noto-fonts-emoji
)

_cli=(
    # rabbitmq
    # screenfetch
    w3m
    github-cli
    the_silver_searcher
    tig
    clash
    trojan
    arandr
    aria2
    bat
    conky
    cowsay
    cronie
    docker
    docker-compose
    dos2unix
    dunst
    feh
    fortune-mod
    fzf
    go
    mlocate
    neofetch
    nginx
    nodejs
    npm
    p7zip
    python-isort
    python-pip
    python-pylint
    python-pynvim
    python-rope
    python2
    python2-pip
    python3
    scrot
    shadowsocks
    tig
    unrar
    xclip
    xsel
    youtube-dl
    zsh
)

_desktop=(
    # thunar 
    # thunar-archive-plugin
    # thunar-media-tags-plugin
    # thunar-volman
    # libreoffice
    # fbreader
    # thunderbird
    compton
    rofi
    geeqie
    chromium
    lxappearance
    pcmanfm
    volumeicon
    polybar
    xfce4-terminal
    flameshot
    github-desktop-bin
    alacritty
    pycharm-community-edition
    remmina
    typora
)

_aur=(
    # wewechat
    # wps-office
    # bmenu
    # electronic-wechat
    # apvlv
    # crossover
    # teamviewer
    # oh-my-zsh-git
    emojify
    sqlint
    acroread
    acroread-fonts
    netease-cloud-music
)

# appearance
_themes=(
    xcursor-simpleandsoft
    # ark-icon-theme
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
    #gitlint
    #python-vint
    shfmt
    sqlint
    python-proselint
)

# pip
_py_general=()


# --------------------------------------------
# Manually install
# --------------------------------------------

# manually install pkg from aur
# $1    the app to install
install_aur_app() {
    local aur_tmp=/tmp/_my_aur
    [[ -z "$1" ]] && exit_with_msg "Invalid argument: $1"
    local app=$1
    do_install git

    mkdir -p $aur_tmp 
    cd $aur_tmp 
    git clone "https://aur.archlinux.org/${app}.git" $app 
    cd $app 
    makepkg -sri --noconfirm
    cd ~
    rm -rf $aur_tmp
}

install_yay() {
    command -v yay >/dev/null && return
    do_install 'go'
    install_aur_app 'yay'
}

install_yaourt() {
    command -v yaourt >/dev/null && return
    install_aur_app 'package-query'
    install_aur_app 'yaourt'
}

install_nerd_fonts() {
    echo "Install monaco nerd font? (Y/n)"
    check_input yn
    [[ ! $ans = 'y' ]] && return

    local target_dir='/usr/share/fonts/nerd'
    local _tmp='/tmp/monaco-nerd-fonts'
    sudo mkdir -p $target_dir
    ls ${target_dir}/*Monaco* >/dev/null 2>&1 && echo 'Monaco Nerd Fonts already exists.' && return
    git clone https://github.com/Karmenzind/monaco-nerd-fonts $_tmp
    cd $_tmp/fonts && rm -rf *Windows* && sudo cp ./*tf $target_dir 
    cd ~
    rm -rf $_tmp
}

install_ranger_and_plugins() {
    echo "Install ranger and plugins? (Y/n)"
    check_input yn
    [[ ! $ans = 'y' ]] && return

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
}

install_wudao_dict() {
    echo "Install wudao-dict? (Y/n)"
    check_input yn
    [[ ! $ans = 'y' ]] && return

    command -v 'pip' > /dev/null 2>&1 || do_install 'python-pip'
    # sudo pip install bs4 lxml requests
    local target_dir="$HOME/.local/wudao-dict"
    if [[ -d "$target_dir" ]]; then
        echo "Delete ${target_dir} and continue?"
        [[ ! $ans = 'y' ]] && return
        rm -rf $target_dir
    fi
    git clone https://github.com/chestnutheng/wudao-dict $target_dir --depth=1
    cd $target_dir/wudao-dict
    sudo bash setup.sh
}

install_officials() {
    echo "Install offcial apps with pacman? (Y/n)"
    check_input yn
    [[ ! $ans = 'y' ]] && return

    do_install ${_basic[*]} 
    do_install ${_fonts[*]} 
    do_install ${_cli[*]} 
    do_install ${_desktop[*]} 
    do_install ${_themes[*]} 
    do_install ${_required_by_vim[*]}
    sudo pacman -Sc 
}

install_aurs() {
    aur_helper=yay
    echo "Install apps from AUR with $aur_helper? (Y/n)"
    check_input yn
    [[ ! $ans = 'y' ]] && return

    install_yay
    $aur_helper -S -v --needed --noconfirm ${_aur[*]} 
    $aur_helper -S -v --needed --noconfirm ${_aur_themes[*]} 
    $aur_helper -S -v --needed --noconfirm ${_required_by_vim_aur[*]}
    $aur_helper -Sc
}

# TODO
install_fcitx() {
    aur_helper=yay
    echo "Install fcitx and Chinese input method? (Y/n)"
    check_input yn
    [[ ! $ans = 'y' ]] && return

    # fcitx4
    # do_install fcitx fcitx-im fcitx-configtool fcitx-sunpinyin fcitx-cloudpinyin

    do_install fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-gtk fcitx5-material-color fcitx5-nord fcitx5-pinyin-zhwiki fcitx5-qt
}


install_zsh_autosuggestions() {
    if command -v zsh; then
        echo "Install fcitx and Chinese input method? (Y/n)"
        check_input yn
        [[ ! $ans = 'y' ]] && return

        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
}

# --------------------------------------------

# official
install_officials
# aur
install_aurs
# others
install_ranger_and_plugins
install_wudao_dict
install_nerd_fonts
install_fcitx
install_zsh_autosuggestions

