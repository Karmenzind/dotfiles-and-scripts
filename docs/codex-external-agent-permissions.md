# Codex-launched external-agent permission probes

Observed on 2026-10-02 on Linux in an OJ multi-repository workspace. These are
local test results, not a claim about all CLI versions, platforms, accounts,
repositories, or permission configurations.

## Environment and method

- Codex CLI: 0.160.0, workspace-write filesystem restrictions and restricted
  network; linked business repositories resolved outside the writable root.
- Claude Code: 2.1.286. The local configured model was explicitly selected and
  confirmed as `claude-fable-5-1` by the result's model usage.
- Cursor Agent: 2026.09.28-64d2043, explicitly selected `composer-2.5` from the
  current full model enumeration. The user's existing Cursor internal sandbox
  configuration was disabled; the probe did not change that configuration.
- Each executor created a unique temporary text file with its file tool, then
  ran a fixed Python verification script that checked that file and created a
  separate shell-write companion. The orchestrator independently checked all
  four contents and removed only these files. Existing code was not changed.

Models above identify this dated test only. Discover currently available
models and honor task directives rather than treating them as defaults.

## Results and diagnosis

| Invocation | Observed result |
|---|---|
| Claude inside Codex's outer sandbox | API request failed with `EAI_AGAIN`; an anonymous connectivity probe also could not resolve the API hostname. Repository write capability was not reached. |
| Cursor inside Codex's outer sandbox | Could not create its user session directory under `~/.cursor/projects/`; reported `ENOENT` from mkdir. Repository write capability was not reached. |
| Claude with an approved outer escalation | Both direct-tool and shell writes succeeded using print mode, `acceptEdits`, and an allowlist for the exact verification command; no permission bypass. |
| Cursor with an approved outer escalation, ordinary print mode | Direct file write succeeded, but the shell tool returned `Rejected` without a detailed reason. Do not describe this as an auto-review rejection: auto-review was not enabled yet. |
| Same Cursor session resumed with `--auto-review` | The exact verification shell command succeeded. No `--force` or global permission change was used. |

The contrast between restricted and approved launches supports an outer-sandbox
cause for the startup failures. The Cursor file/shell contrast shows a separate
child-tool approval boundary. The observed `ENOENT` does not, by itself, prove
every missing-directory error is a sandbox failure.

## Invocation guidance within Codex

Start in the actual repository checkout and declare the allowed write scope.
Use an explicitly discovered model; provide a bounded prompt and EOF on stdin.
For Claude, the successful probe used `-p`, `--permission-mode acceptEdits`,
`--allowedTools` containing the exact Bash verification command plus the
required file tools, and `--output-format json`. For Cursor, it used `-p`,
`--workspace <actual-checkout>`, and, when shell permission was needed,
`--auto-review`. These options retain child permission checks.

Diagnose the actual failure before escalation. When the outer sandbox blocks
an authorized action, use Codex's targeted approval path for that invocation.
Do not try to overcome the outer restriction by granting the child broader
permissions. A rejected automatic approval must be reported with the action
and the stated reason; do not replace it with a permission-bypass launch.

## Limits and revisit conditions

- The successful child launches ran outside Codex's outer sandbox after
  approval. This does not establish that the same writes work inside it.
- The Cursor result was under an already-disabled internal sandbox. It does
  not establish behavior under an enabled Cursor sandbox and is not a reason
  to disable one globally.
- Temporary file and shell writes were tested in two real linked repositories.
  Git metadata writes, project builds, databases and Windows/macOS were not
  part of these child-agent probes.
- No persistent permission settings were changed. Successful auto-review of
  one command does not guarantee approval of another command.
- Re-probe after changes to Codex/child CLI versions, sandbox policy, checkout
  paths or child configuration. Preserve independent startup, file and shell
  checks; update this note rather than treating the dated flags as permanent.
