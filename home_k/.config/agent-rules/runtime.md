# Runtime

Prefer existing running development services when suitable.

Do not start duplicate dev servers unnecessarily.

Long-running executors should be checked for progress when execution materially exceeds expectations, but must not be interrupted merely for being slow.

Runtime state such as available executors, versions, models, and authentication status must be discovered rather than assumed.
