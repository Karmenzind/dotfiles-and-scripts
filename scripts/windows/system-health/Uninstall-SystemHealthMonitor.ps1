[CmdletBinding()]
param(
    [switch]$PurgeData,
    [switch]$SkipElevation
)

$ErrorActionPreference = "Stop"

function Test-IsAdministrator {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $SkipElevation -and -not (Test-IsAdministrator)) {
    $arguments = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"", "-SkipElevation")
    if ($PurgeData) {
        $arguments += "-PurgeData"
    }
    Start-Process -FilePath "pwsh.exe" -ArgumentList $arguments -Verb RunAs -Wait
    return
}

Get-ScheduledTask -TaskName "System Health Monitor*" -ErrorAction SilentlyContinue |
    Unregister-ScheduledTask -Confirm:$false

$dataRoot = Join-Path $env:LOCALAPPDATA "SystemHealthMonitor"
if ($PurgeData) {
    if (Test-Path $dataRoot) {
        Remove-Item -LiteralPath $dataRoot -Recurse -Force
    }
    Write-Output "Scheduled tasks and runtime data removed."
} else {
    $binRoot = Join-Path $dataRoot "bin"
    if (Test-Path $binRoot) {
        Remove-Item -LiteralPath $binRoot -Recurse -Force
    }
    Write-Output "Scheduled tasks and runtime removed. Reports and history were kept."
}

