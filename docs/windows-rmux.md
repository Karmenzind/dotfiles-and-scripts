# RMUX on Windows: compatibility notes

This repository uses RMUX only as a native Windows replacement for tmux. The
goal is to preserve the key bindings and behavior of `home_k/.tmux.conf` where
RMUX supports them, while keeping RMUX-specific workarounds in
`home_k/.rmux.conf`.

These findings were verified against RMUX 0.8.0 on native Windows ConPTY. Treat
them as version-scoped. Re-test every workaround after an RMUX upgrade before
removing it.

## Configuration architecture

- `home_k/.tmux.conf` remains the shared macOS/Linux/tmux configuration.
- `home_k/.rmux.conf` is deliberately standalone. Do not source the complete
  tmux file from it. RMUX 0.8.0 partially accepts that file but skips or rejects
  plugins, shell jobs, conditionals, the `send` command alias, and some terminal
  options. A partial load can look successful while leaving default bindings in
  place.
- The live Windows files `~/.tmux.conf` and `~/.rmux.conf` should both be
  symlinks into this repository.
- RMUX-specific behavior should imitate tmux, but a known upstream limitation
  must be documented rather than hidden behind a misleading configuration.

## Verified RMUX 0.8.0 issues and workarounds

### PowerShell profile loading

RMUX starts its PowerShell host with `-NoProfile`. In addition,
`default-command` is not reliably applied to every `new-window` and
`split-window` path.

The RMUX configuration therefore passes an explicit profile-loading `pwsh.exe`
command to all normal keyboard creation routes:

- initial session through `default-command`;
- `prefix+c` for a new window;
- tmux-compatible `prefix+"` and `prefix+%` splits;
- custom `prefix+_`, `prefix+|`, `prefix+-`, and `prefix+\` splits.

Keep the command's first executable token as `pwsh.exe`. Prefixing the command
with a PowerShell assignment makes `#{pane_current_command}` display the
assignment instead of the process name.

Direct CLI/SDK calls can still bypass key bindings. Callers using
`rmux new-window` or `rmux split-window` directly should provide the same shell
command explicitly until RMUX applies `default-command` consistently.

### TERM and terminfo

RMUX 0.8.0 assigns `TERM=tmux-256color` to Windows ConPTY panes. Native Windows
tools commonly lack that terminfo entry and may fail with:

```text
tmux-256color: unknown terminal type
```

`default-terminal` is accepted but is effectively a no-op, and a global TERM
environment option is overwritten during ConPTY creation. The configured pwsh
command therefore sets the process environment to `xterm-256color`. The
PowerShell profile also corrects inherited Windows RMUX panes at the very top,
before prompts, pagers, and TUI tools run.

Existing panes keep their old environment. After changing this logic, create a
new pane or run `. $PROFILE` in the existing pane before testing a pager such as
`git diff`.

### Current-directory inheritance

On Windows, RMUX cannot continuously infer a ConPTY process's current working
directory. Without terminal integration, `#{pane_current_path}` stays at the
pane's initial directory even though `split-window -c
"#{pane_current_path}"` looks correct.

`others/powershell/profile.ps1` wraps the prompt and emits OSC 7 with the current
`$PWD` on every redraw. RMUX consumes OSC 7 and updates
`#{pane_current_path}`. Keep the `-c` option on every new-window/split binding.

This chain must be tested end to end: change directory in the parent, wait for
the prompt, split, and inspect `$PWD` in the child. Checking the binding text
alone is insufficient.

### Ctrl+D

RMUX 0.8.0 does not reliably pass an unbound Ctrl+D through ConPTY. The root
table binding sends the raw `0x04` byte. Re-test this after upgrades rather than
removing it based only on the binding list.

### Copy mode and Vim-style selection

Use the full `send-keys` command in RMUX copy-table bindings. RMUX silently
skips tmux's `send` alias in this context, which leaves the default `v` binding
as `rectangle-toggle` instead of `begin-selection`.

The required bindings are:

- `v`: `begin-selection`;
- `V`: `select-line`;
- `Ctrl+v`: `rectangle-toggle`;
- `y`: `copy-selection`.

RMUX 0.8.0 has a remaining renderer limitation. It reports
`selection_present=1` and `pane_mode=copy-mode`, and it parses
`mode-style=bg=yellow,fg=black`, but the native pane snapshot contains no
selection-overlay cells. Users therefore do not get tmux's selected-text
reverse/highlight effect. Configuration cannot create that overlay.

The current fallback displays plain `VISUAL` in `status-left` while a selection
exists. Do not put comma-separated `#[...]` styles inside RMUX's
`#{?condition,true,false}` expression: RMUX 0.8.0 treats those commas as
conditional argument separators and leaks fragments such as `fg=black,b` into
the status bar.

Keep `mode-style` configured for tmux parity and future RMUX versions, but do
not claim that selected-text highlighting works until it is visually and
programmatically re-tested with a newer renderer.

### Pane process label

`#{pane_title}` is unsuitable when the pane border should show only a process
name. PowerShell and Oh My Posh themes may set it to a full executable path,
host name, or dynamic title. Use `#{pane_current_command}` and keep the shell
bootstrap beginning with `pwsh.exe`; the resulting label is `pwsh.exe`.

## PowerShell profile architecture and performance

The live PowerShell 7 profile is expected to be a symlink to
`others/powershell/profile.ps1`.

Synchronous interactive startup contains the non-interactive guard, functions
and aliases, environment activation, PSReadLine, Oh My Posh, the RMUX TERM/cwd
integration, and the optional external Coreutils fragment. Terminal-Icons,
PSCompletions, and PsFZF load once through `PowerShell.OnIdle`.

Set `PROFILE_TRACE=1` before starting an interactive shell to print synchronous
and deferred timings. A verified RMUX run measured roughly 300 ms synchronous
startup; treat this as a reference rather than a permanent benchmark.

Coreutils' official installer injects generated code into the current profile.
That is unsafe when the profile is a repository symlink. Use
`scripts/windows/Update-CoreutilsPowerShellFragment.ps1` to render the official
template to `%LOCALAPPDATA%\dotfiles-and-scripts\powershell\coreutils-profile.ps1`.
The repository profile loads that external fragment if present.

## Verification checklist

Always use a unique isolated socket so a stale daemon, old global options, or an
existing pane environment cannot produce a false pass:

```powershell
$socket = "profile-test-$PID"
rmux -L $socket -f .\home_k\.rmux.conf new-session -d -s audit
# Run focused display-message, send-keys, split-window, and capture-pane checks.
rmux -L $socket kill-server
```

Verify at least:

1. A new shell reports `TERM=xterm-256color`, has the `cd` alias from the linked
   profile, and eventually loads PsFZF.
2. `prefix+c` and every configured split binding contains the explicit pwsh
   command.
3. After `cd C:\Windows` and a prompt redraw,
   `#{pane_current_path}` becomes `C:\Windows`; a child split starts there.
4. `list-keys -T copy-mode-vi` shows the four explicit Vim bindings.
5. After `begin-selection`, formats report
   `selection_present=1|pane_mode=copy-mode`.
6. Do not use pane state alone to assert visual highlighting. Inspect an
   attached client and, when supported, styled snapshot cells.
7. Reload the live configuration only after isolated checks:

   ```powershell
   rmux source-file (Join-Path $HOME ".rmux.conf")
   ```

8. Run `git diff --check`.

## Upgrade and cleanup plan

When RMUX is upgraded:

1. Read the upstream changelog for Windows ConPTY, `default-command`, cwd/OSC 7,
   copy-mode rendering, format parsing, and Ctrl+D changes.
2. Run the isolated verification checklist without altering the live server.
3. Test whether `default-terminal`, `default-command`, `mode-style`, and the
   short `send` alias now work as tmux does.
4. Remove a workaround only after its replacement passes both state-level and
   visible interactive tests.
5. Update this document and `home_k/.rmux.conf` in the same change.
