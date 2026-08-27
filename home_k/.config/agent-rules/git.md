# Git

## Commit messages

- Do not add `Co-Authored-By:` trailers naming an AI assistant, and do not add
  any other signature, trailer, or marker indicating that a commit was generated
  by an AI. A commit message describes the change itself and nothing else.

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
- Uncommitted changes already present in the working tree belong to the current
  piece of work unless the user says otherwise; do not split them out on your own
  initiative.
