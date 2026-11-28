# Tool Resolution

- Before declaring a development tool unavailable, check the shell PATH with
  `command -v <tool>`.

## Node.js tooling

Assume every machine in this environment manages Node.js with
[`fnm`](https://github.com/Schniz/fnm) (Fast Node Manager), and uses `pnpm` as
the package manager, unless the project says otherwise.

### Node.js versions come from fnm

- Do not assume a system-wide Node.js install, and do not install Node.js
  through a system package manager, an OS installer, or `nvm`. If a Node.js
  version is missing, use `fnm install` / `fnm use`.
- Respect a project's `.node-version` or `.nvmrc`; that file is the version
  contract fnm reads.
- `node`, `npm`, `pnpm`, and other Node CLIs resolve through the fnm shim
  directory of the current shell, so they exist on PATH only after fnm is
  activated in that shell. Check with `command -v node` before concluding a
  tool is missing.
- Never hard-code a shim path. fnm's per-shell directory is ephemeral and
  platform-specific (for example `/run/user/*/fnm_multishells/*` on Linux and
  `%LOCALAPPDATA%\fnm_multishells\*` on Windows); it changes on every new
  shell. Invoke tools by name, or go through `fnm exec`.

### pnpm is the default package manager

- Whenever both npm and pnpm are viable, choose pnpm. Prefer `pnpm install`,
  `pnpm add`, `pnpm run`, and `pnpm dlx` over the corresponding npm or npx
  commands.
- For a new project, scaffold with pnpm and record it in `packageManager`.
- Use npm or npx only when official documentation explicitly does not support or
  recommends against pnpm, when the affected project's package-manager contract
  requires npm, or when the user explicitly asks for npm or npx.
- Before declaring `pnpm` unavailable, check `command -v pnpm`.
- Preserve a project's existing package-manager contract when its
  `packageManager` field, lockfile, or repository instructions require a
  different tool. Do not convert a repository between package managers, or
  delete and regenerate a lockfile, without being asked.

## Python projects

- Do not assume a project's `.venv/bin/<tool>` is the only valid tool location.
- Preferred lookup order for Python and dev tools:
  1. `command -v <tool>`
  2. project-local `.venv/bin/<tool>`
  3. `<python> -m <tool>`
  4. a project runner such as `uv run`, only when needed
- Do not use `uv run` merely to execute a linter or formatter that is already
  available on PATH.
- Be aware that `uv run` may resolve dependencies, access the network, or touch
  `uv.lock`.

## Command-line database clients

- When querying a database from the command line, try `usql` first. Use
  `mycli`, `pgcli`, `sqlcmd`, or another engine-specific client only when
  `usql` is unavailable, cannot connect to that engine, or lacks a feature
  the task needs.
- Look up named connections in `~/.config/usql/config.yaml` before asking for
  connection details. A name the user gives may be a `usql` connection even
  when they mention a different client; for example, `mycli` cannot open a
  PostgreSQL connection.
- Repository rules that prescribe a specific tool or code path for validating
  queries or migrations take precedence.
