@echo off

setlocal
set drives=h m r
for %d in (%drives%) if exist "\\vmware-host\Shared Folders\%d%" net use %d%: "\\vmware-host\Shared Folders\%d%" /persistent:yes
