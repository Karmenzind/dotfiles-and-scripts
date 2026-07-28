# Neovim fzf on Windows: unresolved `:Rg` failure

## Status

This issue is unresolved. Do not add a Windows-only `:Rg` override until the
same configuration has been compared with a Windows machine where the problem
does not occur.

The shared Vim configuration must retain its existing Linux and macOS
behavior. `fzf.vim` currently provides the built-in `:Rg` command; the
commented custom definition in `home_k/.vimrc` is not active.

## Symptom

On this Windows machine, `:Rg` inside Neovim can report errors such as:

```text
[Command failed: rg --column --line-number --no-heading --color=always --smart-case -- ^"qrcode.pay^"]
```

The same failure was observed for a query expected to match repository files:

```text
[Command failed: rg --column --line-number --no-heading --color=always --smart-case -- ^"rmux^"]
```

The caret-escaped quotes are generated intentionally by `fzf#shellescape()`.
On native Windows, the installed fzf implementation defaults that function to
`cmd.exe` escaping and temporarily changes Neovim's shell to `cmd.exe` while
launching fzf. This happens even though the shared Neovim configuration sets
`shell` to `pwsh`, with Windows PowerShell as its fallback.

## Reproducing machine

Captured on 2026-07-28:

```text
Windows: Microsoft Windows 11 Pro 10.0.26200, build 26200
Neovim: 0.12.4, Release, LuaJIT 2.1.1774638290
PowerShell: 7.6.4
fzf: 0.74.1 (eae8d9d2)
fzf repository commit: 0efef298d2a47cf757d6deedaa804ecc0515bb28
fzf.vim repository commit: d2a59a992a2455f609c0fde2ebd84427ea8f919a
COMSPEC: C:\WINDOWS\system32\cmd.exe
SHELL: C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe
```

Relevant executable paths:

```text
nvim.exe: C:\Program Files\Neovim\bin\nvim.exe
fzf.exe: C:\Users\Edwin\AppData\Local\Microsoft\WinGet\Links\fzf.exe
pwsh.exe: C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe
powershell.exe: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
cmd.exe: C:\Windows\system32\cmd.exe
```

Three ripgrep installations are visible on `PATH`. All currently report
ripgrep 15.2.0 revision `e89fff89ac`, but the Codex-bundled copy has highest
precedence:

```text
1. C:\Users\Edwin\.codex\packages\standalone\releases\0.145.0-x86_64-pc-windows-msvc\codex-path\rg.exe
2. C:\Users\Edwin\AppData\Local\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.2.0-x86_64-pc-windows-msvc\rg.exe
3. C:\Users\Edwin\AppData\Local\Microsoft\WinGet\Packages\BurntSushi.ripgrep.GNU_Microsoft.Winget.Source_8wekyb3d8bbwe\ripgrep-15.2.0-x86_64-pc-windows-gnu\rg.exe
```

The active ripgrep config is:

```text
RIPGREP_CONFIG_PATH=C:\Users\Edwin\.config\ripgreprc
```

It enables hidden-file search and excludes `.venv`, `.mypy_cache`, `.git`,
`node_modules`, `vendor`, and `package-lock.json`. Ripgrep still respects
ignore files.

## Verified observations

- `fzf#shellescape()` emits cmd-style `^"query^"` quoting on native Windows by
  design.
- Running an equivalent caret-quoted ripgrep command directly through
  `cmd.exe` succeeds for a known match.
- Ripgrep returns 1 for a valid query with no matches.
- The problem is not fully explained by no-match behavior because it was also
  reported for `rmux`, which is expected to match files in this repository.
- The reproducing machine may run the Codex-bundled `rg.exe` inside Neovim
  because that directory precedes both winget installations on `PATH`.
- The shared Neovim configuration selects `pwsh` when available and otherwise
  selects Windows PowerShell. `fzf.vim` independently switches to `cmd.exe`
  for its Windows execution path.

## Rejected workaround

A Windows-only `:Rg` override appended this cmd expression:

```text
|| (if errorlevel 2 (exit /b 2) else (exit /b 0))
```

It worked in an isolated `cmd.exe` test but failed after passing through
Vimscript, `FZF_DEFAULT_COMMAND`, fzf, and cmd parsing. The displayed command
was truncated around the nested `exit` expression. The override was reverted;
do not repeat this approach without testing the complete interactive fzf path.

## Comparison checklist

Run the following on the non-reproducing Windows machine from the same
repository and capture the output:

```powershell
pwsh -NoProfile -Command '
$os = Get-CimInstance Win32_OperatingSystem
"OS=$($os.Caption) $($os.Version) build $($os.BuildNumber)"
"PS=$($PSVersionTable.PSVersion)"
nvim --version | Select-Object -First 3
fzf --version
where.exe rg
$paths = where.exe rg
foreach ($path in $paths) {
    "RG=$path"
    & $path --version | Select-Object -First 2
}
"COMSPEC=$env:COMSPEC"
"SHELL=$env:SHELL"
"RIPGREP_CONFIG_PATH=$env:RIPGREP_CONFIG_PATH"
git -C (Join-Path $HOME "vimfiles\plugged\fzf") rev-parse HEAD
git -C (Join-Path $HOME "vimfiles\plugged\fzf.vim") rev-parse HEAD
'
```

Inside Neovim on both machines, record:

```vim
:version
:set shell? shellcmdflag? shellquote? shellxquote? shellslash?
:echo exepath('rg')
:echo exepath('fzf')
:echo fzf#shellescape('rmux')
:pwd
:verbose command Rg
```

Then test the exact generated command in both PowerShell and cmd from the same
working directory, recording output and exit code. Compare PATH ordering
first, especially whether Neovim selects the Codex-bundled or winget ripgrep.
