# Github: https://github.com/Karmenzind/dotfiles-and-scripts

alias bpy bpython
alias l 'ls -lFh'
alias nv nvim
alias vi vim
alias ta 'tmux a -t'
alias gst 'git status'
alias mux tmuxinator
alias pacman 'pacman --disable-download-timeout'
alias toboard 'xclip -selection clipboard'

# function gst
# end

set -x EDITOR vim
set -x PAGER 'less -F'
set -x VISUAL $EDITOR

# pipx
set -x PIPX_HOME /opt/pipx
set -x PIPX_BIN_DIR /usr/local/bin
set -x PIPX_MAN_DIR /usr/local/share/man

# fzf
set -x FZF_TMUX 1
set -x FZF_TMUX_OPTS '-p 80%,60%'
if command -v 'fd' >/dev/null
    set -x FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
else if command -v 'rg' >/dev/null
    set -x FZF_DEFAULT_COMMAND "rg -. --sort path -l . -g '!.git/'"
else if command -v 'ag' >/dev/null
    set -x FZF_DEFAULT_COMMAND "ag --hidden --nocolor -U -g ''"
end

set -gx pure_show_system_time true
set -gx pure_separate_prompt_on_error false
set -gx pure_enable_single_line_prompt false
set -gx pure_show_prefix_root_prompt false

set config_dir (dirname (status -f))
if test -e $config_dir/local.fish
    source $config_dir/local.fish
end
