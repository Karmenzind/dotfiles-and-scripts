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
	elif is_macos; then
		do_install vim neovim curl
	elif command -v apt >/dev/null; then
		! [[ -e /etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable-jammy.list ]] && sudo add-apt-repository ppa:jonathonf/vim
		apti vim neovim curl
	else
		echo_warn "No supported package manager. You should manually install vim/nvim."
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

	if command -v pnpm >/dev/null; then
		echo_run "Installing JavaScript/SQL tools with pnpm..."
		pnpm add -g prettier pg-formatter eslint sqlint
	else
		echo_warn "pnpm is not available. Run scripts/install_apps.sh to enable pnpm through corepack."
	fi

	if [[ $distro == "arch" ]]; then
        # FIXME
		$aur_helper -S -v --needed --noconfirm ${_required_by_vim_aur[*]}
	elif is_macos; then
		do_install shfmt clang-format
	else
		do_install shfmt clang-format
	fi

    if [[ $distro == "arch" ]]; then
		do_install stylua
	elif is_macos; then
		do_install stylua
	elif command -v cargo >/dev/null; then
		cargo install stylua
    else
		echo_warn "stylua is not available. Install Rust/Cargo or install stylua manually."
	fi

	if command -v go >/dev/null; then
		echo_run "Installing golang fixers..."
		go install golang.org/x/tools/cmd/goimports@latest
	else
		echo_run "Golang is not installed. Ignored go pkgs."
	fi

	if ! command -v uv >/dev/null; then
		echo_warn "uv is not available. Run scripts/install_apps.sh to install Python CLI tools."
		return
	fi

	local uv_tools=(
		isort
		autopep8
		autoflake
		black
		pydocstyle
		flake8
		markdown-live-preview
	)

	for tool in ${uv_tools[*]}; do
		if command -v $tool >/dev/null; then
			echo_run "Ignored existed: $tool"
		else
			echo_run "Installing uv tool: $tool"
			uv tool install $tool
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
