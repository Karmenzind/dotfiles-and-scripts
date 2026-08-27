# Github: https://github.com/Karmenzind/dotfiles-and-scripts
status is-interactive; or exit

# vi as the base layout, matching oh-my-zsh's vi-mode plugin.
#
# This is a GLOBAL, not a universal. fish_key_bindings is already a universal in
# ~/.config/fish/fish_variables (fish_default_key_bindings); a global shadows it
# for reads without mutating that untracked file. Ordering is safe:
# __fish_config_interactive runs on the first fish_prompt event, i.e. after all
# conf.d files and config.fish, its __init_uvar sees the global via
# `set --query` and leaves the universal alone, and __fish_reload_key_bindings
# then applies the global's value.
set -g fish_key_bindings fish_vi_key_bindings

function fish_user_key_bindings --description "fzf integration plus emacs keys inside vi mode"
    # NOTE: defining this function here shadows any autoloaded
    # ~/.config/fish/functions/fish_user_key_bindings.fish. That file previously
    # carried the whole fzf integration, so everything it did must be covered
    # below or the fzf keys silently disappear.

    # fzf.fish installs its own bindings from its conf.d and must not be
    # double-initialized (see docs/unix-shell-config.md for the zsh version of
    # this rule). When the plugin is absent -- a fresh machine, or before
    # scripts/setup_fish.sh has run -- fall back to fzf's built-in integration
    # so Ctrl-R and Ctrl-T keep working.
    if not functions -q _fzf_search_history; and type -q fzf
        fzf --fish | source
    end

    # Emacs keys kept inside vi mode, matching what oh-my-zsh's vi-mode plugin
    # also leaves bound.
    #
    # The `\c` escape notation is used deliberately instead of fish 4's readable
    # `ctrl-a` names: fish 4 still accepts it, while fish 3.x parses `ctrl-a` as
    # the literal characters c,t,r,l,-,a and silently installs a nonsense
    # binding. One notation that is correct on both is worth more than the
    # prettier one that breaks on the version Ubuntu ships.
    for mode in default insert
        bind -M $mode \ca beginning-of-line
        bind -M $mode \ce end-of-line
        bind -M $mode \cp up-or-search
        bind -M $mode \cn down-or-search
        # fish's shared preset maps \cw to backward-kill-path-component;
        # zsh's ^W is backward-kill-word, so restore that behaviour.
        bind -M $mode \cw backward-kill-word
    end

    # Ctrl-R is deliberately not re-bound here. Whichever integration ran above
    # installed it as a *user* binding, and `bind --erase --all --preset` inside
    # fish_vi_key_bindings erases only preset bindings, so it survives and wins
    # over the vi preset's `redo`. This is why fish needs no equivalent of the
    # explicit Ctrl-R re-bind in .zshrc, where the vi-mode plugin loads after
    # fzf and steals the key.
    #
    # Ctrl-H / Backspace / DEL need nothing either: fish's vi preset already
    # maps all three to backward-delete-char in insert mode.
end
