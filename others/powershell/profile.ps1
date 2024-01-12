
function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$isRunningAsAdmin = Test-Administrator

Import-Module -Name Terminal-Icons
Write-Host ">> Loaded Terminal-Icons"

Set-Alias ll ls
Set-Alias grep findstr

function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

if (Get-Command oh-my-posh) {
    $myThemes = @(
        "1_shell.omp.json",
        "agnoster.minimal.omp.json",
        "agnoster.omp.json",
        "agnosterplus.omp.json",
        "aliens.omp.json",
        "amro.omp.json",
        "atomic.omp.json",
        "atomicBit.omp.json",
        "avit.omp.json",
        "blue-owl.omp.json",
        "blueish.omp.json",
        "bubbles.omp.json",
        "bubblesextra.omp.json",
        "bubblesline.omp.json",
        "capr4n.omp.json",
        "catppuccin_frappe.omp.json",
        "catppuccin_latte.omp.json",
        "catppuccin_macchiato.omp.json",
        "catppuccin_mocha.omp.json",
        "catppuccin.omp.json",
        "cert.omp.json",
        "chips.omp.json",
        "cinnamon.omp.json",
        "clean-detailed.omp.json",
        "cloud-context.omp.json",
        "cloud-native-azure.omp.json",
        "cobalt2.omp.json",
        "craver.omp.json",
        "darkblood.omp.json",
        "devious-diamonds.omp.yaml",
        "di4am0nd.omp.json",
        "dracula.omp.json",
        "easy-term.omp.json",
        "emodipt-extend.omp.json",
        "emodipt.omp.json",
        "fish.omp.json",
        "free-ukraine.omp.json",
        "froczh.omp.json",
        "glowsticks.omp.yaml",
        "gmay.omp.json",
        "grandpa-style.omp.json",
        "gruvbox.omp.json",
        "half-life.omp.json",
        "honukai.omp.json",
        "hotstick.minimal.omp.json",
        "hul10.omp.json",
        "hunk.omp.json",
        "huvix.omp.json",
        "if_tea.omp.json",
        "illusi0n.omp.json",
        "iterm2.omp.json",
        "jandedobbeleer.omp.json",
        "jblab_2021.omp.json",
        "jonnychipz.omp.json",
        "json.omp.json",
        "jtracey93.omp.json",
        "jv_sitecorian.omp.json",
        "kali.omp.json",
        "kushal.omp.json",
        "lambda.omp.json",
        "lambdageneration.omp.json",
        "larserikfinholt.omp.json",
        "lightgreen.omp.json",
        "M365Princess.omp.json",
        "marcduiker.omp.json",
        "markbull.omp.json",
        "material.omp.json",
        "microverse-power.omp.json",
        "mojada.omp.json",
        "montys.omp.json",
        "mt.omp.json",
        "multiverse-neon.omp.json",
        "negligible.omp.json",
        "neko.omp.json",
        "night-owl.omp.json",
        "nordtron.omp.json",
        "nu4a.omp.json",
        "onehalf.minimal.omp.json",
        "paradox.omp.json",
        "pararussel.omp.json",
        "patriksvensson.omp.json",
        "peru.omp.json",
        "pixelrobots.omp.json",
        "plague.omp.json",
        "poshmon.omp.json",
        "powerlevel10k_classic.omp.json",
        "powerlevel10k_lean.omp.json",
        "powerlevel10k_modern.omp.json",
        "powerlevel10k_rainbow.omp.json",
        "powerline.omp.json",
        "probua.minimal.omp.json",
        "pure.omp.json",
        "quick-term.omp.json",
        "remk.omp.json",
        "robbyrussell.omp.json",
        "rudolfs-dark.omp.json",
        "rudolfs-light.omp.json",
        "schema.json",
        "sim-web.omp.json",
        "slim.omp.json",
        "slimfat.omp.json",
        "smoothie.omp.json",
        "sonicboom_dark.omp.json",
        "sonicboom_light.omp.json",
        "sorin.omp.json",
        "space.omp.json",
        "spaceship.omp.json",
        "star.omp.json",
        "stelbent-compact.minimal.omp.json",
        "stelbent.minimal.omp.json",
        "takuya.omp.json",
        "the-unnamed.omp.json",
        "thecyberden.omp.json",
        "tiwahu.omp.json",
        "tokyo.omp.json",
        "tokyonight_storm.omp.json",
        "tonybaloney.omp.json",
        "uew.omp.json",
        "unicorn.omp.json",
        "velvet.omp.json",
        "wholespace.omp.json",
        "wopian.omp.json",
        "xtoys.omp.json",
        "ys.omp.json",
        "zash.omp.json"
    )
    $randomTheme = $myThemes | Get-Random
    Write-Host "Posh theme: $randomTheme"
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$randomTheme" | Invoke-Expression
    Write-Host ">> Loaded ohmyposh"
    Remove-Variable randomTheme
    Remove-Variable myThemes
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadlineOption -BellStyle None
Set-PSReadLineOption -EditMode Emacs

if (Get-Command rg -ErrorAction SilentlyContinue) {
    $env:RIPGREP_CONFIG_PATH = '~\.config\ripgreprc'
}

if (Get-Command 'fzf') {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -ge 7) {
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
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    }
    # $env:FZF_DEFAULT_OPTS="--preview 'bat.exe -r:10 {}' --inline-info --height 50% --reverse --border=horizontal --preview-window=right:40% --color fg:yellow,fg+:bright-yellow"
    $env:FZF_DEFAULT_OPTS="--preview 'bat.exe -r:10 {}' --inline-info --height 50% --reverse --border --preview-window=right:40%:hidden --bind 'ctrl-/:toggle-preview'"
    # $env:FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    # $env:FZF_CTRL_R_OPTS = "--preview 'bat.exe -r:10 {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    $env:FZF_CTRL_R_OPTS = "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind 'ctrl-/:toggle-preview'"
    $env:FZF_COMPLETION_OPTS = '--border --info=inline'
    # if ($isRunningAsAdmin) {
    #     [System.Environment]::SetEnvironmentVariable("FZF_COMPLETION_OPTS", "--border --info=inline", "Machine")
    # }
    Remove-Variable -Name 'psVersion'
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
