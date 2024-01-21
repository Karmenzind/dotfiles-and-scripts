#! /usr/bin/env bash
# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Last Modified: 2024-01-18 16:21:26

if [[ -z $__loaded_commonrc ]]; then
	cd $(dirname $0)
	source $PWD/utils/commonrc
fi

install_n_vim() {
	if command -v nvim >/dev/null && command -v nvim >/dev/null; then
		echo_ok "Vim and NVim are already installed"
		return
	fi

	if [[ $distro == arch ]]; then
		do_install vim neovim curl
	elif command -v apt >/dev/null; then
		! [[ -e /etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable-jammy.list ]] && sudo add-apt-repository ppa:jonathonf/vim
		apti vim neovim curl
	else
		echo_warn "No pacman/apt. You should manually install vim/nvim."
	fi

	local plugpath=~/.vim/autoload/plug.vim
	if ! [[ -e $plugpath ]]; then
		echo_run "Installing vim-plug"
		curl -fLo $plugpath --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	fi
}

install_vim_specs() {
	echo_run "Install related apps (linters, fixers, etc.) for (n)vim? (Y/n)"
	! check_yn && return

	# linters
	sudo npm i -g sqlint

	# fixers
	sudo npm i -g prettier pg-formatter gofmt clang-format eslint

	if [[ $distro == "arch" ]]; then
		$aur_helper -S -v --needed --noconfirm ${_required_by_vim_aur[*]}
	else
		do_install shfmt
	fi

	if command -v cargo >/dev/null; then
		sudo cargo install stylua
	else
		sudo npm i -g @johnnymorganz/stylua-bin
	fi

	if command -v go >/dev/null; then
		echo_run "Installing golang fixers..."
		sudo go install golang.org/x/tools/cmd/goimports@latest
	else
		echo_run "Golang is not installed. Ignored go pkgs."
	fi

	cmd_not_found pipx && setup_pipx
	local pipx_pkgs=(
		isort
		autopep8
		autoflake
		black
		pydocstyle
		flake8
		markdown_live_preview
	)

	for pi in ${pipx_pkgs[*]}; do
		if command -v $pi >/dev/null; then
			echo_run "Ignored existed: $pi"
		else
			echo_run "Installing python package $pi"
			pipx_install $pi
		fi
	done
}

symlink_files() {
	echo_run "Create symlinks for vim configuration files? (Y/n)"
	! check_yn && return

	echo_run "Start sync vim/nvim config files"
	if command -v python3 >/dev/null; then
		python3 $repo_dir/symlink.py --vimonly
	else
		ls -s $(realpath ${repo_dir}/home_k/.vim/coc-settings.json) $(realpath ~/.vim/coc-settings.json)
		ls -s $(realpath ${repo_dir}/home_k/.vim/mysnippets) $(realpath ~/.vim/mysnippets)
		ls -s $(realpath ${repo_dir}/home_k/.vimrc) $(realpath ~/.vimrc)
		ls -s $(realpath ${repo_dir}/home_k/.config/nvim/init.lua) $(realpath ~/.config/nvim/init.lua)
		echo_ok "already created symlinks"
	fi
}

install_n_vim
symlink_files

echo_run "Install Vim plugins? (Y/n)"
check_yn && vim +PlugInstall +qall

echo_run "Install Neovim plugins (Y/n)?"
check_yn && nvim +PlugInstall +qall

install_vim_specs
