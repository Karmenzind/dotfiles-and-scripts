# Github: https://github.com/Karmenzind/dotfiles-and-scripts
# Last Modified: 2024-01-18 16:21:14

param(
    [int]$vimOnly
)

$isAdminMode = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Command-Exists {
    param ( [string]$commandName )
    Get-Command -Name $commandName -ErrorAction SilentlyContinue
}

if (-not $isAdminMode) {
    if (Command-Exists "pwsh") {
        Start-Process pwsh.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Wait -Verb "RunAs"
    } else {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Wait -Verb "RunAs"
    }
    Exit
}

function Ensure-Tool {
    param (
        [string]$checkCommand,
        [string]$installTool,
        [string]$packageName
    )

    if (($checkCommand -ne "") -and (Command-Exists $checkCommand)) {
        Write-Host "[OK] $packageName is already installed."
        return $true
    }

    Write-Host "[>] Command $checkCommand not found. Attempting to install using $installTool..."

    switch ($installTool) {
        "choco" {
            choco install -y $packageName
        }
        "winget" {
            $wingetInstallCommand = "winget install $packageName -e"
            Invoke-Expression -Command $wingetInstallCommand
        }
        "npm" {
            npm install -g $packageName
        }
        "pip" {
            pip install $packageName
        }
        default {
            Write-Host "[X] Unknown installation tool: $installTool"
            return $false
        }
    }

    if ($checkCommand -eq "") {
        Write-Host "[OK] Finished installing $packageName."
        return $true
    }
    # Check installation result again
    $commandExistsAfterInstall = $(Get-Command -Name $checkCommand -ErrorAction SilentlyContinue)

    if ($commandExistsAfterInstall) {
        Write-Host "[OK] $packageName has been successfully installed."
        return $true
    } else {
        Write-Host "[x] Failed to install $packageName. Please install it manually."
        return $false
    }
}

function PressToQuit {
    Write-Host ":) Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Setup-Fonts {
    # Monaco
    Write-Host "[>] Checking fonts..."
    $fontsDlDir = Join-Path $env:USERPROFILE 'Downloads\fonts'
    New-Item -ItemType Directory -Force -Path $fontsDlDir
    $monacoDir = Join-Path $fontsDlDir 'monaco-nerd'
    if (Test-Path $monacoDir) {
        Write-Host "[>] $monacoDir exists. No need to clone."
    } else {
        Write-Host "[>] Fonts files will be downloaded to $monacoDir..."
        git clone https://github.com/Karmenzind/monaco-nerd-fonts $monacoDir
    }

    foreach ($_ in Get-ChildItem -Path $(Join-Path $monacoDir "fonts")) {
        # Write-Host "Installing font: $_.Name"
        $fontFileName = Split-Path $_ -Leaf
        $srcPath = $(Join-Path "$monacoDir\fonts" $fontFileName)
        $targetPath = Join-Path "C:\Windows\Fonts" $fontFileName
        Write-Host "$_ will be installed to $targetPath"

        if (Test-Path $targetPath) {
            Write-Host "$targetPath already exists. Ignored."
            continue
        }
        if (Command-Exists Install-Font) {
            Install-Font -FontFilePath "$monacoDir\fonts\$_"
        } else {
            Copy-Item $srcPath $targetPath
        }
    }

    PressToQuit
}

# TODO
# https://hamidmosalla.com/2022/12/26/how-to-customize-windows-terminal-and-powershell-using-fzf-neovim-and-beautify-it-with-oh-my-posh/

if (-Not (Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue)) {
    winget install JanDeDobbeleer.OhMyPosh -s winget
}

Write-Host "[>] Checking basic apps..."
$null = Ensure-Tool "choco"  "winget" "chocolatey"
$null = Ensure-Tool "node"   "choco"  "nodejs"
$null = Ensure-Tool "pwsh"   "winget" "MicrosoftPowershell"
$null = Ensure-Tool "git"    "winget" "git"
$pyOk = Ensure-Tool "python" "choco"  "python"

Write-Host "[>] Checking Vim/Neovim related apps..."
$null = Ensure-Tool "vim"     "winget" "vim"
$null = Ensure-Tool "nvim"    "choco"  "neovim"
$null = Ensure-Tool "fzf"     "choco"  "fzf"
$null = Ensure-Tool "axel"    "choco"  "axel"
$null = Ensure-Tool "lua"     "winget" "DEVCOM.Lua"
$null = Ensure-Tool "rg"      "winget" "BurntSushi.ripgrep.MSVC"
$null = Ensure-Tool "bat"     "winget" "sharkdp.bat"
$null = Ensure-Tool "ctags"   "choco"  "universal-ctags"
$null = Ensure-Tool "neovide" "choco"  "neovide"

# linters / fixers / dap / etc
$null = Ensure-Tool "prettier" "npm"    "neovide"
$null = Ensure-Tool "stylua"   "choco"  "stylua"
$null = Ensure-Tool "jq"       "winget" "jqlang.jq"
$null = Ensure-Tool "mlp"      "pip"    "markdown_live_preview"
$null = Ensure-Tool "debugpy"  "pip"    "debugpy"

Setup-Fonts

if ($pyOk) {
    $null = Ensure-Tool ""          "pip" "neovim"
    $null = Ensure-Tool "ipython"   "pip" "ipython"
    $null = Ensure-Tool "autopep8"  "pip" "autopep8"
    $null = Ensure-Tool "black"     "pip" "black"
    $null = Ensure-Tool "isort"     "pip" "isort"
    $null = Ensure-Tool "autoflake" "pip" "autoflake"
}

if ($vimOnly -ne 1) {
    Write-Host ":) Installad vim related apps."
    Write-Host ":) Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit
}

Write-Host "[>] Checking regular apps..."
$null = Ensure-Tool "lf"       "winget" "gokcehan.lf"
$null = Ensure-Tool ""         "winget" "appmakes.Typora"
$null = Ensure-Tool "starship" "winget" "Starship.Starship"
$null = Ensure-Tool "conda"    "winget" "Anaconda.Miniconda3"

Write-Host ":) Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
