# Configuration change scope

- Treat existing behavior outside the user's target environment as a
  compatibility contract. Do not replace a shared or global setting when the
  request concerns only one platform, terminal, shell, editor host, plugin, or
  tool version.
- Before adding a configuration assignment, handler, wrapper, environment
  variable, or workaround, identify every relevant scope boundary: operating
  system, host application, runtime mode, and affected version. Apply the
  narrowest reliable guards and preserve the original fallback behavior.
- Keep compatibility workarounds version-scoped unless there is evidence that
  every supported version needs them. Document the affected versions and an
  upgrade or retest condition.
- Verify both sides of every guard: test the intended target environment and at
  least one representative non-target environment. Compare effective settings or
  actual process invocation where possible. A successful target-only test is not
  sufficient evidence that a change is safely scoped.
- Prefer the narrowest layer that can actually fix the problem. When a setting is
  being overridden from a layer you were told not to touch, look for a later
  layer you do own rather than editing the one that is off limits.
