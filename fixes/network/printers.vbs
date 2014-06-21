Set WshNetwork = CreateObject("WScript.Network") 
 
WshNetwork.AddWindowsPrinterConnection "\\rvil-printers\Copy Machine- Floor 7" 
WshNetwork.AddWindowsPrinterConnection "\\rvil-printers\Copy Machine Floor 8" 
WshNetwork.AddWindowsPrinterConnection "\\rvil-printers\Copy Machine1 Floor9" 
WshNetwork.SetDefaultPrinter "\\rvil-printers\Copy Machine Floor 8"
