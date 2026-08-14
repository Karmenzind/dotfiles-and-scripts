# RMUX cross-platform configuration

`home_k/.rmux.conf` is the standalone RMUX configuration for native Linux,
macOS, and Windows. RMUX supports all three platforms directly, so the common
file owns the shared prefix, navigation, pane creation, copy mode, status line,
and synchronized-pane behavior.

Do not source `home_k/.tmux.conf` from it. The tmux file contains TPM plugins,
Unix shell jobs, clipboard utilities, and terminal overrides that RMUX may parse
but cannot run consistently on every platform.

## Platform boundaries

- Leave `default-shell` unset. RMUX 0.10.0 selected `/usr/bin/zsh` from
  `$SHELL` on Linux, and selects its native default on macOS and Windows.
- Use `source-file -F "#{config_files}"` for the reload binding so it reloads
  the actual file selected by RMUX instead of assuming `$HOME` or
  `%USERPROFILE%` syntax. The `-F` is required: without it, RMUX 0.10.0 treats
  the format as a literal filename.
- Keep `default-terminal` at `xterm-256color`, which is available across the
  supported native backends and avoids requiring tmux-specific terminfo.
- Use `-c "#{pane_current_path}"` for all pane and window creation bindings.
  Unix backends track the foreground process directory; native Windows relies
  on the PowerShell prompt's OSC 7 integration documented in
  [windows-rmux.md](./windows-rmux.md).
- Guard Windows-only commands with runtime
  `if-shell -F '#{USERPROFILE}' ...`. Unix shells may have PowerShell installed,
  so testing for `pwsh` does not identify Windows. RMUX 0.10.0 imports
  `USERPROFILE` into the server environment, but a parse-time
  `%if #{USERPROFILE}` runs too early and remains false.

The symlink installer links `.rmux.conf` on all platforms. The macOS app setup
installs RMUX through Homebrew. On Linux, use the official package instructions
for the distribution, then run `python3 symlink.py`; repository setup does not
modify APT, DNF, Nix, or Cargo sources implicitly.

## Verification

Always test with a unique socket and a fresh server. On Unix:

```sh
socket="/tmp/rmux-config-$PPID.sock"
rmux -S "$socket" -f ./home_k/.rmux.conf new-session -d -s audit
rmux -S "$socket" show-options -gv default-shell
rmux -S "$socket" display-message -p -t audit:0.0 \
  '#{pane_current_command}|#{pane_current_path}|#{config_files}'
rmux -S "$socket" list-keys | grep 'source-file'
rmux -S "$socket" kill-server
```

Verify that the default shell is the user's native shell, the pane starts in
the requested directory, the reload binding targets `#{config_files}` with
`source-file -F`, and an unprefixed `C-d` binding is absent on Unix. Also test
horizontal and vertical splits from a changed directory and run
`git diff --check`.

For Windows, additionally run the version-scoped ConPTY, bracketed-paste,
cursor, OSC 7, and physical Ctrl+D checks in
[windows-rmux.md](./windows-rmux.md).

The Linux behavior above was verified with RMUX 0.10.0 on 2026-08-14. Re-run
the isolated checks after upgrades and record platform-specific findings in the
focused Windows document or a new focused document rather than adding
unguarded behavior to the shared file.
