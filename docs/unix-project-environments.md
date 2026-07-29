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

Both shells passed, as did `zsh -n`, `bash -n`, and `git diff --check`.

On 2026-07-29, a macOS zsh session reproduced an inherited fnm multishell
directory at the end of `PATH`, behind Homebrew Node.js. After tightening the
readiness check, a fresh project shell resolved `node`, `corepack`, and `pnpm`
from the fnm multishell and reported Node.js 24.18.0, Corepack 0.35.0, and pnpm
11.16.0. The project's Vite executable also ran under Node.js 24.18.0.
