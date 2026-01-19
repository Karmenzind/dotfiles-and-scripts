#! /usr/bin/env bash
# Github: https://github.com/Karmenzind/dotfiles-and-scripts

$psVersion = $PSVersionTable.PSVersion.Major

if ($psVersion -lt 7) {
    Write-Warning "You are using powershell $psVersion"
}

$env:EDITOR = "nvim.exe"

# -----------------------------------------------------------------------------
function Invoke-ActiveEnvs {
    # 1. Python (.venv) - 检查目录是否存在
    if (Test-Path ".venv\Scripts\Activate.ps1") {
        Write-Host "🐍 Activating Python .venv ..." -ForegroundColor Cyan
        & ".\.venv\Scripts\Activate.ps1"
    }

    # 2. SDKMAN (针对 Windows 的提示)
    if (Test-Path ".sdkmanrc") {
        Write-Host "☕ .sdkmanrc detected." -ForegroundColor Yellow
    }

    # 3. NVM (Node.js)
    if (Test-Path ".nvmrc") {
        $nodeVersion = (Get-Content ".nvmrc" -Raw).Trim()
        Write-Host "🟢 .nvmrc detected ($nodeVersion)..." -ForegroundColor Green
        nvm use $nodeVersion
    }

    # 4. Ruby (rbenv)
    if (Test-Path ".ruby-version") {
        $rubyVersion = (Get-Content ".ruby-version" -Raw).Trim()
        Write-Host "💎 .ruby-version detected ($rubyVersion) ..." -ForegroundColor Magenta
        if (Get-Command "rbenv" -ErrorAction SilentlyContinue) {
            rbenv shell $rubyVersion
        }
    }
}

function Set-Location-With-Env {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $PathArgs
    )
    
    # 将参数数组合并为一个字符串（处理空格路径）
    $ActualPath = if ($PathArgs) { $PathArgs -join " " } else { $Home }

    # 执行跳转
    # 使用 Try/Catch 捕获路径不存在的情况，防止死循环或报错
    try {
        Microsoft.PowerShell.Management\Set-Location -Path $ActualPath
    } catch {
        Write-Error $_
        return
    }
    
    # 触发环境检测
    Invoke-ActiveEnvs
}

# 重新绑定别名
if (Get-Alias -Name cd -ErrorAction SilentlyContinue) { 
    Remove-Item Alias:cd -Force 
}
Set-Alias cd Set-Location-With-Env -Option AllScope

# 启动执行一次
Invoke-ActiveEnvs
# -----------------------------------------------------------------------------

if ($IsWindows) {
    $env:PROJECT_PATHS = "~/Workspace;~/Localworks"
} else {
    $env:PROJECT_PATHS = "$HOME\Workspace"
}
# $DebugPreference = "Continue"

function Check-PJRootNotSet {
    ($env:PROJECT_PATHS -eq "") -or ($null -eq $env:PROJECT_PATHS)
}

Class ProjectNames : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $counter = @{}
        if (Check-PJRootNotSet){
            Write-Warning "env:PROJECT_PATHS is not set"
            return @()
        }
        $roots = $env:PROJECT_PATHS -split ';'
        $projects = ForEach ($parent in $roots) {
            If (Test-Path $parent) {
                foreach ( $Item in (Get-ChildItem $parent ) ) {
                    if (Test-Path -PathType Container $Item) {
                        $Leaf = Split-Path $Item -Leaf
                        $counter[$Leaf] += 1
                        [PsCustomObject]@{ Leaf = $Leaf; Parent = $parent }
                    }
                }
            }
        }
        if ($projects.Length -eq 0) {
            Write-Warning "No projects under $env:PROJECT_PATHS"
            return @()
        }

        $projects = $projects | Sort-Object {$_.Leaf}

        $assigned = @{}
        $Names = [string[]] @()
        for ($i = 0; $i -lt $projects.Length; $i++) {
            $p = $projects[$i]
            if ($counter[$p.Leaf] -eq 1) {
                $Names += $p.Leaf
            } else {
                $assigned[$p.Leaf] += 1
                $Names += "$($p.Leaf) -- $($assigned[$p.Leaf]) $($p.parent)"
            }
        }
        return $Names
    }
}

function Project-Jump {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet([ProjectNames])]
        [string] $Project
    )
    if (Check-PJRootNotSet){
        Write-Warning "env:PROJECT_PATHS is not set"
        return
    }
    $projectPaths = $env:PROJECT_PATHS -split ";"

    [string] $path
    if ($Project -match '(?<Leaf>.+) -- \d (?<Parent>.+)') {
        # FIXME Why empty $Matches ????
        $path = Join-Path $Matches.Parent $Matches.Leaf
    } else {
        ForEach ($parent in $projectPaths) {
            $p = Join-Path $parent $Project
            if (Test-Path $p) {
                Set-Location-With-Env $p
                return
            }
        }
    }
    if ($null -eq $path) {
        Write-Warning "Not found: $Project"
    }

    if (Test-Path $path) {
        Set-Location-With-Env $path
    } else {
        Write-Warning "Invalid path: $path"
    }
}

function Project-JumpOpen() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet([ProjectNames])]
        [string] $Project,
        [string] $Editor
    )
    Project-Jump $Project
    nvim
}

Set-Alias pj Project-Jump
Set-Alias pjo Project-JumpOpen


$condaRoot = "$HOME\miniconda3"
if (Test-Path $condaRoot) {
    # __setupConda
    Import-Module $condaRoot\shell\condabin\conda-hook.ps1
    # Set-Alias -Name conda -Value $HOME\miniconda3\condabin\conda.bat
}

function __installMyModules {
    Install-Module -Name z –Force
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force
    Install-Module PSReadline -Force
    Install-Module PsFZF -Force
    Import-Module PSCompletions
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

Set-Alias ll ls
Set-Alias grep findstr
Set-Alias which where.exe
if ($IsLinux) {
    Set-Alias ls dir
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    $env:RIPGREP_CONFIG_PATH = "$HOME\.config\ripgreprc"
}

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

function __editHistory {
    nvim.exe (Get-PSReadLineOption).HistorySavePath
}


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

function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location-With-Env -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}

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


# Invoke-Expression (&starship init powershell)
# -----------------------------------------------------------------------------
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadlineOption -BellStyle None

Set-PSReadLineOption -EditMode Vi
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete -ViMode Insert

# 4. 绑定 Ctrl+[ 进入 Normal 模式 建议同时绑定 "`e" (Esc 字符) 以确保终端兼容性
Set-PSReadLineKeyHandler -Key "Ctrl+[" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode() } -ViMode Insert
Set-PSReadLineKeyHandler -Key "`e"      -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode() } -ViMode Insert

# 5. 定义 Vi 模式指示器 (修正了参数类型以适配 7.5.4)
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
    param($Mode) # 移除具体类型声明，让其自动推断，避免 [PSReadLineMode] 报错
    switch ($Mode) {
        'Command' {
            $Host.UI.RawUI.CursorSize = 100 
            Write-Host -NoNewline "`e[2 q" 
        }
        'Insert' {
            $Host.UI.RawUI.CursorSize = 25
            Write-Host -NoNewline "`e[6 q" 
        }
    }
}

# --- 在 Vi 插入模式下保留 Emacs 常用快捷键 ---
Set-PSReadLineKeyHandler -Key "Ctrl+a" -Function BeginningOfLine -ViMode Insert
Set-PSReadLineKeyHandler -Key "Ctrl+e" -Function EndOfLine -ViMode Insert
Set-PSReadLineKeyHandler -Key "Ctrl+b" -Function BackwardChar -ViMode Insert
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardChar -ViMode Insert
Set-PSReadLineKeyHandler -Key "Ctrl+k" -Function ForwardDeleteLine -ViMode Insert
Set-PSReadLineKeyHandler -Key "Ctrl+u" -Function BackwardDeleteLine -ViMode Insert
Set-PSReadLineKeyHandler -Key "Ctrl+w" -Function BackwardKillWord -ViMode Insert

Set-PSReadLineKeyHandler -Key Escape -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
} -ViMode Insert

# -----------------------------------------------------------------------------

Import-Module Terminal-Icons
Import-Module PSCompletions

function __setupPsc {
    psc add choco python jq wsl uv winget git nvm oh-my-posh node pnpm 7z
    psc config language en-US
}


__setupOhmyposh
__setupFzf


Remove-Variable -Name "psVersion"
Remove-Variable -Name "isRunningAsAdmin"

Write-Host "[:)] Loaded profile: $PROFILE"
