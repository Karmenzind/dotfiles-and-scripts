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
