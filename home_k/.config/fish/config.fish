# Github: https://github.com/Karmenzind/dotfiles-and-scripts
#
# fish sources conf.d/*.fish BEFORE this file, so config.fish holds only the
# ordering-sensitive bootstrap: PATH first, then machine-local environment, then
# the tool integrations that read PATH.
#
# Everything declarative lives in conf.d/kz_*.fish. The kz_ prefix is required:
# `fisher update` runs `cp -RLf` into conf.d/, functions/ and completions/, and
# a name collision would silently overwrite a repo file through its symlink.
# See docs/unix-fish.md.

# ---- 1. PATH ----------------------------------------------------------------
# `-gP` operates on the global $PATH. Bare `fish_add_path` writes a UNIVERSAL
# fish_user_paths into the untracked fish_variables; tracked config must not.
# It skips non-existent directories on its own, and returns non-zero when it
# adds nothing, so never chain it with `and`.
fish_add_path -gP $HOME/.local/bin

if type -q ruby; and type -q gem
    fish_add_path -gP (ruby -r rubygems -e 'puts Gem.user_dir')/bin
end

if not set -q GOPATH; and type -q go
    set -gx GOPATH (go env GOPATH | string trim)
end
set -q GOPATH; and fish_add_path -gPa $GOPATH/bin

fish_add_path -gPa $HOME/.cargo/bin $HOME/.dotnet/tools $PNPM_HOME

if test (uname) = Darwin
    fish_add_path -gP /opt/homebrew/bin /opt/homebrew/opt/ruby/bin
    set -gx LDFLAGS "-L/opt/homebrew/opt/ruby/lib"
    set -gx CPPFLAGS "-I/opt/homebrew/opt/ruby/include"
end

# ---- 2. machine-local environment ------------------------------------------
# ~/.config/shrc.ext.local is the single source of truth for machine-local
# exports (JAVA_HOME, BAT_THEME, DPRINT_INSTALL, LUA_INCDIR, API keys, ...) and
# is shared with bash and zsh. It contains only `export` lines, so bass is
# sufficient. Do NOT bass-source the full ~/.config/shrc.ext: that file defines
# bash functions and aliases that cannot transfer, and overrides `cd`.
if test -f "$HOME/.config/shrc.ext.local"
    if functions -q bass
        bass source "$HOME/.config/shrc.ext.local"
    else if status is-interactive
        echo "fish: bass is missing, ~/.config/shrc.ext.local was not loaded." >&2
        echo "      run: fisher install edc/bass" >&2
    end
end

# ---- 3. version managers and tools -----------------------------------------
function __kz_fnm_env_is_ready --description "True when node resolves to the live fnm multishell"
    set -q FNM_MULTISHELL_PATH; or return 1
    test -d "$FNM_MULTISHELL_PATH/bin"; or return 1
    set -l active (command -v node)
    test -n "$active"; or return 1
    test "$active" = "$FNM_MULTISHELL_PATH/bin/node"
end

if not type -q fnm; and test -x "$HOME/.local/share/fnm/fnm"
    fish_add_path -gP $HOME/.local/share/fnm
end
if type -q fnm; and not __kz_fnm_env_is_ready
    # --version-file-strategy recursive makes fnm emit a hook with no `test -f`
    # guard, so `fnm use` resolves .nvmrc/.node-version upward. That matches
    # __sync_fnm_env in shrc.ext. The default `local` strategy emits a
    # cwd-only guard and would not fire in project subdirectories.
    fnm env --use-on-cd --version-file-strategy recursive --shell fish | source
end

# zoxide replaces oh-my-zsh's directory-history habits; `pj` keeps the named
# $PROJECT_PATHS jump. Both hook --on-variable PWD; fish allows many handlers.
type -q zoxide; and zoxide init fish | source

# SDKMAN's `sdk` command comes from the reitzig/sdkman-for-fish plugin.
# .sdkmanrc auto-activation is implemented in conf.d/kz_projenv.fish rather than
# through SDKMAN's global sdkman_auto_env switch -- see that file for why.
# rbenv is intentionally unsupported; gvm is a stub. See docs/unix-fish.md.

# ---- 4. first-run project environment sync ---------------------------------
# --on-variable PWD does not fire for the shell's initial directory, so mirror
# the trailing `__active_envs` call in shrc.ext. fnm's and zoxide's generated
# hooks self-initialize.
#
# Guarded with `functions -q`: these live in conf.d/kz_projenv.fish, and a
# partial install (config.fish symlinked but conf.d not yet) would otherwise
# raise "Unknown command" on every single startup.
functions -q __kz_sync_python_venv; and __kz_sync_python_venv
functions -q __kz_sync_sdkman_env; and __kz_sync_sdkman_env

# ---- 5. re-assert over a system-wide config.fish ----------------------------
# fish reads, in order: conf.d/ -> $__fish_sysconf_dir/config.fish -> this file.
# A system-wide /etc/fish/config.fish therefore OVERRIDES everything set in
# conf.d/. On machines that have one (this repo's own older config was installed
# there as root on at least one box), it re-exports EDITOR, PAGER, VISUAL,
# FZF_TMUX, FZF_DEFAULT_COMMAND, pure_*, and redefines `y`.
#
# Re-sourcing our conf.d files here is a purely user-level fix -- config.fish is
# the last file fish reads, so this needs no sudo and does not touch the system
# file. All four are idempotent. See docs/unix-fish.md.
if test -f $__fish_sysconf_dir/config.fish
    for _kz in kz_env kz_fzf kz_prompt kz_funcs
        test -f $__fish_config_dir/conf.d/$_kz.fish
        and source $__fish_config_dir/conf.d/$_kz.fish
    end
    set -e _kz
end

# Note on conda: a stray ~/.config/fish/conf.d/conda.fish installs conda's own
# shell hook, which re-adds /opt/miniconda3/bin to PATH on a later event, so
# stripping the entry from here does not stick. AGENTS.md forbids conda setup
# paths; scripts/setup_fish.sh offers to remove that untracked file instead,
# which is the layer where it can actually be fixed.

# ---- 6. machine-local fish overrides ---------------------------------------
# $__fish_config_dir instead of (dirname (status -f)): explicit, and immune to
# how fish happens to invoke `source` for this file.
test -f $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish
