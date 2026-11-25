# Development CLI installers

The Windows development action in `install.ps1` and the Unix app setup in
`scripts/install_apps.sh` include Codex CLI, Cursor Agent CLI, Claude Code CLI,
and usql. `install.sh` delegates its development installation to the Unix script.
Editor-only and configuration-only actions do not install these tools.

## AI command-line tools

Use the vendors' standalone installers, independently of Node.js and pnpm:

| Tool | Windows PowerShell installer | Linux/macOS installer |
| --- | --- | --- |
| Codex CLI | `https://chatgpt.com/codex/install.ps1` | `https://chatgpt.com/codex/install.sh` |
| Cursor Agent CLI | `https://cursor.com/install?win32=true` | `https://cursor.com/install` |
| Claude Code CLI | `https://claude.ai/install.ps1` | `https://claude.ai/install.sh` |

Codex runs with `CODEX_NON_INTERACTIVE=1`. Re-running development setup invokes
the official installers again, including when a command is already available,
so the vendor controls installation and update behavior. No authentication or
agent session is started by setup.

Windows runs each installer in a child `powershell.exe -NoProfile` process with
process-scoped `-ExecutionPolicy Bypass`. Installer `exit` statements and
environment assignments cannot terminate or leak into the parent installer.
Nonzero child exit codes stop setup. On Unix, the pipeline uses `pipefail` in
a subshell, so a failed download cannot masquerade as a successful empty script.
Windows appends newly registered PATH entries to the installer process without
replacing the active fnm environment, so a freshly installed uv can run usql setup.
Open a new terminal after installation to pick up installer-managed PATH changes.

The Codex GUI remains separate: Store product ID `9PLM9XGG6VKS`, explicitly
selected from `msstore`, is the winget command documented by OpenAI. Do not
replace it with a similarly named CLI package or third-party application.

Official references:

- [OpenAI Windows deployment](https://learn.chatgpt.com/docs/enterprise/windows-deployment)
- [Codex installer variables](https://learn.chatgpt.com/docs/config-file/environment-variables#installer-variables)
- [Cursor CLI installation](https://cursor.com/docs/cli/installation)
- [Claude Code installation](https://code.claude.com/docs/en/setup)

## usql package sources

Verified on 2026-11-11 against the upstream README and release metadata:

- macOS: `brew install xo/xo/usql` (the upstream tap, not a bare core formula).
- Arch Linux: `yay -S --needed --noconfirm usql-bin` (the released binary;
  `usql` builds all drivers from source and is substantially slower).
- Other Linux distributions and Windows: `scripts/install_usql.py` downloads
  the matching upstream GitHub release and verifies its asset SHA-256 digest
  before replacing `~/.local/bin/usql` or `usql.exe` atomically. Linux prefers
  static builds when published to avoid distribution-specific libc requirements.
- Windows uses the existing uv bootstrap to run this standard-library-only
  Python helper; it does not install Python through winget/npm or compile usql.
  The helper's directory is added to the process and user PATH.

A live `winget search usql --source winget` found no usql package on that date;
the similarly matching NabuSQL package is unrelated. Do not invent a winget ID
or substitute another SQL client. Existing usql commands are retained.

The current upstream v0.21.6 release publishes Windows amd64 only. If a native
platform asset or SHA-256 digest is missing, setup fails explicitly instead of
silently installing a different architecture or an unverified binary. Recheck
package availability, published architectures, and asset naming after upgrades.

Unix setup captures its script directory before running package/font installers:
some existing helpers change the current directory. The usql helper, subsequent
fish setup, and the top-level Vim handoff must not depend on that working directory.

Validation uses offline release archives and mocked installer commands. It
does not install or update the tools on the workstation. Real package-manager
installation on Linux/macOS still needs platform validation.
