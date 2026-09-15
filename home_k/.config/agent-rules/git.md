# Git

## Commit messages

- Record the final behavior change and any design reasons needed to understand
  it. Do not record review rounds, implementation process, trial-and-error
  history, test-pass counts, or agent workflow. Do not record a specific
  verification process unless it is a lasting constraint on understanding the
  code.
- Do not add `Co-Authored-By:` trailers naming an AI assistant, and do not add
  any other signature, trailer, or marker indicating that a commit was generated
  by an AI. A commit message describes the change itself and nothing else.

## Commit scope

When creating a commit, inspect the full working tree: staged, unstaged, and
untracked files.

Prefer fewer commits. Combine changes that share a nearby scope or serve the
same function into one commit. Do not split a related set of edits into several
commits unless the user asks for that split, or the changes are clearly
unrelated.

If extra changes are present that this agent did not make for the current task
(other sessions, other agents, leftover local edits, or unrelated files):

- Stop before staging or committing.
- Name those extra paths and ask whether they should be included in this
  commit's scope.
- Do not omit them on your own initiative, and do not include them on your
  own initiative. Wait for an explicit answer.

This does not override the rule against committing secrets. If an extra path
looks like a secret, warn and keep it out.

## Publishing to a remote

- **Never push to a remote on your own initiative.** Push only when the user has
  explicitly asked for a push in the current exchange, and push only the scope
  they named.
- "The commit is done" is not permission to push. When in doubt, stop and ask.
- This applies to every equivalent way of publishing local commits, including
  `git push` (and its `--force`, `--set-upstream`, and tag-pushing forms),
  `gh pr create`, and `gh pr merge`.

## Branching

- Do not create a branch for the work unless asked. Default to committing on the
  current branch.
