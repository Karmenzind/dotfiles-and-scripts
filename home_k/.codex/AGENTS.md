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

## Configuration change scope

- Treat existing behavior outside the user's target environment as a compatibility contract. Do not replace a shared or global setting when the request concerns only one platform, terminal, shell, editor host, plugin, or tool version.
- Before adding a configuration assignment, handler, wrapper, environment variable, or workaround, identify every relevant scope boundary: operating system, host application, runtime mode, and affected version. Apply the narrowest reliable guards and preserve the original fallback behavior.
- Keep compatibility workarounds version-scoped unless there is evidence that every supported version needs them. Document the affected versions and an upgrade/retest condition.
- Verify both sides of every guard: test the intended target environment and at least one representative non-target environment. Compare effective settings or actual process invocation where possible; a successful target-only test is insufficient evidence that the change is safely scoped.
