# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# fish does not use __active_envs. fnm and zoxide each install their own
# --on-variable PWD handler; Python venv and SDKMAN are implemented here.
# Semantics follow ~/.config/shrc.ext -- see docs/unix-project-environments.md.

function __kz_find_upward --argument-names relpath \
    --description "Print the nearest \$PWD ancestor containing relpath"
    set -l dir $PWD
    while true
        if test -e "$dir/$relpath"
            echo "$dir"
            return 0
        end
        test "$dir" = /; and break
        set dir (string replace -r -- '/[^/]*$' '' $dir)
        test -n "$dir"; or set dir /
    end
    return 1
end

# ---- Python .venv -----------------------------------------------------------
# Mirrors __sync_python_venv: nearest .venv searching upward, and deactivation
# only when this hook owns the environment (a manually activated venv is never
# clobbered).
function __kz_sync_python_venv --on-variable PWD \
    --description "Activate/deactivate the nearest Python .venv"

    # Never mutate the environment or print from inside a command substitution.
    status is-command-substitution; and return
    set -q __kz_hook_busy; and return

    set -l root (__kz_find_upward .venv/bin/activate.fish)
    set -l venv_dir
    test -n "$root"; and set venv_dir "$root/.venv"

    if test -n "$venv_dir"
        test "$VIRTUAL_ENV" = "$venv_dir"; and return

        if test -n "$VIRTUAL_ENV"; and functions -q deactivate
            deactivate
        end

        status is-interactive; and echo "🐍 Activating Python .venv ..."
        if source "$venv_dir/bin/activate.fish"
            set -g __kz_auto_venv $VIRTUAL_ENV
        end
    else if test -n "$__kz_auto_venv"
        if test "$VIRTUAL_ENV" = "$__kz_auto_venv"; and functions -q deactivate
            status is-interactive; and echo "🐍 Deactivating Python .venv ..."
            deactivate
        end
        set -e __kz_auto_venv
    end
end

# ---- SDKMAN -----------------------------------------------------------------
# SDKMAN's own `sdkman_auto_env` switch is deliberately NOT enabled. It lives in
# $SDKMAN_DIR/etc/config and is global: turning it on also makes
# sdkman-init.sh append sdkman_auto_env to zsh's chpwd_functions, which would
# then run alongside shrc.ext's __sync_sdkman_env (two hooks). SDKMAN's own
# implementation is also weaker -- it only checks `.sdkmanrc` in the current
# directory and tears down with an unanchored `$PWD =~ ^$SDKMAN_ENV` regex.
# This is the fish-side equivalent of __sync_sdkman_env: upward search,
# checksum caching, and ownership tracking.
function __kz_sync_sdkman_env --on-variable PWD \
    --description "Activate/clear the nearest .sdkmanrc (SDKMAN)"

    status is-command-substitution; and return
    set -q __kz_hook_busy; and return

    set -l config_dir (__kz_find_upward .sdkmanrc)

    if test -z "$config_dir"
        if test -n "$__kz_auto_sdkman_env" \
                -a "$SDKMAN_ENV" = "$__kz_auto_sdkman_env"; and functions -q sdk
            status is-interactive; and echo "☕ Clearing SDKMAN project environment ..."
            sdk env clear
        end
        set -e __kz_auto_sdkman_env
        set -e __kz_sdkman_config_signature
        return
    end

    set -l config_file "$config_dir/.sdkmanrc"
    set -l signature "$config_file:"(cksum <"$config_file" 2>/dev/null)
    test "$signature" = "$__kz_sdkman_config_signature"; and return

    # Do not clobber a manually selected environment.
    if test -z "$__kz_auto_sdkman_env" -a "$SDKMAN_ENV" = "$config_dir"
        set -g __kz_sdkman_config_signature $signature
        return
    end

    if test -n "$__kz_auto_sdkman_env" \
            -a "$SDKMAN_ENV" = "$__kz_auto_sdkman_env" \
            -a "$SDKMAN_ENV" != "$config_dir"
        sdk env clear
        set -e __kz_auto_sdkman_env
    end

    if not functions -q sdk
        status is-interactive
        and echo "SDKMAN is not available in fish. Run scripts/setup_fish.sh." >&2
        return
    end

    status is-interactive; and echo "☕ Activating .sdkmanrc (SDKMAN) ..."
    if __kz_run_sdkman_env_in "$config_dir"
        set -g __kz_auto_sdkman_env $SDKMAN_ENV
        set -g __kz_sdkman_config_signature $signature
    end
end

# `sdk env` only reads .sdkmanrc from the current directory (an upstream
# limitation documented in docs/unix-project-environments.md), so change into
# the config directory to run it. fish has no `cd -q`, so __kz_hook_busy blocks
# this repository's own PWD handlers from re-entering.
function __kz_run_sdkman_env_in --argument-names target_dir
    set -l previous $PWD
    set -g __kz_hook_busy 1
    if not builtin cd "$target_dir"
        set -e __kz_hook_busy
        return 1
    end
    sdk env
    set -l rc $status
    builtin cd "$previous"
    set -e __kz_hook_busy
    return $rc
end
