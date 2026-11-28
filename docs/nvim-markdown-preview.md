# Neovim Markdown preview networking

## Required behavior

- Both mdkite and markdown-live-preview (`mlp`) listen on `0.0.0.0:13333`.
- Notifications and automatically opened browser URLs use the machine's
  detected LAN IP, never `localhost`, `127.0.0.1`, or `0.0.0.0`.
- When an existing preview is found, the picker asks `y/N` before stopping it.
  Use native `input()` in Neovim's bottom command line, not a `vim.ui.input`
  floating dialog. Enter `y` or `n` and press Enter; Escape also cancels.
  `y` stops it and starts the new selection; `n`, Enter, or cancellation leaves
  it running without launching another preview. mdkite uses `instance_mode = "multi"`; do not enable `takeover` or
  retarget an existing server, because that can keep serving the previous file.
- This behavior is shared across Linux, macOS, and Windows.

## mdkite 2.1.0 finding

Verified on 2026-10-12 against mdkite.nvim 2.1.0
(`dded03dc6cce87364b48260b2ffbace575a6add7`). A primary server bound to
`0.0.0.0` converts its displayed URL to a LAN address. When another Neovim
instance joins that server in `takeover` mode, however, the plugin passes a URL
containing `127.0.0.1` to `hooks.on_start`.

The repository configuration disables takeover and normalizes loopback and
wildcard hosts in preview URLs through `markdown_preview_lan_url()`. The same
helper is used by mlp so its browser URL and notification cannot drift back to
localhost.

After upgrading mdkite, retest a fresh preview and the fixed-port conflict from
a second Neovim instance. Do not switch back to takeover unless the requirement
to always start a new preview is deliberately changed.

## Cross-instance stop confirmation

The picker discovers mdkite in other Neovim instances through their default RPC
sockets (or Windows named pipes), checks the loaded server's port, and calls
`mdkite.stop()` only after confirmation. Each RPC client has a one-second timeout.
Managed mlp tmux panes are identified by the exact launch-command prefix;
mlp jobs in this Neovim's terminal buffers are also recognized. The
new preview waits up to 1.5 seconds for port 13333 to become available.

Unknown port owners, custom RPC socket locations, or unresponsive editors may
not be identifiable. In that case the picker reports the problem and leaves
the owner running; it never kills a Neovim process to free its port. Windows
named-pipe discovery requires validation on a native Windows host.

On 2026-10-28, an isolated Linux two-editor test verified that `n` and
cancellation leave the remote preview running, `y` releases its port without
exiting its editor before launching the replacement, and a free port launches
without prompting. Lua syntax and whitespace checks also passed.
