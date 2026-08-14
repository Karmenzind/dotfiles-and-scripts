# RMUX on Windows: compatibility notes

The repository's standalone RMUX configuration is shared by Linux, macOS, and
Windows; see [rmux.md](./rmux.md) for its architecture and common verification.
This document records only native Windows compatibility findings and guarded
workarounds.

The current findings were verified against RMUX 0.10.0 on native Windows ConPTY.
They are version-scoped; use a fresh isolated server after every upgrade.

## Configuration architecture

- Keep `home_k/.rmux.conf` standalone. RMUX 0.10 parses much more tmux syntax,
  but `home_k/.tmux.conf` still contains Unix-only TPM plugins, shell jobs,
  clipboard commands, and terminal assumptions.
- The live `~/.rmux.conf` should remain a symlink into this repository.
- Do not set `default-shell` in the shared file. RMUX 0.10 chooses the native
  platform default; a stale Windows server that retained the former
  `pwsh.exe` value must clear it with `rmux set-option -gu default-shell` or be
  restarted.
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

## RMUX 0.10.0 verification

RMUX 0.10.0 moves detached RPC from wire version 5 to 8 and is not compatible
with 0.9.x daemons. Stop old servers during the upgrade and validate against a
fresh socket. The installed client, attached client, and daemon were all
verified as 0.10.0. See the
[upstream 0.10.0 release notes](https://github.com/Helvesec/rmux/releases/tag/v0.10.0).

The release fixes additional fragmented Windows bracketed-paste cases and adds
the `title` client feature, but it still does not auto-detect `cstyle`. Keep the
version-scoped cursor workaround described below. `set-titles` remains off to
match the shared tmux configuration; the new capability is not a reason to
change terminal-tab titles implicitly.

The bundled human-friendly configuration now documents a UTF-8-safe Windows
`copy-command` for `copy-pipe`. This configuration already uses
`copy-selection` with the `clipboard` client feature and `set-clipboard
external`, not `clip.exe` or `copy-pipe`, so adding that external PowerShell
pipeline would replace a working OSC 52 path without benefit. Keep
`copy-command` empty unless the copy binding is deliberately changed to
`copy-pipe`.

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
console key noise. RMUX 0.10.0 hardens fragmented reads, startup deferral,
Ctrl+Enter-shaped LF records, and final-sink delivery. The installed client was
verified as 0.10.0; start a fresh server after upgrading so it runs the same
implementation.

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

### Cursor shape ownership

Windows Terminal may define a bar as its profile default, but PSReadLine's Vi
mode handler is the immediate owner of the interactive PowerShell cursor after
the prompt starts. PSReadLine begins in Insert mode, so its normal `ESC[6 q`
sequence changes the cursor to a steady bar even when the outer terminal or
Alacritty is configured for a block.

RMUX 0.9.1 and 0.10.0 parse DECSCUSR and store each pane's cursor style, but the
0.10.0 Windows client auto-detects only `sync`, `bpaste`, `mouse`, `clipboard`,
and `title`. The attached client therefore still lacks the `cstyle` feature.
Its outer `TERM` is also empty, and
`apply_terminal_feature_options` returns before matching `.rmux.conf`
`terminal-features` entries, so adding `*:cstyle` to `.rmux.conf` cannot repair
these versions.

On Windows, the PowerShell profile wraps interactive `rmux` calls and applies
`rmux.exe -T cstyle ...` only when `rmux -V` reports 0.9.1 or 0.10.0. `-T`
adds the client capability at attach time; RMUX then uses its built-in `Ss`/`Se`
templates to relay the pane's recorded cursor style to Windows Terminal. Other
platforms and other RMUX versions retain their normal invocation. This wrapper
is required for each newly attached affected client, so reload the profile and
fully reattach after changing it. Verify with
`rmux list-clients -F '#{client_termfeatures}'`: the attached client must
include `cstyle`. Do this check in a real interactive PowerShell session: the
shared profile intentionally returns before defining interactive helpers when
stdin or stdout is redirected, so a headless profile-load test cannot validate
this wrapper.

Restarting only the RMUX server is insufficient when the outer PowerShell was
opened before this wrapper was added. Detach to that outer shell and dot-source
`$PROFILE`, or open a new terminal tab, then verify that `Get-Command rmux`
reports `Function` before attaching. If `list-clients` still omits `cstyle`,
inspect the attached client process: a working invocation includes
`-T cstyle` before `new-session` or `attach-session`.

For RMUX panes, keep both PSReadLine Vi modes on `ESC[2 q` (steady block).
Neovim owns the cursor while it is active: `guicursor` explicitly uses a block
for Normal/Visual/Command modes and a blinking `ver25` bar for
Insert/Command-line Insert/Visual Select modes. This division keeps the shell
cursor a block, gives Insert mode a distinct bar, and lets the next PowerShell
prompt restore the shell cursor after Neovim exits. Do not change the global
Windows Terminal cursor shape just to fix RMUX; that would affect unrelated
profiles and tabs.

The scope guards are part of the workaround: keep the PSReadLine override and
Neovim `guicursor` assignment limited to Windows RMUX panes. Non-RMUX
PowerShell must retain its original Vi-mode handler, and non-RMUX Neovim must
retain its default `guicursor`. Editing the files does not revert state already
loaded by a running shell or Neovim process; restart that process (or explicitly
reset its option) before treating the old cursor shape as evidence about the
new guards.

### Ctrl+D remains provisional

The root-table `C-d` binding that sends raw `0x04` is retained only when
`USERPROFILE` marks a native Windows server. An isolated 0.9
`send-keys C-d` probe did not close an empty PowerShell pane, but that command
uses the server key path and cannot prove how a physical console Ctrl+D is
forwarded. Remove this workaround only after a real attached-client test; do
not infer success from `list-keys` or `send-keys` alone.

RMUX 0.10.0 includes upstream Windows tests for attached and raw-console Ctrl+D,
but this host currently has no `cargo` or `rustc` on PATH, so those physical
ConPTY tests were not run against the installed build. Keep the binding until a
real attached-client test exercises the same path.

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

1. `rmux -V`, the client executable, and daemon process all report 0.10.0, and
   `rmux capabilities --human` reports detached wire version 8.
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
7. In a fresh RMUX pane, confirm that both PSReadLine Vi modes use a steady
   block. Start Neovim and confirm Normal mode is a block, Insert mode is a
   blinking vertical bar, and the shell returns to a block after Neovim exits.
8. Reload the live config only after the isolated checks:

   ```powershell
   rmux source-file (Join-Path $HOME ".rmux.conf")
   ```

9. Run `git diff --check`.

## Upgrade procedure

1. Read the upstream changelog for Windows ConPTY input, shell startup,
   `default-command`, cwd/OSC 7, copy-mode rendering, and key forwarding.
2. Restart long-running servers. RMUX 0.10.0 uses detached RPC wire version 8
   and rejects 0.9.x daemons, which use wire version 5.
3. Run the checklist with a fresh isolated socket before touching the live
   server.
4. Remove a workaround only when a test exercises the same input or rendering
   path as the original failure.
5. Update this document and `home_k/.rmux.conf` together.
