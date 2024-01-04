$isAdminMode = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Command-Exists {
    param ( 
        [string]$commandName
    )
    Get-Command -Name $commandName -ErrorAction SilentlyContinue
}

if (-not $isAdminMode) {
    if (Command-Exists "pwsh") {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Wait -Verb "RunAs"
    }
    else {
        Start-Process pwsh.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Wait -Verb "RunAs"
    }
    Exit
}


function Ensure-Tool {
    param (
        [string]$checkCommand,
        [string]$installTool,
        [string]$packageName
    )

    if (Command-Exists $checkCommand) {
        Write-Host "[OK] $checkCommand is already installed."
        return $true
    }
     
    Write-Host "[>] $checkCommand is not installed. Attempting to install using $installTool..."

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

    # Check installation result again
    $commandExistsAfterInstall = Get-Command -Name $checkCommand -ErrorAction SilentlyContinue

    if ($commandExistsAfterInstall) {
        Write-Host "[OK] $checkCommand has been successfully installed."
        return $true
    }
    else {
        Write-Host "[x] Failed to install $checkCommand using $installTool. Please install it manually."
        return $false
    }
    
}

$null = Ensure-Tool "choco" "winget" "chocolatey"
$null = Ensure-Tool "nvim" "choco" "neovim"
$null = Ensure-Tool "fzf" "choco" "fzf"
$null = Ensure-Tool "axel" "choco" "axel"
$null = Ensure-Tool "node" "choco" "nodejs"
$null = Ensure-Tool "pwsh" "winget" "MicrosoftPowershell"
$null = Ensure-Tool "lua" "winget" "DEVCOM.Lua"
$null = Ensure-Tool "rg" "winget" "BurntSushi.ripgrep.MSVC"
$null = Ensure-Tool "lf" "winget" "gokcehan.lf"
$null = Ensure-Tool "bat" "winget" "sharkdp.bat"
$null = Ensure-Tool "ctags" "choco" "universal-ctags"

if (Ensure-Tool "python" "choco" "python") {
    $null = Ensure-Tool "ipython" "pip" "ipython"
    $null = Ensure-Tool "autopep8" "pip" "autopep8"
    $null = Ensure-Tool "black" "pip" "black"
    $null = Ensure-Tool "isort" "pip" "isort"
    $null = Ensure-Tool "autoflake" "pip" "autoflake"
}

# 在脚本结束时，提示用户按任意键继续
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")