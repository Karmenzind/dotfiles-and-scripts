[CmdletBinding()]
param(
    [ValidateRange(5, 1440)]
    [int]$IntervalMinutes = 15,
    [string]$DailySummaryTime = "20:00",
    [switch]$SkipElevation
)

$ErrorActionPreference = "Stop"

function Test-IsAdministrator {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $SkipElevation -and -not (Test-IsAdministrator)) {
    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "-IntervalMinutes", $IntervalMinutes,
        "-DailySummaryTime", $DailySummaryTime,
        "-SkipElevation"
    )
    Start-Process -FilePath "pwsh.exe" -ArgumentList $arguments -Verb RunAs -Wait
    return
}

$sourceScript = Join-Path $PSScriptRoot "SystemHealthMonitor.ps1"
$sourceRunner = Join-Path $PSScriptRoot "Run-SystemHealthMonitorHidden.vbs"
$dataRoot = Join-Path $env:LOCALAPPDATA "SystemHealthMonitor"
$binRoot = Join-Path $dataRoot "bin"
$deployedScript = Join-Path $binRoot "SystemHealthMonitor.ps1"
$deployedRunner = Join-Path $binRoot "Run-SystemHealthMonitorHidden.vbs"
New-Item -ItemType Directory -Path $binRoot -Force | Out-Null
Copy-Item -Path $sourceScript -Destination $deployedScript -Force
Copy-Item -Path $sourceRunner -Destination $deployedRunner -Force

$wscript = Join-Path $env:WINDIR "System32\wscript.exe"
$userId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -MultipleInstances IgnoreNew

$checkAction = New-ScheduledTaskAction -Execute $wscript -Argument "//B //Nologo `"$deployedRunner`" `"$deployedScript`""
$checkTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) -RepetitionDuration (New-TimeSpan -Days 3650)
Register-ScheduledTask -TaskName "System Health Monitor - Check" -Action $checkAction -Trigger $checkTrigger -Principal $principal -Settings $settings -Description "Checks memory, disks, storage reset events, and unexpected restarts." -Force | Out-Null

try {
    $dailyAt = [datetime]::Today.Add([timespan]::Parse($DailySummaryTime))
} catch {
    throw "DailySummaryTime must use HH:mm format."
}
$dailyAction = New-ScheduledTaskAction -Execute $wscript -Argument "//B //Nologo `"$deployedRunner`" `"$deployedScript`" -DailySummary"
$dailyTrigger = New-ScheduledTaskTrigger -Daily -At $dailyAt
Register-ScheduledTask -TaskName "System Health Monitor - Daily Summary" -Action $dailyAction -Trigger $dailyTrigger -Principal $principal -Settings $settings -Description "Creates the daily system health report and notification." -Force | Out-Null

& pwsh -NoProfile -ExecutionPolicy Bypass -File $deployedScript -NoNotify

Write-Output "System Health Monitor installed."
Write-Output "Runtime: $deployedScript"
Write-Output "Reports: $(Join-Path $dataRoot 'reports')"
Get-ScheduledTask -TaskName "System Health Monitor*" | Select-Object TaskName, State
