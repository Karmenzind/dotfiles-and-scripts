# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Mirrors the environment section of ~/.config/shrc.ext. fish cannot source that
# file (bash syntax), so this is a deliberate re-implementation, not a copy.
# See docs/unix-fish.md.

# ---- editor / pager ---------------------------------------------------------
if type -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end
set -gx VISUAL $EDITOR
set -gx SVN_EDITOR $EDITOR
set -gx PAGER less

# ---- preferred GUI programs -------------------------------------------------
for _t in alacritty xfce4-terminal urxvt
    if type -q $_t
        set -gx TERMINAL (command -v $_t)
        break
    end
end
for _b in chromium chrome firefox elinks
    if type -q $_b
        set -gx BROWSER (command -v $_b)
        break
    end
end
set -e _t
set -e _b

# ---- appearance -------------------------------------------------------------
set -gx COLORTERM truecolor
set -e GREP_COLOR
set -gx GREP_COLORS '1;32'
set -gx TERMINFO /usr/share/terminfo

# ---- tools ------------------------------------------------------------------
set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgreprc
set -gx WORKON_HOME $HOME/.venvs
set -gx USE_PROXYCHAINS_FIRST true
set -gx SDKMAN_DIR $HOME/.sdkman
set -gx PNPM_HOME $HOME/.local/share/pnpm

# ---- input method (fcitx) ---------------------------------------------------
set -gx XMODIFIERS '@im=fcitx'
set -gx QT_IM_MODULE fcitx

# ---- pj ---------------------------------------------------------------------
# Not exported: consumed by `pj` and its completion only.
set -g PROJECT_PATHS ~/Workspace ~/Localworks

# VIRTUAL_ENV_DISABLE_PROMPT is intentionally not set here; pure's own
# conf.d/_pure_init.fish already exports it.
