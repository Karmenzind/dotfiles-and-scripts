# Github: https://github.com/Karmenzind/dotfiles-and-scripts

param(
    [ValidateSet("1", "2", "3", "4", "5", "q")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

Set-StrictMode -Version Latest

$script:RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:IsAdmin = if ($IsWindows) {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} else {
    $false
}

function Write-Title {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message ==" -ForegroundColor Magenta
}

function Write-Step {
    param([string]$Message)
    Write-Host "🔎 $Message" -ForegroundColor Cyan
}

function Write-Install {
    param([string]$Message)
    Write-Host "📦 $Message" -ForegroundColor Blue
}

function Write-Ok {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Invoke-SelfElevated {
    param([Parameter(Mandatory)][string]$SelectedAction)

    if ($script:IsAdmin) {
        return $false
    }

    Write-Warn "This action needs an elevated PowerShell session. Requesting administrator permission..."
    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "-Action", $SelectedAction
    )
    Start-Process -FilePath "pwsh.exe" -ArgumentList $args -Verb RunAs -Wait
    return $true
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [Parameter(Mandatory)][string[]]$ArgumentList,
        [Parameter(Mandatory)][string]$Label
    )

    Write-Install $Label
    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

function Test-WingetPackageInstalled {
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Source
    )

    if (-not (Test-Command winget)) {
        return $false
    }

    $args = @("list", "--id", $Id, "--exact", "--disable-interactivity", "--accept-source-agreements")
    if ($Source) {
        $args += @("--source", $Source)
    }

    $output = & winget @args 2>$null
    return ($LASTEXITCODE -eq 0) -and (($output -join "`n") -match [regex]::Escape($Id))
}

function Ensure-WingetPackage {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Id,
        [string]$Source = "winget",
        [string]$FallbackChocoId
    )

    if (Test-WingetPackageInstalled -Id $Id -Source $Source) {
        Write-Ok "$Name is already installed."
        return $true
    }

    if (-not (Test-Command winget)) {
        Write-Warn "winget is not available."
    } else {
        try {
            $args = @(
                "install",
                "--id", $Id,
                "--exact",
                "--source", $Source,
                "--accept-package-agreements",
                "--accept-source-agreements",
                "--disable-interactivity"
            )
            Invoke-LoggedCommand -FilePath "winget" -ArgumentList $args -Label "Installing $Name with winget..."
            Write-Ok "$Name installed."
            return $true
        } catch {
            Write-Warn $_.Exception.Message
        }
    }

    if ($FallbackChocoId) {
        return Ensure-ChocoPackageFallback -Name $Name -Id $FallbackChocoId
    }

    Write-Fail "$Name was not installed."
    return $false
}

function Ensure-ChocoPackageFallback {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Id
    )

    if (-not (Test-Command choco)) {
        Write-Warn "Chocolatey is not available. Skipping fallback for $Name."
        return $false
    }

    $installed = (& choco list --local-only --limit-output 2>$null) -match "^$([regex]::Escape($Id))\|"
    if ($installed) {
        Write-Ok "$Name is already installed by Chocolatey."
        return $true
    }

    try {
        Invoke-LoggedCommand -FilePath "choco" -ArgumentList @("install", "-y", $Id) -Label "Installing $Name with Chocolatey fallback..."
        Write-Ok "$Name installed."
        return $true
    } catch {
        Write-Fail $_.Exception.Message
        return $false
    }
}

function Ensure-PwshModule {
    param([Parameter(Mandatory)][string]$Name)

    if (Get-Module -ListAvailable -Name $Name) {
        Write-Ok "PowerShell module $Name is already installed."
        return
    }

    Write-Install "Installing PowerShell module $Name..."
    Install-Module -Name $Name -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
    Write-Ok "PowerShell module $Name installed."
}

function Ensure-UvTool {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Package = $Name
    )

    if (-not (Test-Command uv)) {
        Write-Warn "uv is not available. Skipping Python tool $Name."
        return
    }

    $tools = & uv tool list 2>$null
    if (($tools -join "`n") -match "(?m)^$([regex]::Escape($Name))\s") {
        Write-Ok "uv tool $Name is already installed."
        return
    }

    Invoke-LoggedCommand -FilePath "uv" -ArgumentList @("tool", "install", $Package) -Label "Installing uv tool $Package..."
    Write-Ok "uv tool $Package installed."
}

function Ensure-PnpmGlobalPackage {
    param(
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string]$Package
    )

    if (Test-Command $Command) {
        Write-Ok "$Command is already available."
        return
    }

    if (-not (Test-Command pnpm)) {
        Write-Warn "pnpm is not available. Skipping $Package."
        return
    }

    Invoke-LoggedCommand -FilePath "pnpm" -ArgumentList @("add", "-g", $Package) -Label "Installing $Package with pnpm..."
    Write-Ok "$Package installed."
}

function Ensure-FnmNodeLts {
    Ensure-WingetPackage -Name "Fast Node Manager" -Id "Schniz.fnm" | Out-Null

    if (-not (Test-Command fnm)) {
        Write-Warn "fnm is not available after installation. Open a new shell and run this script again."
        return
    }

    Invoke-LoggedCommand -FilePath "fnm" -ArgumentList @("install", "--lts") -Label "Installing Node.js LTS with fnm..."
    Invoke-LoggedCommand -FilePath "fnm" -ArgumentList @("default", "lts-latest") -Label "Setting Node.js LTS as the fnm default..."

    $fnmEnv = & fnm env --shell powershell
    $fnmEnv | Invoke-Expression
    Write-Ok "Node.js LTS is managed by fnm."
}

function Enable-CorepackPnpm {
    if (-not (Test-Command corepack)) {
        Write-Warn "corepack is not available. Ensure Node.js is active through fnm, then rerun this step."
        return
    }

    Invoke-LoggedCommand -FilePath "corepack" -ArgumentList @("enable") -Label "Enabling corepack..."
    Invoke-LoggedCommand -FilePath "corepack" -ArgumentList @("prepare", "pnpm@latest", "--activate") -Label "Activating latest pnpm through corepack..."
    Write-Ok "pnpm is managed by corepack."
}

function Set-UserEnvironment {
    Write-Step "Configuring user environment variables..."
    [Environment]::SetEnvironmentVariable("EDITOR", "nvim.exe", "User")
    [Environment]::SetEnvironmentVariable("VISUAL", "nvim.exe", "User")
    [Environment]::SetEnvironmentVariable("SHELL", "pwsh.exe", "User")
    $env:EDITOR = "nvim.exe"
    $env:VISUAL = "nvim.exe"
    $env:SHELL = "pwsh.exe"
    Write-Ok "User environment variables configured."
}

function Set-WindowsTerminalDefaultPwsh {
    Write-Step "Configuring Windows Terminal default profile..."

    $settingsPaths = @(
        Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    )

    foreach ($path in $settingsPaths) {
        if (-not (Test-Path $path)) {
            continue
        }

        try {
            $settings = Get-Content -Raw -Path $path | ConvertFrom-Json
            $profiles = @($settings.profiles.list)
            $pwshProfile = $profiles | Where-Object {
                $commandlineProperty = $_.PSObject.Properties["commandline"]
                $nameProperty = $_.PSObject.Properties["name"]
                $commandline = if ($commandlineProperty) { [string]$commandlineProperty.Value } else { "" }
                $profileName = if ($nameProperty) { [string]$nameProperty.Value } else { "" }
                ($commandline -match "(^|\\)pwsh(\.exe)?(\s|$)") -or ($profileName -match "PowerShell")
            } | Select-Object -First 1

            if (-not $pwshProfile) {
                Write-Warn "No pwsh profile found in $path."
                continue
            }

            $guidProperty = $pwshProfile.PSObject.Properties["guid"]
            $nameProperty = $pwshProfile.PSObject.Properties["name"]
            if (-not $guidProperty) {
                Write-Warn "The pwsh profile in $path does not have a guid."
                continue
            }

            $settings.defaultProfile = $guidProperty.Value
            $settings | ConvertTo-Json -Depth 100 | Set-Content -Path $path -Encoding UTF8
            $profileName = if ($nameProperty) { $nameProperty.Value } else { $guidProperty.Value }
            Write-Ok "Windows Terminal default profile set to $profileName."
        } catch {
            Write-Warn "Failed to update Windows Terminal settings at $path`: $($_.Exception.Message)"
        }
    }
}

function Get-RegisteredFileAssociations {
    param([Parameter(Mandatory)][string]$CapabilityPath)

    $key = "HKLM:\$CapabilityPath\FileAssociations"
    if (-not (Test-Path $key)) {
        $key = "HKCU:\$CapabilityPath\FileAssociations"
    }
    if (-not (Test-Path $key)) {
        return @{}
    }

    $props = Get-ItemProperty -Path $key
    $result = @{}
    foreach ($prop in $props.PSObject.Properties) {
        if ($prop.Name -like "PS*") {
            continue
        }
        $result[$prop.Name] = [string]$prop.Value
    }
    return $result
}

function Set-MediaDefaultsBestEffort {
    Write-Step "Configuring default media apps best-effort..."

    $registered = Get-ItemProperty "HKLM:\Software\RegisteredApplications" -ErrorAction SilentlyContinue
    $potProperty = if ($registered) { $registered.PSObject.Properties["PotPlayerMini64"] } else { $null }
    $foobarProperty = if ($registered) { $registered.PSObject.Properties["foobar2000"] } else { $null }
    $potCapability = if ($potProperty) { [string]$potProperty.Value } else { $null }
    $foobarCapability = if ($foobarProperty) { [string]$foobarProperty.Value } else { $null }

    if (-not $potCapability -or -not $foobarCapability) {
        Write-Warn "PotPlayer or foobar2000 registration was not found. Opening Default apps settings."
        Start-Process "ms-settings:defaultapps"
        return
    }

    $videoExts = @(".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".webm", ".m4v")
    $audioExts = @(".mp3", ".flac", ".wav", ".m4a", ".aac", ".ogg", ".opus", ".wma")
    $potAssociations = Get-RegisteredFileAssociations -CapabilityPath $potCapability
    $foobarAssociations = Get-RegisteredFileAssociations -CapabilityPath $foobarCapability
    $rows = New-Object System.Collections.Generic.List[string]

    foreach ($ext in $videoExts) {
        if ($potAssociations.ContainsKey($ext)) {
            $rows.Add("  <Association Identifier=`"$ext`" ProgId=`"$($potAssociations[$ext])`" ApplicationName=`"PotPlayer`" />")
        }
    }

    foreach ($ext in $audioExts) {
        if ($foobarAssociations.ContainsKey($ext)) {
            $rows.Add("  <Association Identifier=`"$ext`" ProgId=`"$($foobarAssociations[$ext])`" ApplicationName=`"foobar2000`" />")
        }
    }

    if ($rows.Count -eq 0) {
        Write-Warn "No media associations were discovered. Opening Default apps settings."
        Start-Process "ms-settings:defaultapps"
        return
    }

    $xmlPath = Join-Path $env:TEMP "dotfiles-media-defaults.xml"
    $xml = @(
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<DefaultAssociations>',
        $rows,
        '</DefaultAssociations>'
    )
    $xml | Set-Content -Path $xmlPath -Encoding UTF8

    if ($script:IsAdmin) {
        try {
            Invoke-LoggedCommand -FilePath "dism.exe" -ArgumentList @("/Online", "/Import-DefaultAppAssociations:$xmlPath") -Label "Importing default app associations..."
            Write-Ok "Default app associations were imported. Windows may still require confirmation for the current user."
        } catch {
            Write-Warn $_.Exception.Message
        }
    } else {
        Write-Warn "Default association import requires an elevated shell."
    }

    Write-Warn "If the defaults did not change, choose PotPlayer for video and foobar2000 for audio in Windows Settings."
    Start-Process "ms-settings:defaultapps"
}

function Install-MonacoNerdFont {
    Write-Step "Checking Monaco Nerd Font..."

    if (-not (Test-Command git)) {
        Write-Warn "git is not available. Skipping font installation."
        return
    }

    $fontsDlDir = Join-Path $env:USERPROFILE "Downloads\fonts"
    $monacoDir = Join-Path $fontsDlDir "monaco-nerd"
    $fontSourceDir = Join-Path $monacoDir "fonts"
    New-Item -ItemType Directory -Force -Path $fontsDlDir | Out-Null

    if (-not (Test-Path $monacoDir)) {
        Invoke-LoggedCommand -FilePath "git" -ArgumentList @("clone", "https://github.com/Karmenzind/monaco-nerd-fonts", $monacoDir) -Label "Downloading Monaco Nerd Font..."
    }

    if (-not (Test-Path $fontSourceDir)) {
        Write-Warn "Font source folder not found: $fontSourceDir"
        return
    }

    $shell = New-Object -ComObject Shell.Application
    $fontsFolder = $shell.Namespace(0x14)

    foreach ($font in Get-ChildItem -Path $fontSourceDir -File) {
        $target = Join-Path "C:\Windows\Fonts" $font.Name
        if (Test-Path $target) {
            Write-Ok "$($font.Name) is already installed."
            continue
        }

        Write-Install "Installing font $($font.Name)..."
        $fontsFolder.CopyHere($font.FullName)
    }
}

function Install-PackageSet {
    param([Parameter(Mandatory)][array]$Packages)

    foreach ($package in $Packages) {
        Ensure-WingetPackage @package | Out-Null
    }
}

$script:CommonPackages = @(
    @{ Name = "Google Chrome"; Id = "Google.Chrome" },
    @{ Name = "Windows Terminal"; Id = "Microsoft.WindowsTerminal" },
    @{ Name = "Microsoft PowerToys"; Id = "Microsoft.PowerToys" },
    @{ Name = "CCleaner"; Id = "Piriform.CCleaner" },
    @{ Name = "Neovim"; Id = "Neovim.Neovim"; FallbackChocoId = "neovim" },
    @{ Name = "Spotify"; Id = "Spotify.Spotify" },
    @{ Name = "7-Zip"; Id = "7zip.7zip" },
    @{ Name = "Bitwarden"; Id = "Bitwarden.Bitwarden" },
    @{ Name = "ChatGPT"; Id = "9NT1R1C2HH7J"; Source = "msstore" },
    @{ Name = "CPUID CPU-Z"; Id = "CPUID.CPU-Z" },
    @{ Name = "FFmpeg"; Id = "Gyan.FFmpeg"; FallbackChocoId = "ffmpeg" },
    @{ Name = "ImageMagick"; Id = "ImageMagick.ImageMagick" },
    @{ Name = "Yazi"; Id = "sxyazi.yazi" },
    @{ Name = "RMUX"; Id = "Helvesec.RMUX" },
    @{ Name = "Git"; Id = "Git.Git" },
    @{ Name = "Codex GUI app"; Id = "9PLM9XGG6VKS"; Source = "msstore" }
)

$script:DevPackages = @(
    @{ Name = "PowerShell"; Id = "Microsoft.PowerShell" },
    @{ Name = "uv"; Id = "astral-sh.uv" },
    @{ Name = "Oh My Posh"; Id = "JanDeDobbeleer.OhMyPosh" },
    @{ Name = "fzf"; Id = "junegunn.fzf" },
    @{ Name = "fd"; Id = "sharkdp.fd" },
    @{ Name = "bat"; Id = "sharkdp.bat" },
    @{ Name = "ripgrep"; Id = "BurntSushi.ripgrep.MSVC" },
    @{ Name = "jq"; Id = "jqlang.jq" },
    @{ Name = "zoxide"; Id = "ajeetdsouza.zoxide" },
    @{ Name = "lazygit"; Id = "JesseDuffield.lazygit" },
    @{ Name = "Lua"; Id = "DEVCOM.Lua" },
    @{ Name = "clangd"; Id = "LLVM.clangd" },
    @{ Name = "Go"; Id = "GoLang.Go" },
    @{ Name = "Temurin JDK 17"; Id = "EclipseAdoptium.Temurin.17.JDK" },
    @{ Name = "Vim"; Id = "vim.vim" },
    @{ Name = "universal-ctags"; Id = "UniversalCtags.Ctags"; FallbackChocoId = "universal-ctags" },
    @{ Name = "StyLua"; Id = "JohnnyMorganz.StyLua"; FallbackChocoId = "stylua" },
    @{ Name = "Neovide"; Id = "Neovide.Neovide"; FallbackChocoId = "neovide" },
    @{ Name = "lf"; Id = "gokcehan.lf" },
    @{ Name = "Typora"; Id = "appmakes.Typora" },
    @{ Name = "Starship"; Id = "Starship.Starship" }
)

$script:MediaPackages = @(
    @{ Name = "PotPlayer"; Id = "Daum.PotPlayer" },
    @{ Name = "foobar2000"; Id = "PeterPawlowski.foobar2000" }
)

$script:PwshModules = @("PSReadLine", "Terminal-Icons", "PSCompletions", "PsFZF")
$script:UvTools = @(
    @{ Name = "ipython"; Package = "ipython" },
    @{ Name = "debugpy"; Package = "debugpy" },
    @{ Name = "black"; Package = "black" },
    @{ Name = "isort"; Package = "isort" },
    @{ Name = "autoflake"; Package = "autoflake" },
    @{ Name = "ruff"; Package = "ruff" },
    @{ Name = "pgcli"; Package = "pgcli" },
    @{ Name = "markdown-live-preview"; Package = "markdown-live-preview" },
    @{ Name = "pynvim"; Package = "pynvim" }
)

function Install-CommonBaseline {
    Write-Title "Common baseline apps"
    Install-PackageSet -Packages $script:CommonPackages
    Set-UserEnvironment
}

function Install-DevelopmentEnvironment {
    Install-CommonBaseline

    Write-Title "Development environment"
    Install-PackageSet -Packages $script:DevPackages

    Ensure-FnmNodeLts
    Enable-CorepackPnpm
    Ensure-PnpmGlobalPackage -Command "codex" -Package "@openai/codex"

    foreach ($module in $script:PwshModules) {
        Ensure-PwshModule -Name $module
    }

    foreach ($tool in $script:UvTools) {
        Ensure-UvTool @tool
    }

    Install-MonacoNerdFont
    Set-WindowsTerminalDefaultPwsh
}

function Install-PersonalMediaEnvironment {
    Install-CommonBaseline

    Write-Title "Personal and media environment"
    Install-PackageSet -Packages $script:MediaPackages
    Set-MediaDefaultsBestEffort
}

function Configure-DefaultsOnly {
    Write-Title "Default configuration"
    Set-UserEnvironment
    Set-WindowsTerminalDefaultPwsh
    Set-MediaDefaultsBestEffort
}

function Install-SystemHealthMonitorTask {
    Write-Title "System health monitor"
    $installer = Join-Path $script:RepoRoot "scripts\windows\system-health\Install-SystemHealthMonitor.ps1"
    & $installer -SkipElevation
    Write-Ok "System health monitor installed or updated."
}

function Show-Menu {
    Write-Host ""
    Write-Host "What do you want to do? (default: 1)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1) 🧑‍💻 Install development environment"
    Write-Host "2) 🎧 Install personal/media environment"
    Write-Host "3) 🧰 Install common baseline apps only"
    Write-Host "4) ⚙️  Configure defaults only"
    Write-Host "5) 🩺 Install/update system health monitor"
    Write-Host "q) Quit"
    Write-Host ""
}

function Invoke-Main {
    if (-not $IsWindows) {
        Write-Fail "This script only supports Windows."
        return
    }

    if ($Action) {
        $answer = $Action
    } else {
        Show-Menu
        $answer = Read-Host "Select an option"
    }

    if ([string]::IsNullOrWhiteSpace($answer)) {
        $answer = "1"
    }

    if (($answer -ne "q") -and ($answer -in @("1", "2", "3", "4", "5")) -and (Invoke-SelfElevated -SelectedAction $answer)) {
        return
    }

    switch ($answer.Trim().ToLowerInvariant()) {
        "1" { Install-DevelopmentEnvironment }
        "2" { Install-PersonalMediaEnvironment }
        "3" { Install-CommonBaseline }
        "4" { Configure-DefaultsOnly }
        "5" { Install-SystemHealthMonitorTask }
        "q" { Write-Warn "No action selected." }
        default { Write-Fail "Invalid option: $answer" }
    }

    Write-Host ""
    Write-Ok "Done."
}

Invoke-Main
