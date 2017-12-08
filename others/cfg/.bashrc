# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# -----------------------------------------------------------------------------
# basic
# -----------------------------------------------------------------------------

export PATH="$PYENV_ROOT/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)" >/dev/null 2>&1

export PS1="
\u@local \t > \w
 \$ "

# -----------------------------------------------------------------------------
# terminal
# -----------------------------------------------------------------------------

export TERMINAL=tilix
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

# -----------------------------------------------------------------------------
# for ssh
# -----------------------------------------------------------------------------

export s15=klicen@172.16.6.15
export s16=klicen@172.16.6.16
export s31=klicen@192.168.1.31
export s83=klicen@192.168.1.83
export s88=klicen@192.168.1.88
export s89=klicen@192.168.1.89
export s92=klicen@192.168.1.92
export s93=klicen@192.168.1.93
export s99=klicen@192.168.1.99
export steq=' -p 3022 k@localhost'

# -----------------------------------------------------------------------------
# prompt
# -----------------------------------------------------------------------------

# `warriartask` required
task +work

# -----------------------------------------------------------------------------
# common aliases
# -----------------------------------------------------------------------------

# vim with access to system clipboard
alias vim=vimx
# File Manager
alias nautilus='nohup nautilus . >/dev/null & 2>&1'
alias work='task +work'
alias i3lock='i3lock -t -i /home/k/Pictures/f.png'


# -----------------------------------------------------------------------------
# color output 
# -----------------------------------------------------------------------------

alias diff='diff --color=auto'

alias grep='grep -n --color=auto'
export GREP_COLOR="1;32"

export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# alias ping='prettyping'

