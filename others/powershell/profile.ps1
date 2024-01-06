function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$isRunningAsAdmin = Test-Administrator

if (Get-Command 'fzf') {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion.Major -ge 7) {
        if (Get-Module -ListAvailable -Name PsFZF ) {
            Write-Host "Found Psfzf. Configuring..."
            # replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
            Import-Module PSReadline
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
            # Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
        }
        elseif ($isRunningAsAdmin) {
            Write-Host "PsFZF not found. Install command: 'Install-Module -Name PSFzf'"
        }
    } else {
        Write-Host "(PsFZF is Ignored.)"
    }
    if (Get-Command rg -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    }
    # $env:FZF_DEFAULT_OPTS="--preview 'bat.exe -r:10 {}' --inline-info --height 50% --reverse --border=horizontal --preview-window=right:40% --color fg:yellow,fg+:bright-yellow"
    $env:FZF_DEFAULT_OPTS="--preview 'bat.exe -r:10 {}' --inline-info --height 50% --reverse --border --preview-window=right:40%:hidden --bind 'ctrl-/:toggle-preview'"
    # $env:FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    # $env:FZF_CTRL_R_OPTS = "--preview 'bat.exe -r:10 {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    $env:FZF_CTRL_R_OPTS = "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind 'ctrl-/:toggle-preview'"
    $env:FZF_COMPLETION_OPTS = '--border --info=inline'

    if ($isRunningAsAdmin) {
        [System.Environment]::SetEnvironmentVariable("FZF_COMPLETION_OPTS", "--border --info=inline", "Machine")
    }

}

# $env:HTTP_PROXY="http://0.0.0.0:12345"
# Write-Host "Set proxy: $env:HTTP_PROXY"

# [system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy('http://0.0.0.0:12345')
# # If you need to import proxy settings from Internet Explorer, you can replace the previous line with the: "netsh winhttp import proxy source=ie"
# [system.net.webrequest]::DefaultWebProxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
# # You can request user credentials:
# # System.Net.WebRequest]::DefaultWebProxy.Credentials = Get-Credential
# # Also, you can get the user password from a saved XML file (see the article “Using saved credentials in PowerShell scripts”):
# # System.Net.WebRequest]::DefaultWebProxy= Import-Clixml -Path C:\PS\user_creds.xml
# [system.net.webrequest]::DefaultWebProxy.BypassProxyOnLocal = $true

# Import the Chocolatey Profile that contains the necessary code to enable tab-completions to function for `choco`.
# $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# if (Test-Path($ChocolateyProfile)) {
#     Import-Module "$ChocolateyProfile"
# }

# Invoke-Expression (&starship init powershell)
# pwsh -ExecutionPolicy Bypass -NoLogo -NoProfile -NoExit -Command "Invoke-Expression 'Import-Module ''%ConEmuDir%\..\profile.ps1''; Import-Module ''C:\Users\qike\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'''"

Remove-Variable -Name 'isRunningAsAdmin'
Write-Host "[:)] Loaded profile: $PROFILE"
