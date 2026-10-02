Follow my shared personal agent rules under:

`~/.config/agent-rules/`

Read `AGENTS.md` there before planning or orchestrating delegated work.

Everything that is not specific to Codex lives there — planning behavior, git
conventions, tool resolution, executor selection, and configuration scoping.
Only Codex-specific mechanics belong in this file.

## Codex Windows sandbox helper recovery

- When Codex on Windows fails before command execution with
  `orchestrator_helper_launch_failed` because `codex-windows-sandbox-setup.exe`
  is not found, inspect the active standalone release before treating the
  sandbox as unavailable.
- If the active release contains both
  `codex-resources/codex-windows-sandbox-setup.exe` and
  `codex-resources/codex-command-runner.exe`, but the launcher's resolved `bin`
  directory lacks them, copy both helpers into that active release's `bin`
  directory.
- Do not overwrite a destination helper with different contents. If a
  destination exists, compare SHA-256 first; stop and report any mismatch. After
  copying, verify source and destination SHA-256 values match and run one
  ordinary non-elevated sandbox command.
- Apply this recovery only to the confirmed standalone resource-resolution
  failure. Do not generalize it to missing helpers, other install layouts,
  signature or hash mismatches, or unrelated sandbox errors.
- Treat the repair as release-scoped, because `standalone/current` may change
  after a Codex update. On recurrence, re-identify the active release and repeat
  the checks instead of assuming the previous copy remains effective.

## External agents launched from Codex

- An external Claude or Cursor process inherits Codex's outer filesystem and
  network restrictions. Its own permission mode cannot grant access denied by
  that outer sandbox. A linked repository's real path may be outside Codex's
  writable roots even when its workspace link is readable.
- Separate startup failures (session/cache directories or API connectivity)
  from child-agent file-tool and shell-tool denials. A working version banner
  or successful file edit does not prove that shell commands or Git metadata
  writes are permitted.
- If an authorized invocation fails because of the outer sandbox, request a
  targeted `require_escalated` rerun through Codex's approval mechanism. Keep
  the child's write scope and permission checks narrow; do not silently use
  `--force`, skip permissions, disable sandboxes, or change global settings.
- For Codex-launched noninteractive probes, Claude `acceptEdits` plus an exact
  Bash-command allowlist and Cursor `--auto-review` have worked after the outer
  restriction was addressed. These are observed invocation options, not blanket
  approval or a requirement to override the user's existing configuration.
  Recheck installed CLI support and report any subsequent review rejection.
- Before assigning repository work, test the required file and shell operations
  in the actual checkout with isolated temporary files. Independently verify
  their contents, clean only those files, and preserve existing changes. Probe
  Git metadata writes separately when a task requires commits.

For dated versions, failures, successful invocations, and limitations, see
[the dotfiles evidence note](../../docs/codex-external-agent-permissions.md).
Resolve this file's symlink target when locating the companion document.
