# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# pure-fish/pure settings.
#
# `set -g`, never `set -Ux` and never `set -gx`:
#   * global values shadow the stale `SETUVAR pure_*` entries left in the
#     untracked ~/.config/fish/fish_variables, so the repository owns the value
#     in every new session without rewriting machine state;
#   * pure's `_pure_set_default` only writes a universal when the variable is
#     unset/empty in BOTH universal and global scope, so this file wins
#     regardless of whether it is sourced before or after conf.d/pure.fish;
#   * `-x` would leak pure_* into every child process for no reason.
# pure_symbol_ssh_prefix is a *symbol* printed immediately before user@host in
# SSH sessions; pure's own default is "". A system-wide /etc/fish/config.fish
# sets it to $USER on at least one machine, which renders as "user user@host" --
# the username twice. Pin it back to the default here.
set -g pure_symbol_ssh_prefix ""

set -g pure_show_system_time true
set -g pure_separate_prompt_on_error false
set -g pure_enable_single_line_prompt false
set -g pure_show_prefix_root_prompt false
set -g pure_reverse_prompt_symbol_in_vimode true
set -g pure_check_for_new_release false

# No right prompt. pure already prints user@host on the first line in SSH
# sessions, and a system-wide /etc/fish/config.fish defines a fish_right_prompt
# ("☁ $USER@$hostname") that repeats it -- the same string rendered on both
# lines. This configuration owns the prompt, and pure does not use a right
# prompt, so define it empty.
#
# config.fish re-sources this file after /etc/fish/config.fish, which is what
# makes the override stick. For a machine-local right prompt, define your own
# in ~/.config/fish/local.fish; config.fish sources that last of all.
function fish_right_prompt
end
