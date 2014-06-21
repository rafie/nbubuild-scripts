
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\NBU Environment.lnk")
$Shortcut.TargetPath = "c:\root\scripts\nbu-guest.bat"
$Shortcut.Save()
