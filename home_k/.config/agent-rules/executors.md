# Executor Discovery

Current executor capabilities are stored outside this rule repository as runtime state.

Preferred cache:

`~/.config/agent-runtime/executors.json`

Before planning work that may delegate to another Executor:

1. read the capability cache;
2. refresh it when stale or missing;
3. refresh immediately when actual behavior contradicts cached metadata.

Do not hard-code current model lists into this file.

Capability discovery and calibration evidence are separate concerns.

## Enumerating models

Use the command that returns the executor's complete model list, not whichever
subcommand is shortest.

For `cursor-agent`, always use `agent --list-models`. Do not use
`agent models`: it prints a **truncated short list** that omits many
models. The difference is measured, not assumed — in the short list the
`cursor-` prefix retains only a single fast model, while `--list-models` also
returns the low / medium / high / xhigh tiers of the same family and their
non-fast variants.

**Concluding that a model "does not exist" from a truncated list produces wrong
answers.** When an expected model appears to be missing, re-enumerate with the
full-list command before reporting it as unavailable.
