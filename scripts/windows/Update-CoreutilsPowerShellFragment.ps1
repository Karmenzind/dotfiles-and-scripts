#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [string] $InstallRoot = (Join-Path $env:ProgramFiles "coreutils"),
    [string] $OutputPath = (Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "dotfiles-and-scripts\powershell\coreutils-profile.ps1")
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$templatePath = Join-Path $InstallRoot "pwsh-install-template.ps1"
$cmdDir = Join-Path $InstallRoot "cmd"

if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    throw "Coreutils PowerShell template not found: $templatePath"
}
if (-not (Test-Path -LiteralPath $cmdDir -PathType Container)) {
    throw "Coreutils command directory not found: $cmdDir"
}

[string[]] $disabled = @()
$registryPath = "HKLM:\SOFTWARE\Microsoft\coreutils"
$properties = Get-ItemProperty -LiteralPath $registryPath -Name "DisabledUtilities" -ErrorAction Ignore
if ($null -ne $properties) {
    $disabled = $properties.DisabledUtilities
}
$disabledSet = [System.Collections.Generic.HashSet[string]]::new(
    $disabled,
    [System.StringComparer]::OrdinalIgnoreCase
)

$aliasSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($file in Get-ChildItem -LiteralPath $cmdDir -Filter "*.cmd" -File) {
    $aliasName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    if ($aliasName -and -not $disabledSet.Contains($aliasName)) {
        [void] $aliasSet.Add($aliasName)
    }
}
[void] $aliasSet.Remove("coreutils-manager")
if ($aliasSet.Contains("ls")) {
    [void] $aliasSet.Add("la")
}

$aliases = ($aliasSet | Sort-Object | ForEach-Object { "'$_'" }) -join ","
$normalizedCmdDir = [System.IO.Path]::GetFullPath($cmdDir).TrimEnd("\") + "\"
$fragment = Get-Content -LiteralPath $templatePath -Raw
$fragment = $fragment.Replace("'!!COREUTILS!!'", $aliases)
$fragment = $fragment.Replace("!!CMDDIR!!", $normalizedCmdDir.Replace("'", "''"))
$fragment = $fragment.TrimEnd("`r", "`n") + "`r`n"

$parent = Split-Path -LiteralPath $OutputPath
[void] (New-Item -ItemType Directory -Path $parent -Force)
$temporaryPath = "$OutputPath.new"
try {
    [System.IO.File]::WriteAllText($temporaryPath, $fragment, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::Move($temporaryPath, $OutputPath, $true)
} catch {
    Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction Ignore
    throw
}

Write-Host "Coreutils PowerShell fragment updated: $OutputPath"
