# System Health Monitor

This Windows-only monitor checks storage resets, disk health and free space, memory pressure, and unexpected restarts. Source files stay in this repository; runtime state and reports are written to `%LOCALAPPDATA%\SystemHealthMonitor`.

Install or update it through option 5 in the repository `install.ps1`, or run:

```powershell
pwsh -NoProfile -File .\scripts\windows\system-health\Install-SystemHealthMonitor.ps1
```

Defaults:

- Health check every 15 minutes.
- Daily report and notification at 20:00 local time.
- Immediate notification for new storage resets and other urgent events.
- Reports in `%LOCALAPPDATA%\SystemHealthMonitor\reports`.
- Scheduled checks run through `wscript.exe` without opening a terminal window.

Uninstall while keeping reports:

```powershell
pwsh -NoProfile -File .\scripts\windows\system-health\Uninstall-SystemHealthMonitor.ps1
```

Use `-PurgeData` to remove reports, history, and state as well.
