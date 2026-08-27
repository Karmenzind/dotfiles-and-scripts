Follow my shared personal agent rules under:

`~/.config/agent-rules/`

Read `AGENTS.md` there before planning or orchestrating delegated work.

Everything that is not specific to Claude Code lives there — planning behavior,
git conventions, tool resolution, executor selection, and configuration
scoping. Only Claude-specific mechanics belong in this file.

## Plan mode

- `planning.md` in the shared rules governs planning behavior. In Claude Code it
  has one concrete consequence: **do not call `ExitPlanMode`, or otherwise ask
  for approval to start, unless the user has asked to begin.** Finishing the
  plan file and saying so is the end of the turn.
