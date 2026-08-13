# Unix project environment activation

`home_k/.config/shrc.ext` synchronizes project environments after each successful
directory change in zsh and bash. It searches upward from the current directory,
so entering a repository through `pj` or working in a repository subdirectory
uses the nearest supported configuration.

## State model

- Python activates the nearest `.venv` and deactivates it on exit only when the
  hook activated that environment.
- SDKMAN loads the nearest `.sdkmanrc`. It uses `sdk env clear` when leaving an
  environment owned by the hook, which restores SDKMAN defaults.
- fnm uses the nearest `.nvmrc`, then `.node-version`. It does not change the
  active Node.js version when leaving a project because fnm 1.39.0's generated
  `--use-on-cd` hook also leaves the last selected version active.
- rbenv uses the nearest `.ruby-version`. It restores the previous
  `RBENV_VERSION`, or runs `rbenv shell --unset`, when leaving an environment
  owned by the hook.
- GVM is exposed through a lightweight `gvm` wrapper. On the first explicit
  `gvm ...` command, the wrapper requires `go.mod` directly in the current
  directory, sources the real GVM implementation, and forwards the arguments.
  Merely starting a shell or changing directories never loads GVM.
  Detect an existing GVM shell function rather than a `gvm` executable on
  inherited `PATH`; the executable cannot apply version changes to its parent
  shell and must not bypass the wrapper.

Python tracks its automatically activated environment. The version managers
cache their configuration path and checksum. Moving inside the same project
does not repeat activation, while editing a version file and then changing
directories causes it to be reapplied. State initialization preserves existing
values when `.zshrc` or `.bashrc` is sourced again, so reloading the profile
does not duplicate activation or lose ownership needed for cleanup.

## Compatibility findings

- Do not combine `fnm env --use-on-cd` with the shared `__active_envs` hook.
  Doing so creates two directory-change handlers.
- Generate plain `fnm env` integration for the running shell. Hard-coding
  `--shell zsh` makes bash evaluate zsh hook syntax and produces a syntax error.
- Do not treat a non-empty `FNM_MULTISHELL_PATH`, or merely finding its `bin`
  directory somewhere in `PATH`, as proof that fnm is ready. `.zshrc` rebuilds
  `PATH`, and Homebrew or system Node.js directories can take precedence over an
  inherited fnm multishell directory. Re-run `fnm env` unless `command -v node`
  resolves to that multishell's `node` shim.
- pnpm is enabled through Corepack in each fnm-managed Node.js installation.
  `PNPM_HOME` is only a location for pnpm-installed global commands and is
  appended to `PATH`; it must not override the active fnm/Corepack shims.
- SDKMAN's public `sdk env` command only reads `.sdkmanrc` from the current
  directory. The wrapper temporarily changes to the configuration directory;
  zsh uses `cd -q` so this internal change does not recursively invoke `chpwd`.
- SDKMAN also requires the active project's `.sdkmanrc` to remain present for
  `sdk env clear`. Deleting that file before leaving can prevent SDKMAN from
  restoring its defaults; this is an upstream command limitation.
- GVM defines a global `cd` wrapper that calls `setValueForKeyFakeAssocArray`.
  Claude Code 2.1.226 shell snapshots retained that wrapper and its public
  callers but omitted GVM's `_encode` and `_decode` helpers. Every snapshot cwd
  reset then printed `command not found` warnings. Keep GVM out of shell startup
  and directory-change hooks; the lazy wrapper lets Claude snapshots retain a
  self-contained loader instead. If Claude explicitly runs `gvm` in a direct
  `go.mod` directory, GVM exists only in that tool shell. Existing Claude
  sessions must be restarted after changing this behavior because their broken
  snapshot is already cached.

Re-test the generated fnm hook and SDKMAN `sdk env clear` behavior after major
version-manager upgrades. The behavior above was verified with fnm 1.39.0 and
the SDKMAN installation present on 2026-07-27.

## Verification evidence

On 2026-07-27, isolated zsh and bash integration checks covered:

- shell-specific fnm initialization;
- recovery when `FNM_MULTISHELL_PATH` is stale or missing from `PATH`;
- activation through project-root configuration files;
- retaining the same state in nested directories;
- avoiding repeated activation after profile reload;
- reapplying a changed version file;
- switching directly between two configured projects;
- SDKMAN cleanup and rbenv restoration after leaving a project.
- GVM staying unloaded on shell startup and directory changes, rejecting calls
  outside a direct `go.mod` directory, then loading and forwarding arguments
  when explicitly invoked inside one.

Both shells passed, as did `zsh -n`, `bash -n`, and `git diff --check`.

On 2026-07-29, a macOS zsh session reproduced an inherited fnm multishell
directory at the end of `PATH`, behind Homebrew Node.js. After tightening the
readiness check, a fresh project shell resolved `node`, `corepack`, and `pnpm`
from the fnm multishell and reported Node.js 24.18.0, Corepack 0.35.0, and pnpm
11.16.0. The project's Vite executable also ran under Node.js 24.18.0.

On 2026-08-13, Claude Code 2.1.226's saved snapshot was sourced in an isolated
zsh and reproduced the `_encode` / `_decode` warnings on `cd`. The lazy wrapper
was then verified in zsh and bash for rejection outside a Go project, no loading
on directory changes, one-time loading on explicit use, and argument forwarding.
