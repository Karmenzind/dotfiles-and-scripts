$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$tokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile(
    (Join-Path $repoRoot "install.ps1"), [ref]$tokens, [ref]$parseErrors
)
if ($parseErrors.Count) {
    throw ($parseErrors | Out-String)
}

function Import-InstallerFunction {
    param([string]$Name)
    $definition = $ast.Find({
        param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $Name
    }.GetNewClosure(), $true)
    if (-not $definition) { throw "Missing function: $Name" }
    # Install the definition in this test's script scope without invoking the entrypoint.
    Set-Item -Path "function:script:$Name" -Value $definition.Body.GetScriptBlock()
}

Import-InstallerFunction Install-AiClis
$script:captured = @()
function Invoke-LoggedCommand {
    param($FilePath, $ArgumentList, $Label)
    $script:captured += @{ FilePath = $FilePath; Arguments = $ArgumentList }
}
Install-AiClis
if ($captured.Count -ne 3) { throw "Expected three official AI installers" }

$expectedUris = @(
    "https://chatgpt.com/codex/install.ps1",
    "https://cursor.com/install?win32=true",
    "https://claude.ai/install.ps1"
)
$fixturePrefix = @'
function Invoke-RestMethod {
    param([string]$Uri)
    '[Console]::WriteLine(''fixture:' + $Uri + ':' + $env:CODEX_NON_INTERACTIVE + '''); exit 0'
}
'@

Import-InstallerFunction Invoke-LoggedCommand
function Write-Install { param($Message) }
$previous = $env:CODEX_NON_INTERACTIVE
try {
    $env:CODEX_NON_INTERACTIVE = "fixture-parent"
    for ($index = 0; $index -lt $captured.Count; $index++) {
        $call = $captured[$index]
        $arguments = @($call.Arguments)
        if ($call.FilePath -ne "powershell.exe" -or
            ($arguments[0..3] -join " ") -ne "-NoProfile -ExecutionPolicy Bypass -Command" -or
            -not $arguments[-1].Contains($expectedUris[$index])) {
            throw "Unexpected installer command at index $index"
        }
        # Replace only the downloader with a fixture; execute the actual child shell.
        $arguments[-1] = $fixturePrefix + "`n" + $arguments[-1]
        $output = Invoke-LoggedCommand -FilePath $call.FilePath -ArgumentList $arguments -Label "Fixture"
        $expectedEnv = if ($index -eq 0) { "1" } else { "fixture-parent" }
        if ($output -ne "fixture:$($expectedUris[$index]):$expectedEnv") {
            throw "Child invocation or installer exit isolation failed: $output"
        }
        if ($env:CODEX_NON_INTERACTIVE -ne "fixture-parent") {
            throw "Installer environment leaked into the parent"
        }
    }
    $failedAsExpected = $false
    try {
        Invoke-LoggedCommand -FilePath "powershell.exe" -ArgumentList @(
            "-NoProfile", "-Command", "exit 7"
        ) -Label "Expected fixture failure"
    } catch {
        if ($_.Exception.Message -notlike "*exit code 7*") { throw }
        $failedAsExpected = $true
    }
    if (-not $failedAsExpected) { throw "Child failure was ignored" }
} finally {
    $env:CODEX_NON_INTERACTIVE = $previous
}

$packagesAssignment = $ast.Find({
    param($node)
    $node -is [Management.Automation.Language.AssignmentStatementAst] -and
    $node.Left.Extent.Text -eq '$script:CommonPackages'
}, $true)
$packages = & ([scriptblock]::Create($packagesAssignment.Right.Extent.Text))
$gui = @($packages | Where-Object Name -eq "Codex GUI app")
if ($gui.Count -ne 1 -or $gui[0].Id -ne "9PLM9XGG6VKS" -or $gui[0].Source -ne "msstore") {
    throw "Codex GUI must stay on the official Store package"
}

Import-InstallerFunction Update-ProcessPath
$previousPath = $env:Path
try {
    $env:Path = "C:\Fixture\active-fnm;$env:Path"
    Update-ProcessPath
    if (-not $env:Path.StartsWith("C:\Fixture\active-fnm;")) {
        throw "Refreshing PATH replaced the active toolchain"
    }
} finally {
    $env:Path = $previousPath
}

Write-Host "PASS: official Windows CLI commands, child exit/env isolation, failure propagation, and GUI source"
