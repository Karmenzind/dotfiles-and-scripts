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

## Keep going; stop only for decisions that are mine

**Once orchestration has started, run it to completion. Do not stop to wait for
me unless a genuine decision is blocked on my input.** Dispatch the next
runnable task as soon as its dependencies are met, review it, verify it, commit
it, and move on. Reporting progress is not a reason to pause: report *and*
continue in the same turn.

Things that are **not** reasons to stop:

- a task finished and the next one is ready — dispatch it;
- an executor stopped on a frozen-artifact conflict whose correct resolution is
  already determined by the frozen documents — rule on it, record the ruling,
  send it back;
- a write-scope or capability gap the orchestrator itself created — fix the
  dispatch and re-send;
- verification the executor could not perform — do it yourself, that is already
  the orchestrator's job;
- a defect found outside the current contract's scope — record it as a
  follow-up and keep going;
- the harness or environment needs repair — repair it.

Things that **are** reasons to stop and ask:

- a change to frozen Plan scope, Contract semantics, or acceptance criteria that
  the frozen documents do not already settle;
- an execution-metadata revision (Executor, Model, Reasoning, Execution Mode) —
  these need explicit approval and must be recorded before dispatch;
- anything destructive or outward-facing: pushing, deleting, touching a shared
  database or a production system;
- a trade-off where two defensible answers lead to materially different work,
  and the frozen documents do not choose between them.

When in doubt, prefer acting and reporting the judgment over stalling. A
recorded judgment I can overturn costs less than an idle orchestrator.

## Pre-dispatch checks

- Confirm the executor actually runs **in the write mode the task needs**, not
  merely that `--version` responds. A version banner is not evidence that the
  executor can write files in the intended mode.
- When a task declares a required capability (browser, container runtime,
  network), **probe that capability itself**, not just executor reachability.
  Reaching an executor proves nothing about what it is allowed to do inside its
  sandbox. Known example: `codex exec` cannot start Docker
  (`operation not permitted`) and cannot call Playwright MCP
  (`approval policy is never`), so it must not take a task whose acceptance
  needs a browser — dispatching one costs a full round of rework.

## Supervisor for every orchestration run

Every orchestration run gets a **supervisor**: a dedicated watcher, started
when the first task is dispatched, whose only job is to notice executors that
have hung. Dispatching a task is not delivering it; a long silence can be
normal work, a deadlock, a sandbox refusal, or an executor waiting for input
nobody will give, and nothing distinguishes them unless someone looks.

- **Scope.** The supervisor watches every dispatched task, whatever the
  executor or adapter.
- **Cadence.** Once a task has been running for more than **15 minutes**, the
  supervisor checks its status **every 5 minutes** until it finishes. Tasks
  under 15 minutes are not polled.
- **What a check looks at.** Whether the executor is still alive, whether its
  output or working tree is changing, whether it is consuming CPU, and whether
  it is waiting on input, authentication, permissions, or quota. Report how
  long the task has been running, not merely "still running". Several
  executors write their output only at the end, so empty output alone is not
  evidence of a hang; unchanged output *and* no CPU progress is.
- **How completion is detected.** Prefer the executor's own completion signal
  over process lookups. A watcher that matches processes by command-line text
  can match itself, and a PID captured right after dispatch is often a
  short-lived intermediate process; both have produced false "still running"
  and false "finished" readings.
- **Read-only.** Checks never modify the task's working tree, compete with the
  executor, or interrupt it for being slow. A suspected hang is reported to the
  orchestrator, which acts on it under the long-running-executor rules of the
  engineering playbook (investigate, correct the invocation, redispatch to the
  same executor, or report) — never by silently taking over the task.
- **Exit.** The supervisor stops when orchestration ends, which is when every
  task in the Tasks document is completed. It does not stop merely because the
  currently running tasks have finished while others remain.
