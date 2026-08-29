# Personal Agent Rules

These rules apply to AI coding agents running in my personal development environment.

They are independent of any specific company, repository, or project.

## Scope

This rule set defines:

- executor discovery and availability;
- model and reasoning selection metadata;
- cross-agent delegation behavior;
- runtime/tool capabilities;
- browser verification defaults;
- personal orchestration conventions;
- planning-phase behavior;
- git commit and push conventions;
- development tool resolution;
- configuration change scoping.

Project and repository rules always remain authoritative for project-specific behavior.

## General principles

- Never silently substitute an unavailable Executor or Model.
- Treat Executor, Model, Reasoning, and Execution Mode as independent dimensions.
- Prefer explicit delegation over simulating another Executor with an internal subagent.
- Use current executor capability metadata rather than assumptions when planning delegation.
- Report conflicts between these rules and repository-local rules instead of silently resolving them.

## Language

Write these rules in English, including any rule extracted here from an
agent-specific file.

See:

- `communication.md` — language and style for output addressed to the user
- `executors.md` — enumerating executors and their models
- `orchestration.md` — delegation, model selection, pre-dispatch checks
- `runtime.md` — running services and discovered runtime state
- `browser.md` — browser verification capability
- `planning.md` — planning-phase behavior and what counts as verified
- `git.md` — commit messages, pushing, branching
- `tooling.md` — tool resolution, Node.js and Python conventions
- `config-scope.md` — scoping configuration changes and their guards
