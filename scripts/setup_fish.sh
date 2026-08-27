#! /usr/bin/env bash
# Github: https://github.com/Karmenzind/dotfiles-and-scripts

if [[ -z $__loaded_commonrc ]]; then
	cd "$(dirname "$0")"
	source "$PWD/utils/commonrc"
fi

# install.sh exports repo_dir; fall back when this script is run directly.
if [[ -z $repo_dir ]]; then
	repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fi

FISH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"

install_fish() {
	# fish 4.x is required: fzf.fish v11+ and pure v4.13+ both dropped fish 3.x.
	local ver
	ver=$(fish --version 2>/dev/null | grep -oE '[0-9]+' | head -n1)
	if [[ -n $ver && $ver -ge 4 ]]; then
		echo_ok "fish $ver is already installed"
		return 0
	fi

	if [[ -n $ver ]]; then
		echo_warn "fish $ver is too old; this configuration needs fish 4.x."
	fi

	echo_run "Installing fish 4.x..."
	do_install fish || {
		echo_warn "Failed to install fish."
		return 1
	}
}

install_fisher() {
	if fish -c 'functions --query fisher' 2>/dev/null; then
		echo_ok "fisher is already installed"
		return 0
	fi

	echo_run "Installing fisher..."
	fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
}

symlink_fish_files() {
	echo_run "Create symlinks for fish configuration files? (Y/n)"
	! check_yn && return

	if command -v python3 >/dev/null; then
		python3 "$repo_dir/symlink.py" --fishonly
	else
		echo_warn "python3 is not available; run symlink.py --fishonly manually."
	fi
}

clean_stale_fish_files() {
	# nvm.fish contradicts the fnm-only rule in AGENTS.md. Deleting the line from
	# fish_plugins is not enough: fisher tracks installed files in the universal
	# _fisher_<plugin>_files variable and only `fisher remove` cleans them up.
	if fish -c 'contains jorgebucaran/nvm.fish $_fisher_plugins' 2>/dev/null; then
		echo_run "Remove the nvm.fish plugin (this repo manages Node.js with fnm)? (Y/n)"
		check_yn && fish -c 'fisher remove jorgebucaran/nvm.fish'
	fi

	if [[ -f "$FISH_CONFIG_DIR/conf.d/conda.fish" ]]; then
		echo_warn "$FISH_CONFIG_DIR/conf.d/conda.fish exists; conda is not managed by this repo."
		echo_run "Remove it? (Y/n)"
		check_yn && rm -f "$FISH_CONFIG_DIR/conf.d/conda.fish"
	fi

	# A hand-written fish_user_key_bindings would shadow conf.d/kz_keys.fish and,
	# if it runs `fzf --fish | source`, install the fzf bindings a second time.
	local ukb="$FISH_CONFIG_DIR/functions/fish_user_key_bindings.fish"
	if [[ -f $ukb && ! -L $ukb ]]; then
		echo_warn "$ukb is now owned by conf.d/kz_keys.fish."
		echo_run "Back it up and remove it? (Y/n)"
		check_yn && mv "$ukb" "${ukb}.backup_$(date +%Y%m%d_%H%M)"
	fi
}

install_fish_plugins() {
	echo_run "Install fish plugins listed in fish_plugins? (Y/n)"
	! check_yn && return

	fish -c 'fisher update'
}

install_fish || return 2>/dev/null || exit 1
install_fisher
symlink_fish_files
clean_stale_fish_files
install_fish_plugins

echo_ok "fish is configured. Start a new fish session to pick it up."
echo_warn "fish is NOT set as the login shell. Run 'chsh -s \$(command -v fish)' yourself if you want that."
