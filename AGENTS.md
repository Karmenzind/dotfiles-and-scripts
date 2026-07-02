# AGENTS.md

## Working agreements

- Use `pwsh -NoProfile` for scripts and commands.
- Prefer `rg`/`rg --files` for repository searches.
- Prefer `pnpm` for Node.js package management.
- Ask before adding new production dependencies.

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
- Keep `.nvmrc` handling on `fnm use`.
- Do not reintroduce conda, npm, pip, nvm, Chocolatey profile initialization, or module installation helpers into the profile.

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
