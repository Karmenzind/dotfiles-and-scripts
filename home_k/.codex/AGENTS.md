## Tool Resolution

- Before declaring a development tool unavailable, first check the shell PATH with `command -v <tool>`.

### Python projects Specs

- Do not assume project `.venv/bin/<tool>` is the only valid tool location.
- Preferred lookup order for Python/dev tools:
  1. `command -v <tool>`
  2. project-local `.venv/bin/<tool>`
  3. `<python> -m <tool>`
  4. project runner such as `uv run`, only when needed
- Do not use `uv run` merely to execute linters or formatters if the tool is already available on PATH.
- Be aware that `uv run` may resolve dependencies, access the network, or touch `uv.lock`.
