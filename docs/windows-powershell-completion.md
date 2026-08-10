# PowerShell completion strategies

The shared PowerShell profile supports three mutually exclusive completion
strategies. The default is `psc` when no preference has been saved.

```powershell
Switch-Completion native
Switch-Completion psc
Switch-Completion carapace
```

`Switch-Completion` only persists the requested mode. Open a new PowerShell
session to activate it. Running the command without an argument shows the mode
active in the current session and the mode configured for new sessions.

The preference is stored in a marked block in `~/.pwsh-profile.local.ps1` so it
stays machine-specific and preserves unrelated local profile content.

All three modes keep PSReadLine history predictions enabled in `InlineView`,
with inline prediction text rendered in dark gray.

## Mode behavior

- `native` uses PSReadLine's built-in `MenuComplete` handler without loading
  PSCompletions or Carapace.
- `psc` imports PSCompletions after PSReadLine has configured Vi mode, then
  installs the PSCompletions custom Tab handler.
- `carapace` evaluates `carapace _carapace`, then uses PSReadLine
  `MenuComplete`, as required by Carapace's PowerShell integration.

Carapace 1.7.3 was verified on Windows. Its generated PowerShell integration
registers native argument completers for each supported command, and PowerShell
does not expose a supported way to unregister those completers. For that
reason, completion providers are selected only while a new shell is starting;
do not change the active provider in place. Re-test the generated integration
and the new-session boundary after Carapace or PSReadLine upgrades.
