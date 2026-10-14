# Neovim Markdown preview networking

## Required behavior

- Both mdkite and markdown-live-preview (`mlp`) listen on `0.0.0.0:13333`.
- Notifications and automatically opened browser URLs use the machine's
  detected LAN IP, never `localhost`, `127.0.0.1`, or `0.0.0.0`.
- Every picker launch stops the managed active preview before starting the new
  selection. mdkite uses `instance_mode = "multi"`; do not enable `takeover` or
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
