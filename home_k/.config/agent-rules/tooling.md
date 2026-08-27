# Tool Resolution

- Before declaring a development tool unavailable, check the shell PATH with
  `command -v <tool>`.

## Node.js tooling

- For nearly all Node.js work on this machine, use the `pnpm` managed by `fnm` as
  the default package manager and package runner.
- Whenever both npm and pnpm are viable, choose pnpm. Prefer `pnpm install`,
  `pnpm add`, `pnpm run`, and `pnpm dlx` over the corresponding npm or npx
  commands.
- Use npm or npx only when official documentation explicitly does not support or
  recommends against pnpm, when the affected project's package-manager contract
  requires npm, or when the user explicitly asks for npm or npx.
- Before declaring `pnpm` unavailable, check `command -v pnpm`. Do not hard-code
  transient paths under `/run/user/*/fnm_multishells/`.
- Preserve a project's existing package-manager contract when its
  `packageManager` field, lockfile, or repository instructions require a
  different tool.

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
