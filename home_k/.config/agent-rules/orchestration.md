# Orchestration

When delegating work:

- use the Executor requested by the task;
- verify the actual Executor and Model before dispatch;
- do not replace Codex with Claude, Cursor with Codex, or any other Executor without an explicit execution-metadata revision;
- if the selected Executor cannot be invoked, stop and report the constraint;
- Executor completion does not imply task acceptance;
- review and verification remain the Orchestrator's responsibility.

## Model selection

- Use the **non-fast** variant of a model. `-fast` serving variants are **more
  expensive**; the only permitted exception is the user explicitly asking for
  one. Do not choose a fast variant merely because it appears first in a list.
  (Corrected 2026-08-29: an earlier draft claimed a second exception for
  "inconsequential tasks" — the user never authorized it.)

## Pre-dispatch checks

- Confirm the executor actually runs **in the write mode the task needs**, not
  merely that `--version` responds. A version banner is not evidence that the
  executor can write files in the intended mode.
