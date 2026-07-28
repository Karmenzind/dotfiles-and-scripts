# RMUX on Windows: compatibility notes

This repository uses RMUX only as a native Windows replacement for tmux. Keep
RMUX-specific behavior in `home_k/.rmux.conf` and match the shared tmux key
bindings where Windows and RMUX support them.

The current findings were verified against RMUX 0.9.1 on native Windows ConPTY.
They are version-scoped; use a fresh isolated server after every upgrade.

## Configuration architecture

- Keep `home_k/.rmux.conf` standalone. RMUX 0.9 parses much more tmux syntax,
  but `home_k/.tmux.conf` still contains Unix-only TPM plugins, shell jobs,
  clipboard commands, and terminal assumptions.
- The live `~/.rmux.conf` should remain a symlink into this repository.
- Keep the explicit `-c "#{pane_current_path}"` on pane/window creation.
  PowerShell emits OSC 7 on prompt redraw so RMUX can track a ConPTY pane's
  current directory; a control test using `cmd.exe` without OSC 7 remained at
  the pane's initial directory.
- Use `status-justify absolute-centre` for the window list. Plain `centre`
  centers within the space left after `status-left` and `status-right`; because
  those sections have different widths, it does not place the list at the
  terminal's geometric center.
- Keep status decoration in portable Unicode rather than Powerline private-use
  glyphs. RMUX 0.9.1 parses bold and italic inline styles and accounts for emoji
  width. The active window keeps the existing white-on-red palette and uses a
  dark `▐` half-block as a terminal-safe shadow approximation; terminals cannot
  render a real blurred or offset shadow.

## RMUX 0.9.1 verification

### Retired 0.8 workarounds

RMUX 0.9.0 now starts interactive PowerShell as `pwsh.exe -NoLogo -NoExit`
without `-NoProfile`. An isolated initial pane, CLI-created window, and split
all loaded the linked profile and reported `pwsh.exe` as the current command.
`default-command` is also applied consistently across creation paths.

Consequently, the configuration no longer starts a second child PowerShell and
no longer repeats that wrapper in every binding. This avoids nested shells,
keeps process labels accurate, and lets RMUX own the interactive shell directly.

Sourcing a file does not erase an option that was removed from that file. When
upgrading a live 0.8 server, clear its saved wrapper once with
`rmux set-option -gu default-command` (or restart the server). The effective
0.9 default is then shown as `default-command ''`.

`default-terminal` is now applied to initial and subsequently created panes.
Set it to `xterm-256color`; this avoids the missing `tmux-256color` terminfo
failure previously seen in native Windows tools. Existing panes retain their
old environment, so validate this only in new panes on a fresh server. The old
PowerShell profile correction for RMUX 0.8 has been removed; a wrong `TERM`
must now expose a stale server or pane instead of being silently masked.

RMUX 0.9 accepts tmux's `send` alias and renders the copy selection overlay with
`mode-style`. RMUX 0.9.1 fixes the attached-client selection bug reported as
[Helvesec/rmux#125](https://github.com/Helvesec/rmux/issues/125). In 0.9.0,
keyboard `begin-selection` and `select-line` consumed
`active.mouse.current_event`, moved the real selection to the cached mouse
coordinate, and made the copied region differ from the keyboard cursor.

The 0.9.1 implementation carries an explicit `CopyModeCommandOrigin`.
`CopyModeCommandOrigin::NonMouse` supplies no mouse context, while applicable
mouse commands consume only their originating event. Its regression test
installs a cached mouse event and verifies direct `send-keys -X`, normal
`send-keys`, `send-keys -K`, and attached keyboard selection paths.

The 0.9.0 workaround used `clear-selection` followed by `selection-mode
char`/`line`. It avoided the bad dispatch path, but line mode selected only the
displayed row rather than expanding a soft-wrapped logical line. RMUX 0.9.1 can
use the native bindings again:

```tmux
bind-key -T copy-mode-vi v send -X begin-selection
bind-key -T copy-mode-vi V send -X select-line
```

An isolated 0.9.1 probe started at `(0,5)` and reported
`cursor=0,5|selection_start=0,5|selection_present=1` after `v`. The upstream
attached-client regression test provides the cached-mouse coverage that a
detached isolated server cannot reproduce by itself.

RMUX 0.9.1 also adds `pane-scrollbars` and `copy-mode-line-numbers`. Both
default to `off` and consume pane width when enabled (the line-number gutter is
at least four columns). Keep them at their defaults to match the shared tmux
configuration; they remain available as explicit user preferences.

### Bracketed paste and Neovim

RMUX 0.8 delivered a native Windows console paste as ordinary insert-mode key
input. In Markdown buffers, `plasticboy/vim-markdown` sets
`comments=b:>,b:*,b:+,b:-` and includes `r` in `formatoptions`, so Neovim
correctly treated every pasted newline as typed Enter and continued `*` list
markers. Clipboard contents, `"+p`, mappings, paste settings, and paste-related
autocommands were not the cause.

RMUX 0.9 fixes the missing protocol boundary in its Windows attach path. It
detects a multi-character `ReadConsoleInputW` paste burst and wraps the batch in
`ESC[200~` / `ESC[201~`, allowing Neovim's bracketed-paste handler to receive it
as a paste rather than typed text. RMUX 0.9.1 further preserves multiline
framing across short LF, Tab, and Backspace bursts and batches separated by
console key noise. The installed client was verified as 0.9.1; start a fresh
server after upgrading so it runs the same implementation.

Do not remove `r` from Markdown `formatoptions` or enable Neovim's global
`paste` option as a workaround: both change editor behavior while leaving the
transport error unresolved. After future RMUX upgrades, re-test a real
Ctrl+Shift+V paste through a newly started isolated server. Automated
`paste-buffer -p` or `send-keys` tests do not exercise the same physical console
input path.

Related upstream history: [#92](https://github.com/Helvesec/rmux/issues/92) and
[#93](https://github.com/Helvesec/rmux/issues/93).

### Current-directory inheritance

RMUX cannot infer a running Windows ConPTY process's current directory by
itself. `others/powershell/profile.ps1` emits OSC 7 with `$PWD` on each prompt
redraw; RMUX consumes it and updates `#{pane_current_path}`. Keep both that
profile integration and `-c "#{pane_current_path}"` in creation bindings.

Test the entire chain: change directory, let the prompt redraw, create a split,
and inspect `$PWD` in the child. Reading the binding alone is insufficient.

### Ctrl+D remains provisional

The root-table `C-d` binding that sends raw `0x04` is retained. An isolated 0.9
`send-keys C-d` probe did not close an empty PowerShell pane, but that command
uses the server key path and cannot prove how a physical console Ctrl+D is
forwarded. Remove this workaround only after a real attached-client test; do
not infer success from `list-keys` or `send-keys` alone.

### Pane process label

Use `#{pane_current_command}`, not `#{pane_title}`, for pane borders. PowerShell
and Oh My Posh may set the title to a path, host name, or dynamic text.

## Verification checklist

Always use a unique socket so stale options, an older daemon, or old pane
environments cannot create a false result:

```powershell
$socket = "profile-test-$PID"
rmux -L $socket -f .\home_k\.rmux.conf new-session -d -s audit
# Run focused display-message, send-keys, split-window, and capture-pane checks.
rmux -L $socket kill-server
```

Verify:

1. `rmux -V`, the client executable, and daemon process all report 0.9.1.
2. A new shell reports `TERM=xterm-256color`, loads the linked profile, and has
   `pane_current_command=pwsh.exe` without a nested child shell.
3. CLI and bound window/split creation load the profile and preserve the parent
   directory after an OSC 7 prompt redraw.
4. `list-keys -T copy-mode-vi` shows native `begin-selection`/`select-line` for
   `v`/`V`, plus direct `send -X` bindings for `Ctrl+v` and `y`. With the mouse
   at a different location, a real attached `v` selection must start at the
   keyboard copy cursor and be painted with `mode-style`.
5. A real Ctrl+Shift+V paste into a Markdown Neovim buffer reaches bracketed
   paste and does not add list markers. Do not substitute `send-keys` for this
   physical-console test.
6. Test physical Ctrl+D before removing its compatibility binding.
7. Reload the live config only after the isolated checks:

   ```powershell
   rmux source-file (Join-Path $HOME ".rmux.conf")
   ```

8. Run `git diff --check`.

## Upgrade procedure

1. Read the upstream changelog for Windows ConPTY input, shell startup,
   `default-command`, cwd/OSC 7, copy-mode rendering, and key forwarding.
2. Restart long-running servers even when the wire version does not change.
   RMUX 0.9.1 remains wire-compatible with 0.9.0 at detached RPC version 5, but
   a 0.9.0 daemon cannot provide fixes implemented in the 0.9.1 server.
3. Run the checklist with a fresh isolated socket before touching the live
   server.
4. Remove a workaround only when a test exercises the same input or rendering
   path as the original failure.
5. Update this document and `home_k/.rmux.conf` together.
