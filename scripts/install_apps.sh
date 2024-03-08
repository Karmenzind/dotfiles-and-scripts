#! /usr/bin/env bash
# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Last Modified: 2024-01-18 16:20:34

# Mainly for ArchLinux
# Partially support Debian-based system

if [[ -z $__loaded_commonrc ]]; then
	cd $(dirname $0)
	source $PWD/utils/commonrc
fi

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
	wqy-zenhei
	noto-fonts-emoji
	# otf-fira-mono
	# ttf-anonymous-pro
	# ttf-arphic-ukai
	# ttf-arphic-uming
	# ttf-fira-mono
	# ttf-freefont
	# ttf-gentium
	# ttf-hack
	# ttf-hannom
	# ttf-inconsolata
	# ttf-linux-libertine
	# wqy-bitmapfont
)

_cli=(
    brightnessctl
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
	github-cli
	go
	miniconda
	neofetch
	nginx
	nodejs
	npm
	p7zip
	plocate
	python-isort
	python-pip
	python-pylint
	python-pynvim
	python-rope
	python3
	screenfetch
	scrot
	the_silver_searcher
	tig
	unrar
	w3m
	xclip
	xsel
	youtube-dl
	zsh
	fish
	jq

	# system service
	udiskie

	# language server
	marksman
	taplo-cli
)

_desktop=(
	# libreoffice
	# fbreader
	# thunderbird
	# chromium
	alacritty
	picom
	rofi
	geeqie
	lxappearance
	pcmanfm
	volumeicon
	polybar
	xfce4-terminal
	flameshot
	remmina
	typora
	pycharm-community-edition
	# github-desktop-bin
)

_aur=(
	# electronic-wechat
	# apvlv
	# crossover
	# teamviewer
	emojify
	sqlint
	acroread
	acroread-fonts

	ttf-monaco-nerd-font-git
)

_themes=(
	xcursor-simpleandsoft
	papirus-icon-theme
)
_aur_themes=(
	vertex-themes
	paper-gtk-theme-git
	paper-icon-theme-git
)

_required_by_vim=(
	flake8
	autopep8
	prettier
	ack
)

_required_by_vim_aur=(
	# gitlint
	shfmt
	sqlint
	python-proselint
)

# pip
_py_general=(
	bpython
)

# --------------------------------------------
# Manually install
# --------------------------------------------
git_pull_head() {
	git pull origin $(git rev-parse --abbrev-ref HEAD)
}

# manually install pkg from aur
# $1    the app to install
install_aur_app() {
	local aur_tmp=/tmp/_my_aur
	[[ -z "$1" ]] && exit_with_msg "Invalid argument: $1"
	local app=$1
	if cmd_not_found git; then
		if !do_install git; then
			echo_warn "Failed to install git."
		fi
	fi

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
	do_install 'go' && install_aur_app 'yay'
}

install_nerd_fonts() {
	echo_run "Install monaco nerd font? (Y/n)"
	! check_yn && return

	local target_dir='/usr/share/fonts/nerd'
	local _tmp='/tmp/monaco-nerd-fonts'
	sudo mkdir -p $target_dir
	ls ${target_dir}/*Monaco* >/dev/null 2>&1 && echo_run 'Monaco Nerd Fonts already exists.' && return
	git clone https://github.com/Karmenzind/monaco-nerd-fonts $_tmp
	cd $_tmp/fonts && rm -rf *Windows* && sudo cp ./*tf $target_dir
	cd ~
	rm -rf $_tmp
}

install_ranger_and_plugins() {
	echo_run "Install ranger and plugins? (Y/n)"
	! check_yn && return

	# ranger and basic config
	if do_install ranger; then
		ranger --copy-config=all
		# devicons
		local clonedir=/tmp/ranger_devicons
		[[ -d $clonedir ]] && rm -rf $clonedir
		git clone https://github.com/alexanderjeurissen/ranger_devicons $clonedir
		cd $clonedir
		make install
		cd ~
		rm -rfv $clonedir
	else
		echo_warn "Failed to install ranger"
	fi

}

install_wudao_dict() {
	echo_run "Install wudao-dict? (Y/n)"
	! check_yn && return

	command -v 'pip' >/dev/null 2>&1 || do_install 'python-pip'
	# sudo pip install bs4 lxml requests
	local target_dir="$HOME/.local/wudao-dict"
	if [[ -d "$target_dir" ]]; then
		echo_run "Delete ${target_dir} and continue?"
		[[ ! $ans = 'y' ]] && return
		rm -rf $target_dir
	fi
	git clone https://github.com/chestnutheng/wudao-dict $target_dir --depth=1
	cd $target_dir/wudao-dict
	sudo bash setup.sh
}

install_officials() {
	echo_run "Install offcial apps with pacman? (Y/n)"
	! check_yn && return

	do_install ${_basic[*]}
	do_install ${_fonts[*]}
	do_install ${_cli[*]}
	do_install ${_desktop[*]}
	do_install ${_themes[*]}
	# do_install ${_required_by_vim[*]}
	sudo pacman -Sc
}

auri() {
	$aur_helper -S -v --needed --noconfirm ${@}
}

install_aurs() {
	aur_helper=yay
	echo_run "Install apps from AUR with $aur_helper? (Y/n)"
	! check_yn && return

	install_yay
	$aur_helper -S -v --needed --noconfirm ${_aur[*]}
	$aur_helper -S -v --needed --noconfirm ${_aur_themes[*]}
	# $aur_helper -S -v --needed --noconfirm ${_required_by_vim_aur[*]}
	$aur_helper -Sc
}

install_fcitx() {
	aur_helper=yay
	echo_run "Install fcitx and Chinese input method? (Y/n)"
	! check_yn && return

	# do_install fcitx fcitx-im fcitx-configtool fcitx-sunpinyin fcitx-cloudpinyin

	do_install fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-gtk fcitx5-material-color fcitx5-nord fcitx5-pinyin-zhwiki fcitx5-qt

	# TODO (k): <2023-04-06> update charactor config
}

install_zsh_plugin() {
	local name=$1
	local url=$2
	echo_run "Install/Update zsh plugin: ${name}? (Y/n)"
	! check_yn && return

	local targetdir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/${name}

	if [[ -d $targetdir ]]; then
		cd $targetdir
		git_pull_head
		cd -
	else
		git clone $url $targetdir
	fi
}

install_ohmyzsh() {
	echo_run "Install ohmyzsh? (Y/n)"
	! check_yn && return

	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_kd() {
	echo_run "Install kd? (Y/n)"
	! check_yn && return

	sh -c "$(curl -fsSL https://raw.githubusercontent.com/Karmenzind/kd/master/scripts/install.sh)"
}

install_zsh_stuff() {
	echo_run "Install ohmyzsh and plugins? (Y/n)"
	! check_yn && return

	install_ohmyzsh
	install_zsh_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
	install_zsh_plugin conda-zsh-completion https://github.com/esc/conda-zsh-completion
	install_zsh_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
}

setup_bluetooth() {
	echo_run "Setup bluetooth? (Y/n)"
	! check_yn && return

    do_install bluez bluez-utils
    systemctl enable --now bluetooth.service

}

pwsh_run() {
	pwsh -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "$@" && echo_ok "Finished installing ${@}"
}

setup_pwsh() {
	echo_run "Install and setup powershell? (Y/n)"
	! check_yn && return

    if command -v pwsh; then
        echo_ok "pwsh is already installed"
    elif [[ $distro == arch ]]; then
        auri powershell-bin
        auri oh-my-posh-bin
    else
		echo_warn "You should manually install pwsh"
    # elif command -v apt >/dev/null; then
		# echo_warn "No pacman/apt. Ignored pwsh installation."
    fi

}

# --------------------------------------------

install_apt_recommandations() {
	echo_run "Install recommandations via apt-get? (Y/n)"
	! check_yn && return

	# basic
	! [[ -e /etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable-jammy.list ]] && sudo add-apt-repository ppa:neovim-ppa/unstable
	apti git python3 python3-pip vim neovim tmux command-not-found wget curl unzip
	# apti golang

	# tools
	apti ripgrep fzf axel universal-ctags jq httpie
	! is_wsl && apti docker

	! [[ -e /etc/apt/sources.list/nodesource.list ]] && curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash -
	apti nodejs npm

	# (n)vim related
	apti python3-neovim
}

install_dnf_recommentations() {
	echo_warn "WIP"
}

setup_fish() {
	cmd_not_found fish && do_install fish && chsh $(which fish)
}

# --------------------------------------------

if [[ $distro == arch ]]; then
	install_officials
	install_aurs
	install_fcitx
else
	if command -v apt >/dev/null; then
		install_apt_recommandations
	else
		echo_warn "No pacman/apt. Ignored pkg installation."
	fi

	install_nerd_fonts
fi

# --------------------------------------------

install_ranger_and_plugins
install_zsh_stuff
setup_pwsh

setup_bluetooth
