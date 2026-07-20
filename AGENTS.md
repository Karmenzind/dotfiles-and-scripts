# AGENTS.md

## Working agreements

- Use `pwsh -NoProfile` for scripts and commands.
- Prefer `rg`/`rg --files` for repository searches.
- Prefer `pnpm` for Node.js package management.
- Ask before adding new production dependencies.
- Persist non-obvious compatibility findings, risks, rejected approaches, and verified workarounds before finishing a task so a fresh agent does not repeat the same investigation. Keep durable rules in `AGENTS.md`; put version-specific symptoms, causes, limitations, test evidence, and upgrade/revisit plans in a focused document linked from `AGENTS.md`.
- Update or remove persisted guidance when the corresponding implementation or upstream behavior changes. Do not leave stale workarounds documented as current facts.

## Windows setup

- `install.ps1` is the Windows environment setup entrypoint.
- `scripts/setup.ps1` was intentionally removed; do not recreate it.
- Keep installer output in English. Emoji and colored `Write-Host` output are acceptable for readability.
- Prefer `winget` for software installation, and use Chocolatey only as a fallback for packages that are unavailable or unreliable in `winget`.
- Manage Node.js with `fnm`; do not install Node.js through Chocolatey, winget Node packages, npm, or nvm.
- Enable pnpm through `corepack`; do not install pnpm as a standalone package.
- Manage Codex CLI with `pnpm`; manage the Codex GUI app with `winget`/Microsoft Store.
- Manage Python CLI tools with `uv tool`; do not add `pip install` or conda-based setup paths.

## Unix shell setup

- `install.sh` is the Unix-like setup entrypoint and delegates package installs to `scripts/install_apps.sh` and Vim setup to `scripts/setup_vim.sh`.
- Keep macOS support on Homebrew (`brew`) for formulae and casks.
- Keep Node.js setup on `fnm`, then enable pnpm through `corepack`.
- Use `pnpm` for JavaScript CLI tools such as prettier, eslint, sqlint, and pg-formatter.
- Use `uv tool` for Python CLI tools such as black, isort, autoflake, ruff, pgcli, and markdown-live-preview.
- Do not reintroduce conda, nvm, distro npm installs, or `pip install` setup paths.

## PowerShell profile

- `others/powershell/profile.ps1` should contain pwsh runtime behavior only.
- Do not put environment installation logic in the profile.
- Initialize `fnm` synchronously in the profile. `fnm env` only affects the process that evaluates it, so running it from `install.ps1` does not make Node.js available in future pwsh sessions.
- Keep `.nvmrc` handling on `fnm use`.
- Do not reintroduce conda, npm, pip, nvm, Chocolatey profile initialization, or module installation helpers into the profile.
- The live PowerShell 7 current-user/current-host profile is expected to be a symlink to `others/powershell/profile.ps1`; do not replace it with a generated or injected regular file.
- Keep Coreutils' generated PowerShell integration outside the repository profile. Refresh it with `scripts/windows/Update-CoreutilsPowerShellFragment.ps1`; the profile may load the external fragment but Coreutils must not inject generated code into the symlink target.
- Keep machine-specific PowerShell settings outside the repository in `~/.pwsh-profile.local.ps1`; the shared profile loads that file when present.
- Preserve the lean startup split: interactive essentials load synchronously and optional modules load through `PowerShell.OnIdle`. Use `PROFILE_TRACE=1` when measuring changes.
- Go project activation uses `gvm --format=powershell --no-install`. Search upward for `.gvmrc`, `.go-version`, `go.version`, `.tool-versions`, `go.work`, and `go.mod` in that priority order; prefer a `toolchain go...` directive over `go ...`. Parse `.gvmrc` as data and never execute it. Do not let profile-driven directory changes install or download Go versions.

## RMUX on Windows

- Read `docs/windows-rmux.md` before changing RMUX, tmux, PowerShell prompt integration, or Windows pane creation behavior.
- RMUX is currently used only as the native Windows substitute for tmux. Match the shared tmux key bindings and user-visible behavior wherever RMUX supports them.
- Keep `home_k/.rmux.conf` standalone. Do not source the full `home_k/.tmux.conf`: even when RMUX parses its syntax, that file contains Unix-only TPM plugins, shell jobs, clipboard commands, and terminal assumptions.
- Treat RMUX workarounds as version-scoped. Re-test them against a fresh isolated RMUX server after upgrades before removing or simplifying them.

## Cross-platform configuration

- Treat configuration files shared by macOS, Linux, and Windows as cross-platform by default, including `home_k/.tmux.conf`. Consider compatibility with all three platforms whenever changing shared configuration.
- Keep the shared Codex global instructions in `home_k/.codex/AGENTS.md` and list that file explicitly in `symlink.py`; generic directory traversal excludes Markdown files.
- Keep shared settings in one common file when platform differences are small, and isolate platform-specific behavior with guarded sections or included/imported macOS, Linux, and Windows fragments when the configuration format supports it.
- Split out a platform- or tool-specific configuration when its behavior differs substantially or compatibility conditionals would make the shared configuration hard to understand or unreliable.
- `home_k/.rmux.conf` is the separate Windows RMUX configuration. Keep behavior aligned with `home_k/.tmux.conf`, but do not force syntax-level sharing when RMUX compatibility is unreliable.

## Verification

- For installer changes, verify the no-install path with:

  ```powershell
  pwsh -NoProfile -File .\install.ps1 -Action q
  ```

- For profile changes, verify it can be loaded with:

  ```powershell
  . .\others\powershell\profile.ps1
  ```

- Run a focused cleanup search when touching Windows setup/profile logic:

  ```powershell
  rg -n 'conda|npm install|pip install|\bnvm\b|__installMyModules|__setupPsc|scripts/setup.ps1|setup.ps1' others\powershell\profile.ps1 install.ps1 README.md README_CN.md
  ```

- Run whitespace checks before finishing:

  ```powershell
  git diff --check
  ```

- For RMUX changes, run the isolated-server checks documented in `docs/windows-rmux.md`; do not validate only against a long-running server with stale options or pane environments.
