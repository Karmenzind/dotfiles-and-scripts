# Github: https://github.com/Karmenzind/dotfiles-and-scripts

# ---- ex: archive extractor --------------------------------------------------
# Hand-written rather than oh-my-fish/plugin-extract: that plugin has ~20 stars,
# was last pushed in 2023, and installs a differently named `extract` command.
# Keep the case list in sync with `ex` in ~/.config/shrc.ext.
function ex --description "Extract an archive"
    if test (count $argv) -eq 0
        echo "usage: ex FILE" >&2
        return 2
    end

    set -l f $argv[1]
    if not test -f "$f"
        echo "'$f' is not a valid file" >&2
        return 1
    end

    switch $f
        case '*.tar.bz2'
            tar xjf "$f"
        case '*.tar.gz'
            tar xzf "$f"
        case '*.bz2'
            bunzip2 "$f"
        case '*.rar'
            unrar x "$f"
        case '*.gz'
            gunzip "$f"
        case '*.tar'
            tar xf "$f"
        case '*.tbz2'
            tar xjf "$f"
        case '*.tgz'
            tar xzf "$f"
        case '*.zip'
            unzip "$f"
        case '*.Z'
            uncompress "$f"
        case '*.7z'
            7z x "$f"
        case '*'
            echo "'$f' cannot be extracted via ex" >&2
            return 1
    end
end

# ---- y: yazi with cwd follow ------------------------------------------------
# The official fish wrapper from https://yazi-rs.github.io/docs/quick-start
function y --description "Run yazi and follow its final directory"
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end

# ---- secrets ----------------------------------------------------------------
# ~/.config/secrets/*.env are bash `export` files, so they need bass.
function load_secret --description "Load ~/.config/secrets/<name>.env"
    if test (count $argv) -eq 0
        echo "usage: load_secret NAME" >&2
        return 2
    end

    set -l f "$HOME/.config/secrets/$argv[1].env"
    if not test -f "$f"
        echo "load_secret: no such file: $f" >&2
        return 1
    end
    if not functions -q bass
        echo "load_secret: bass is required. Run: fisher install edc/bass" >&2
        return 1
    end

    bass source "$f"
end

complete -c load_secret -f \
    -a "(path basename \$HOME/.config/secrets/*.env | string replace -r '\.env\$' '')"

# ---- codex ------------------------------------------------------------------
function update_codex --description "Update the Codex CLI with the official installer"
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
end

# ---- weather ----------------------------------------------------------------
function weather --description "Show the weather from wttr.in"
    if test (count $argv) -eq 0
        curl -4 http://wttr.in
    else
        curl -4 "http://wttr.in/$argv[1]"
    end
end

# ---- gvm stub ---------------------------------------------------------------
# GVM ships bash/zsh scripts only (~/.gvm/scripts/* are bash) and installs a
# global `cd` wrapper. bass cannot bridge it: bass transfers environment
# variables, not functions, and the `cd` override would break fish's own cd.
# See docs/unix-project-environments.md for why it stays lazy even in bash/zsh.
function gvm --description "GVM is not available in fish"
    echo "gvm is bash/zsh only. Run it from bash or zsh, where the repo exposes" >&2
    echo "a lazy gvm wrapper that loads GVM inside a Go project directory." >&2
    return 1
end
