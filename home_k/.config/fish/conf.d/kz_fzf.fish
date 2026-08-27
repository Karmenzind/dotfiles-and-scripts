# Github: https://github.com/Karmenzind/dotfiles-and-scripts
status is-interactive; or exit
type -q fzf; or exit

if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
else if type -q rg
    set -gx FZF_DEFAULT_COMMAND "rg -. --sort path -l . -g '!.git/'"
else if type -q ag
    set -gx FZF_DEFAULT_COMMAND "ag --hidden --nocolor -U -g ''"
end
set -q FZF_DEFAULT_COMMAND; and set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

set -gx FZF_DEFAULT_OPTS "--bind 'ctrl-/:toggle-preview' --inline-info --height 50% --reverse --border=horizontal --preview-window=down:50%:hidden --color fg:yellow,fg+:bright-yellow"

# Set FZF_TMUX / FZF_TMUX_OPTS only when fzf-tmux exists. Either variable is an
# instruction to shell out to fzf-tmux inside tmux, and fzf does not verify the
# command is installed; unconditional values break the widgets instead of
# falling back to plain fzf. The zsh side learned this the hard way -- see
# docs/unix-shell-config.md. The pre-2026 config.fish had exactly this bug.
if type -q fzf-tmux
    set -gx FZF_TMUX 1
    set -gx FZF_TMUX_OPTS '-p 80%,60%'
else
    set -e FZF_TMUX
    set -e FZF_TMUX_OPTS
end

# fzf.fish reads its own fzf_* variables. FZF_CTRL_T_OPTS and FZF_CTRL_R_OPTS
# are bash/zsh shell-integration knobs and have no effect here.
#
# Do NOT add `fzf --fish | source`: fzf.fish is the sole integration, and
# running both installs the same bindings twice. This is the fish analogue of
# the zsh double-init rule in docs/unix-shell-config.md.
set -g fzf_history_time_format '%F %T'
set -g fzf_fd_opts --hidden --exclude=.git
if type -q bat
    set -g fzf_preview_file_cmd 'bat --color=always --style=snip --theme=GitHub --line-range :40'
end
if type -q eza
    set -g fzf_preview_dir_cmd 'eza --all --color=always'
else
    set -g fzf_preview_dir_cmd 'ls -A --color=always'
end
if type -q delta
    set -g fzf_diff_highlighter 'delta --paging=never --width=80'
end
