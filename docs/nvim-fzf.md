# Neovim fzf layout selection

On 2026-11-25, `<leader>ff` was correctly mapped to `:Files` and both fzf
plugins were loaded, but the picker did not appear. The live instance had
`g:fzf_layout = { tmux = '-p90%,60%' }` and inherited
`TMUX=/private/tmp/tmux-501/default,9380,0`; the socket no longer existed.
`tmux -V` still succeeded because it only queried the client executable.

Verified versions: Neovim 0.12.5, tmux 3.7c, fzf 0.74.4, junegunn/fzf
`9a07058`, fzf.vim `fe5f1fd`.

The configuration now requires an executable tmux, a supported version,
nonempty `TMUX` and `TMUX_PANE`, and a successful
`tmux display-message -p -t "$TMUX_PANE" '#{pane_id}'` matching that pane.
Windows, VS Code and Neovide do not take the tmux popup path. All other cases
use the existing Neovim floating-window layout. Version comparisons use
separate major/minor numbers so tmux 3.10 is not mistaken for 3.1.

The check runs during Neovim initialization. An instance already configured
with a stale layout needs its layout changed or a restart; re-sourcing the
entire init.lua is not supported by lazy.nvim.

Verification covered stale/live/mismatched panes, GUI/Windows exclusions and
old/future tmux versions. A real isolated tmux server retained popup
eligibility. With the stale environment, a minimal Neovim loaded the installed
fzf plugins, opened `:Files` in a floating terminal, and kept fzf running until
it was explicitly cancelled. The agent sandbox initially made fzf exit with
`operation not permitted`; the same isolated test outside the sandbox passed.
Do not confuse that terminal restriction with the host's stale-tmux failure.

For recurrence, inspect the live mapping, `g:fzf_layout`, environment, socket
and pane before changing file-finder commands or reinstalling plugins. The
separate Windows `:Rg` investigation remains in [windows-nvim-fzf.md](./windows-nvim-fzf.md).
