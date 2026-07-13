Option Explicit

Dim arguments, shell, fileSystem, pwshPath, command, index, exitCode
Set arguments = WScript.Arguments

If arguments.Count < 1 Then
    WScript.Quit 2
End If

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")
pwshPath = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%\Microsoft\WindowsApps\pwsh.exe")

If Not fileSystem.FileExists(pwshPath) Then
    pwshPath = "pwsh.exe"
End If

command = Quote(pwshPath) & " -NoProfile -ExecutionPolicy Bypass -File " & Quote(arguments(0))
For index = 1 To arguments.Count - 1
    command = command & " " & Quote(arguments(index))
Next

exitCode = shell.Run(command, 0, True)
WScript.Quit exitCode

Function Quote(value)
    Quote = Chr(34) & value & Chr(34)
End Function

