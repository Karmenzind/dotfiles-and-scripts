# Windows Neovim gopls installation failure

## Verified on 2026-10-05

Mason repeatedly failed to install `gopls v0.23.0` with
`verifying module: missing GOSUMDB`. This was an environment failure, separate
from the legacy-project gopls compatibility configuration introduced in commit
`5798ea6`.

The effective `go.exe` was `C:\Program Files\Go\bin\go.exe` (Go 1.26.5), but
the machine environment still specified `GOROOT=C:\Go`. That directory existed
without `go.env`. Consequently, `go env GOSUMDB GOTOOLCHAIN` returned empty
values even though the actual installation's `go.env` contained
`GOSUMDB=sum.golang.org` and `GOTOOLCHAIN=auto`.

Removing `GOROOT` only in an isolated PowerShell process restored the inferred
root to `C:\Program Files\Go` and both defaults to their expected values.
After explicit user authorization, the obsolete machine-level `GOROOT=C:\Go`
was removed through a Windows UAC elevated process. A subsequent registry read
confirmed it was absent, and an isolated process with the inherited GOROOT
cleared again reported the correct root and defaults. Installation was not
retried during diagnosis; existing editor and terminal processes still need
to be restarted to discard their inherited environment.

The existing Neovim configuration remains active through the live `init.lua`
symlink. It excludes Mason's gopls installation when the detected Go version
is older than 1.21, and lazily installs `gopls v0.15.3` for the specific legacy
project `D:/Workspace/oj/ipc-client`. It does not repair inherited Go environment
variables or provide automatic compatibility selection for every project.

## Remediation and revisit

Remove the obsolete machine-level `GOROOT` override, allowing the installed Go
binary to infer its root. Keep deliberate process-level GOROOT settings used by
GVM when activating a project version. Restart the editor and its launching
terminal after changing the persistent environment, check `go env GOROOT
GOSUMDB GOTOOLCHAIN`, then retry Mason's gopls installation.

Do not disable checksum verification with `GOSUMDB=off` or hard-code a GOROOT
in the shared Neovim configuration to mask this machine-specific mismatch.
After a Go/GVM upgrade or any recurrence, recheck the executable path, effective
GOROOT, and that root's `go.env`; this evidence does not establish an upstream
Go, GVM, or Mason defect.
