[CmdletBinding()]
param(
    [switch]$DailySummary,
    [switch]$NoNotify,
    [int]$SimulateStorageResets = 0,
    [Nullable[double]]$SimulateMemoryUsedPct
)

$ErrorActionPreference = "SilentlyContinue"
$dataRoot = Join-Path $env:LOCALAPPDATA "SystemHealthMonitor"
$reportRoot = Join-Path $dataRoot "reports"
$statePath = Join-Path $dataRoot "state.json"
$historyPath = Join-Path $dataRoot "history.csv"
New-Item -ItemType Directory -Path $reportRoot -Force | Out-Null

function Get-MonitorState {
    if (Test-Path $statePath) {
        try {
            return Get-Content -Raw $statePath | ConvertFrom-Json -AsHashtable
        } catch {
            # Start with clean state if a previous run was interrupted while writing.
        }
    }

    return @{
        LastCheckUtc = $null
        LastAlertUtc = $null
        HighMemorySamples = 0
        Firmware = @{}
    }
}

function Show-SystemHealthNotification {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Body
    )

    if ($NoNotify) {
        return
    }

    try {
        $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
        $escapedTitle = [System.Security.SecurityElement]::Escape($Title)
        $escapedBody = [System.Security.SecurityElement]::Escape($Body)
        $toastXml = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$escapedTitle</text>
      <text>$escapedBody</text>
    </binding>
  </visual>
</toast>
"@
        $xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
        $xml.LoadXml($toastXml)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Microsoft.PowerShell_8wekyb3d8bbwe!App")
        $notifier.Show($toast)
        return
    } catch {
        $msg = Get-Command msg.exe -ErrorAction SilentlyContinue
        if ($msg) {
            & $msg.Source $env:USERNAME /TIME:180 "$Title`n$Body" 2>$null
        }
    }
}

$now = Get-Date
$nowUtc = $now.ToUniversalTime()
$state = Get-MonitorState
foreach ($requiredKey in "LastCheckUtc", "LastAlertUtc", "HighMemorySamples", "Firmware") {
    if (-not $state.ContainsKey($requiredKey)) {
        $state[$requiredKey] = if ($requiredKey -eq "Firmware") { @{} } elseif ($requiredKey -eq "HighMemorySamples") { 0 } else { $null }
    }
}

$os = Get-CimInstance Win32_OperatingSystem
$boot = $os.LastBootUpTime
$lastCheck = if ($state.LastCheckUtc) {
    [datetime]::Parse($state.LastCheckUtc).ToLocalTime()
} else {
    $now.AddMinutes(-1)
}
if ($lastCheck -lt $boot) {
    $lastCheck = $boot
}

$totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$measuredUsedPct = [math]::Round((1 - $os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100, 1)
$usedPct = if ($null -ne $SimulateMemoryUsedPct) { [double]$SimulateMemoryUsedPct } else { $measuredUsedPct }
$commitUsedGB = [math]::Round(($os.TotalVirtualMemorySize - $os.FreeVirtualMemory) / 1MB, 2)
$commitLimitGB = [math]::Round($os.TotalVirtualMemorySize / 1MB, 2)

if ($usedPct -ge 85) {
    $state.HighMemorySamples = [int]$state.HighMemorySamples + 1
} else {
    $state.HighMemorySamples = 0
}

$volumes = @(Get-Volume | Where-Object DriveLetter | Sort-Object DriveLetter | ForEach-Object {
    [pscustomobject]@{
        Drive = "$($_.DriveLetter):"
        Health = $_.HealthStatus
        FreeGB = [math]::Round($_.SizeRemaining / 1GB, 2)
        SizeGB = [math]::Round($_.Size / 1GB, 2)
        FreePct = [math]::Round(100 * $_.SizeRemaining / $_.Size, 1)
    }
})

$physicalDisks = @(Get-PhysicalDisk | Sort-Object FriendlyName | ForEach-Object {
    [pscustomobject]@{
        Name = $_.FriendlyName
        Firmware = $_.FirmwareVersion
        Health = $_.HealthStatus
        Operational = ($_.OperationalStatus -join ", ")
    }
})

$storageResets = @(Get-WinEvent -FilterHashtable @{
    LogName = "System"
    ProviderName = "iaStorVD"
    Id = 129
    StartTime = $lastCheck
} | Where-Object TimeCreated -gt $lastCheck)

if ($SimulateStorageResets -gt 0) {
    $storageResets = @($storageResets) + @(1..$SimulateStorageResets | ForEach-Object {
        [pscustomobject]@{ TimeCreated = $now; Message = "Simulated iaStorVD reset" }
    })
}

$diskErrors = @(Get-WinEvent -FilterHashtable @{
    LogName = "System"
    StartTime = $lastCheck
} | Where-Object {
    $_.TimeCreated -gt $lastCheck -and
    $_.ProviderName -match "disk|stor|nvme|Ntfs" -and
    $_.ProviderName -ne "iaStorVD" -and
    $_.Level -le 3 -and
    $_.Id -in 7, 11, 15, 51, 55, 57, 129, 153, 157
})

$unexpectedRestarts = @(Get-WinEvent -FilterHashtable @{
    LogName = "System"
    ProviderName = "Microsoft-Windows-Kernel-Power"
    Id = 41
    StartTime = $lastCheck
} | Where-Object TimeCreated -gt $lastCheck)

$topProcesses = @(Get-Process | Group-Object ProcessName | ForEach-Object {
    [pscustomobject]@{
        Name = $_.Name
        Count = $_.Count
        WorkingMB = [math]::Round(($_.Group | Measure-Object WorkingSet64 -Sum).Sum / 1MB, 1)
        PrivateMB = [math]::Round(($_.Group | Measure-Object PrivateMemorySize64 -Sum).Sum / 1MB, 1)
    }
} | Sort-Object PrivateMB -Descending | Select-Object -First 10)

$alerts = [System.Collections.Generic.List[string]]::new()
$recommendations = [System.Collections.Generic.List[string]]::new()
$firmwareChanges = [System.Collections.Generic.List[string]]::new()

foreach ($disk in $physicalDisks) {
    $previous = $state.Firmware[$disk.Name]
    if ($previous -and $previous -ne $disk.Firmware) {
        $firmwareChanges.Add("$($disk.Name): $previous -> $($disk.Firmware)")
    }
    $state.Firmware[$disk.Name] = $disk.Firmware
}

if ($storageResets.Count -gt 0) {
    $alerts.Add("Storage controller reset: $($storageResets.Count) new iaStorVD 129 event(s).")
    $recommendations.Add("Back up important files. If resets continue after SSD firmware updates, investigate both SSDs, M.2 slots, and the Intel VMD controller.")
}
if ($diskErrors.Count -gt 0) {
    $alerts.Add("Other storage warnings or errors: $($diskErrors.Count).")
    $recommendations.Add("Review event details and run each SSD vendor diagnostic.")
}
if ($unexpectedRestarts.Count -gt 0) {
    $alerts.Add("Unexpected restart: $($unexpectedRestarts.Count) new Kernel-Power 41 event(s).")
    $recommendations.Add("Check whether the system froze or lost power immediately before the restart.")
}
if (@($physicalDisks | Where-Object { $_.Health -ne "Healthy" -or $_.Operational -notmatch "OK" }).Count -gt 0) {
    $alerts.Add("A physical disk is not reporting Healthy/OK.")
    $recommendations.Add("Back up data immediately and run the manufacturer diagnostic tool.")
}
if ($usedPct -ge 95 -or [int]$state.HighMemorySamples -ge 2) {
    $alerts.Add("High memory usage: $usedPct% used; consecutive samples: $($state.HighMemorySamples).")
    if ($topProcesses.Count -gt 0) {
        $recommendations.Add("Review the largest process group: $($topProcesses[0].Name) ($($topProcesses[0].PrivateMB) MB private).")
    }
}

$lowVolumes = @($volumes | Where-Object FreePct -lt 10)
if ($lowVolumes.Count -gt 0) {
    $driveText = ($lowVolumes | ForEach-Object { "$($_.Drive) $($_.FreeGB) GB ($($_.FreePct)%)" }) -join "; "
    $alerts.Add("Low disk free space: $driveText.")
    $recommendations.Add("Keep at least 10% free; target about 100 GB on C: and 60 GB on D: for this machine.")
}

$alertLines = if ($alerts.Count) { ($alerts | ForEach-Object { "- $_" }) -join "`n" } else { "- No current alerts." }
$recommendationLines = if ($recommendations.Count) { ($recommendations | Select-Object -Unique | ForEach-Object { "- $_" }) -join "`n" } else { "- No action required. Continue monitoring." }
$firmwareLines = if ($firmwareChanges.Count) { ($firmwareChanges | ForEach-Object { "- $_" }) -join "`n" } else { "- No firmware changes since the previous recorded version." }
$resetLines = if ($storageResets.Count) { ($storageResets | ForEach-Object { "- $($_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')): $($_.Message)" }) -join "`n" } else { "- None since the previous check." }
$volumeLines = ($volumes | ForEach-Object { "| $($_.Drive) | $($_.Health) | $($_.FreeGB) | $($_.SizeGB) | $($_.FreePct)% |" }) -join "`n"
$diskLines = ($physicalDisks | ForEach-Object { "| $($_.Name) | $($_.Firmware) | $($_.Health) | $($_.Operational) |" }) -join "`n"
$processLines = ($topProcesses | ForEach-Object { "| $($_.Name) | $($_.Count) | $($_.WorkingMB) | $($_.PrivateMB) |" }) -join "`n"

$report = @"
# System Health Report

Generated: $($now.ToString('yyyy-MM-dd HH:mm:ss zzz'))
Last boot: $($boot.ToString('yyyy-MM-dd HH:mm:ss'))
Previous check: $($lastCheck.ToString('yyyy-MM-dd HH:mm:ss'))

## Summary

$alertLines

## Memory

- Physical memory: $totalGB GB
- Used: $usedPct%
- Free: $freeGB GB
- Commit: $commitUsedGB / $commitLimitGB GB
- Consecutive high-memory samples: $($state.HighMemorySamples)

## Volumes

| Drive | Health | Free GB | Size GB | Free |
|---|---|---:|---:|---:|
$volumeLines

## Physical Disks

| Disk | Firmware | Health | Operational |
|---|---|---|---|
$diskLines

## Firmware Changes

$firmwareLines

## New Storage Resets

$resetLines

## Top Process Groups

| Process | Count | Working MB | Private MB |
|---|---:|---:|---:|
$processLines

## Recommendations

$recommendationLines
"@

$latestPath = Join-Path $reportRoot "latest.md"
Set-Content -Path $latestPath -Value $report -Encoding utf8

if ($DailySummary) {
    Set-Content -Path (Join-Path $reportRoot ("daily-{0}.md" -f $now.ToString("yyyy-MM-dd"))) -Value $report -Encoding utf8
}
if ($storageResets.Count -or $diskErrors.Count -or $unexpectedRestarts.Count) {
    Set-Content -Path (Join-Path $reportRoot ("incident-{0}.md" -f $now.ToString("yyyyMMdd-HHmmss"))) -Value $report -Encoding utf8
}

[pscustomobject]@{
    Timestamp = $now.ToString("o")
    MemoryUsedPct = $usedPct
    FreeMemoryGB = $freeGB
    CommitUsedGB = $commitUsedGB
    CFreeGB = ($volumes | Where-Object Drive -eq "C:").FreeGB
    DFreeGB = ($volumes | Where-Object Drive -eq "D:").FreeGB
    NewStorageResets = $storageResets.Count
    NewDiskErrors = $diskErrors.Count
} | Export-Csv -Path $historyPath -Append -NoTypeInformation -Encoding utf8

if ($DailySummary) {
    $historyCutoff = $now.AddDays(-90)
    $retainedHistory = @(Import-Csv $historyPath | Where-Object { [datetime]$_.Timestamp -ge $historyCutoff })
    $retainedHistory | Export-Csv -Path $historyPath -NoTypeInformation -Encoding utf8
    Get-ChildItem $reportRoot -Filter "daily-*.md" | Where-Object LastWriteTime -lt $now.AddDays(-90) | Remove-Item -Force
    Get-ChildItem $reportRoot -Filter "incident-*.md" | Where-Object LastWriteTime -lt $now.AddDays(-180) | Remove-Item -Force
}

$lastAlertUtc = if ($state.LastAlertUtc) { [datetime]::Parse($state.LastAlertUtc).ToUniversalTime() } else { [datetime]::MinValue }
$cooldownExpired = ($nowUtc - $lastAlertUtc).TotalHours -ge 6
$urgent = $storageResets.Count -gt 0 -or $diskErrors.Count -gt 0 -or $unexpectedRestarts.Count -gt 0 -or $usedPct -ge 95

if ($alerts.Count -gt 0 -and ($urgent -or $cooldownExpired)) {
    $summary = ($alerts | Select-Object -First 3) -join "`n"
    Show-SystemHealthNotification -Title "System Health Monitor" -Body "$summary`nReport: $latestPath"
    if (-not $NoNotify) {
        $state.LastAlertUtc = $nowUtc.ToString("o")
    }
} elseif ($DailySummary) {
    Show-SystemHealthNotification -Title "System Health Monitor daily summary" -Body "Memory: $usedPct% | Alerts: $($alerts.Count)`nReport: $latestPath"
}

$state.LastCheckUtc = $nowUtc.ToString("o")
$state | ConvertTo-Json -Depth 5 | Set-Content -Path $statePath -Encoding utf8

Write-Output "Report: $latestPath"
Write-Output "Alerts: $($alerts.Count)"
