# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Only the aliases written by hand in ~/.config/shrc.ext are mirrored here.
# oh-my-zsh's common-aliases / lib/directories surface is deliberately not
# ported; see the "not ported" section of docs/unix-fish.md.

# `alias` in fish generates a function, so these work in scripts, pipes and
# command substitution. fish's alias builtin inserts `command` automatically
# when the body starts with the alias name, so the self-referential ones below
# do not recurse.
alias vi vim
alias nv nvim
alias mux tmuxinator
alias xy proxychains4
alias diff 'diff --color=auto'
alias sdcv 'sdcv --color'
alias py python
alias py3 python3
alias py2 python2
alias bpy 'python -m bpython'

# An abbreviation, not an alias: the expansion is what lands in history, which
# is the whole point of `yolo`. It is never needed from a script.
abbr -a yolo 'git commit -m (curl -s https://whatthecommit.com/index.txt)'

# shrc.ext hard-codes xclip on Linux. Probe at runtime instead so this works on
# Wayland and on machines without xclip.
function toboard --description "Copy stdin to the system clipboard"
    if type -q pbcopy
        pbcopy $argv
    else if set -q WAYLAND_DISPLAY; and type -q wl-copy
        wl-copy $argv
    else if type -q xclip
        xclip -selection clipboard $argv
    else if type -q xsel
        xsel --clipboard --input $argv
    else
        echo "toboard: no clipboard tool found (pbcopy/wl-copy/xclip/xsel)." >&2
        return 1
    end
end
