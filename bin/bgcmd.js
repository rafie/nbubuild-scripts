var WindowStyle_Hidden = 0
var sh = WScript.CreateObject("WScript.Shell")
var rc = sh.Run("cmd.exe /c " + WScript.Arguments.Item(0), WindowStyle_Hidden)
