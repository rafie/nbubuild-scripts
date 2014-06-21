WshShell = CreateObject("WScript.Shell")
desktop = WshShell.SpecialFolders("Desktop")
lnk = WshShell.CreateShortcut(desktop + "\jojo.lnk")
lnk.WindowStyle = 4
lnk.TargetPath = "c:\root\scripts\nbu-guest.bat"
lnk.Save
