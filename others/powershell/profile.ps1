#! /usr/bin/env bash
# Github: https://github.com/Karmenzind/dotfiles-and-scripts

$psVersion = $PSVersionTable.PSVersion.Major

if ($psVersion -lt 7) {
    Write-Warning "You are using powershell $psVersion"
}

$condaRoot = "$HOME\miniconda3"
if (Test-Path $condaRoot) {
    # __setupConda 
    Import-Module $condaRoot\shell\condabin\conda-hook.ps1
    # Set-Alias -Name conda -Value $HOME\miniconda3\condabin\conda.bat
}

function __installMyModules {
    Install-Module -Name z –Force
    Install-Module -Name Terminal-Icons -Repository PSGallery
    Install-Module PSReadline
    # Install-Module Terminal-Icons
    Install-Module PsFZF
}

function __loadModule {
    param ([string] $Name)
    $m = (Get-Module $Name)
    if ($null -eq $m) {
        Write-Warning "$Name not found. Run __installMyModules first."
        return
    }
    Import-Module $m
}

# __loadModule -Name Terminal-Icons

Set-Alias ll ls
Set-Alias grep findstr
if ($IsLinux) {
    Set-Alias ls dir
}

# PsReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadlineOption -BellStyle None
Set-PSReadLineOption -EditMode Emacs

if (Get-Command rg -ErrorAction SilentlyContinue) {
    $env:RIPGREP_CONFIG_PATH = "$HOME\.config\ripgreprc"
}

# function which ($command) {
#     Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
# }

Set-Alias which where.exe

function __setupOhmyposh {
    if (-Not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Warning "Oh-My-Posh not installed."
        return
    }
    $env:POSH_THEMES_PATH = ($IsLinux)? "/usr/share/oh-my-posh/themes/": "$HOME\AppData\Local\Programs\oh-my-posh\themes\"
    $randomTheme = Get-ChildItem $env:POSH_THEMES_PATH | Get-Random
    if ( $null -eq $randomTheme) {
        Write-Warning "Failed to get posh theme."
        oh-my-posh init pwsh | Invoke-Expression
    } else {
        Write-Host ">> Posh theme: $(Split-Path $randomTheme -Leaf)"
        oh-my-posh init pwsh --config "$randomTheme" | Invoke-Expression
    }
    Write-Debug ">> Loaded ohmyposh"
}

function Test-Administrator {
    if ($IsWindows) {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } else {
        $(whoami) -eq 'root'
    }
}
$isRunningAsAdmin = Test-Administrator

function __setupFzf{
    if (Get-Command 'fzf' -ErrorAction SilentlyContinue) {
        $psVersion = $PSVersionTable.PSVersion.Major
        if ($psVersion -ge 7) {
            if (Get-Module -ListAvailable -Name PsFZF ) {
                __loadModule PSReadline
                Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
                # Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
            } elseif ($isRunningAsAdmin) {
                Write-Host "PsFZF not found. Install command: 'Install-Module -Name PSFzf'"
            }
        } else {
            Write-Host "(PsFZF is Ignored.)"
        }
        if (Get-Command fd -ErrorAction SilentlyContinue) {
            $env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        }

        $bat = ($IsWindows)? 'bat.exe': 'bat'
        $env:FZF_DEFAULT_OPTS="--preview '$bat -r:10 {}' --inline-info --height 50% --reverse --border --preview-window=right:40%:hidden --bind 'ctrl-/:toggle-preview'"
        # $env:FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
        # $env:FZF_CTRL_R_OPTS = "--preview 'bat.exe -r:10 {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
        $env:FZF_CTRL_R_OPTS = "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind 'ctrl-/:toggle-preview'"
        $env:FZF_COMPLETION_OPTS = '--border --info=inline'
        # if ($isRunningAsAdmin) {
        #     [System.Environment]::SetEnvironmentVariable("FZF_COMPLETION_OPTS", "--border --info=inline", "Machine")
        # }
        Write-Debug ">> Configured PsFZF"
    }
}

# Import the Chocolatey Profile that contains the necessary code to enable tab-completions to function for `choco`.
# $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# if (Test-Path($ChocolateyProfile)) {
#     __loadModule "$ChocolateyProfile"
# }

function __setupProxy {
    $env:HTTP_PROXY="http://0.0.0.0:12345"
    Write-Host "Set proxy: $env:HTTP_PROXY"

    # [system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy('http://0.0.0.0:12345')
    # # If you need to import proxy settings from Internet Explorer, you can replace the previous line with the: "netsh winhttp import proxy source=ie"
    # [system.net.webrequest]::DefaultWebProxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    # # You can request user credentials:
    # # System.Net.WebRequest]::DefaultWebProxy.Credentials = Get-Credential
    # # Also, you can get the user password from a saved XML file (see the article “Using saved credentials in PowerShell scripts”):
    # # System.Net.WebRequest]::DefaultWebProxy= Import-Clixml -Path C:\PS\user_creds.xml
    # [system.net.webrequest]::DefaultWebProxy.BypassProxyOnLocal = $true

    # Invoke-Expression (&starship init powershell)
    # pwsh -ExecutionPolicy Bypass -NoLogo -NoProfile -NoExit -Command "Invoke-Expression 'Import-Module ''%ConEmuDir%\..\profile.ps1''; Import-Module ''C:\Users\qike\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'''"
}

__setupOhmyposh
__setupFzf
# Invoke-Expression (&starship init powershell)

Remove-Variable -Name "psVersion"
Remove-Variable -Name "isRunningAsAdmin"

Write-Host "[:)] Loaded profile: $PROFILE"
