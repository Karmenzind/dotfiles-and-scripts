# Orchestration

When delegating work:

- use the Executor requested by the task;
- verify the actual Executor and Model before dispatch;
- do not replace Codex with Claude, Cursor with Codex, or any other Executor without an explicit execution-metadata revision; the one standing exception is an exhausted usage quota, under the conditions in "Executor quota runs out mid-run" below;
- if the selected Executor cannot be invoked, stop and report the constraint;
- Executor completion does not imply task acceptance;
- review and verification remain the Orchestrator's responsibility.

## Model selection

- Use the **non-fast** variant of a model. `-fast` serving variants are **more
  expensive**; the only permitted exception is the user explicitly asking for
  one. Do not choose a fast variant merely because it appears first in a list.
  (Corrected 2026-08-29: an earlier draft claimed a second exception for
  "inconsequential tasks" — the user never authorized it.)

### Cursor's Composer models: choose with caution, and conservatively

Developer instruction, 2026-11-28. Treat a Composer model (`composer-*`) as the
last choice among the available executors, not as the default for frontend
work.

- **Before choosing it, ask whether another executor or model can take the
  task.** Prefer one that can; pick Composer only when the task is small, its
  write scope is a few files that only this task touches, and a wrong result
  would be obvious and cheap to undo. Say why it was chosen in the capability
  assessment.
- **Do not give it a task that edits files shared across the application**:
  locale catalogues, lockfiles, generated code, snapshots, route or menu
  registries, shared styles or configuration. If the task needs such an edit,
  either assign the whole task to a stronger model, or split that edit out to
  one.
- **Do not give it broad rewrites** (a page rework across many components, a
  refactor) or anything touching money, permissions, data writes or
  migrations.
- **When it is used, the prompt spells out every constraint that a stronger
  model would be trusted to infer**: which files may change and how, what must
  not be regenerated, sorted or bulk-copied, what counts as unfinished. "Follow
  the repository's existing practice" is not a constraint for this model.
- **Review its work as untrusted**: start from `git status` and
  `git diff --stat` and check the size and spread of the change against the
  task before reading any line, and do not rely on its tests passing. Its
  report understates what it did.

Why: on 2026-11-28 `composer-2.5`, asked to rework one page of
`oj-next-frontend` and add about fifty locale keys, rewrote `zh.json` and
`jp.json` in full (about 5,700 changed lines each, keys re-sorted) and replaced
existing Chinese and Japanese translations with English so that a parity test
would pass. The type check and every unit test passed, and its report
mentioned it in one soft line. The orchestrator noticed only because of the
diff size; had it been pushed, shipped screens would have turned English. The
general rule this produced is in the engineering playbook,
`workspaces/agent-execution.md`, "Read the shape of the diff before accepting a
report".

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
  these need explicit approval and must be recorded before dispatch, except
  the quota fallback below, which I have approved in advance;
- anything destructive or outward-facing: pushing, deleting, touching a shared
  database or a production system;
- a trade-off where two defensible answers lead to materially different work,
  and the frozen documents do not choose between them.

When in doubt, prefer acting and reporting the judgment over stalling. A
recorded judgment I can overturn costs less than an idle orchestrator.

## Executor quota runs out mid-run

Added 2026-10-29, after Cursor hit its team usage limit halfway through a
frozen run and two tasks sat blocked waiting for me.

**When it applies:** Plan, Contract and Tasks are frozen, orchestration has
started, and a task cannot run because its assigned executor reports an
exhausted usage quota or rate-limit window (for example `usage limit`,
`ActionRequiredError`, a stated reset time). It does not apply to any other
kind of unavailability — not installed, authentication failure, sandbox
refusal, wrong invocation — and not to unfrozen work; those still stop and
report.

1. **Report at once.** Name the blocked tasks, quote the error, give the
   reset time if known, propose the replacement Executor and Model, and state
   the deadline: one hour after the report. Keep dispatching every other
   runnable task meanwhile.
2. **If I answer within the hour, follow my answer.**
3. **If I have not answered within the hour, switch** to another executor whose
   quota is available. This is a standing, pre-approved execution-metadata
   revision; do not wait any longer.
   - Pick an executor that can actually do the task (check required
     capabilities such as browser or network); prefer one already working in
     this run. Smoke-test it before the real dispatch if it is new to the run.
   - Keep the task's Reasoning; never switch to a fast variant.
   - If the quota resets within that same hour, waiting for the reset is also
     acceptable — say which you chose.
4. **Record it; never substitute silently.** In the Tasks document's dispatch
   record write: Requested and Actual executor, the quota error, the report
   time, the switch time, and "no reply within one hour". Revise the task's
   execution metadata the same way any developer revision is recorded.

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
