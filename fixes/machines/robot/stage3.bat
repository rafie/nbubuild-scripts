@echo off

setlocal
if not exist r:\ net use r: \\storage.RADVISION.com\NBU

net session >nul 2>&1
if %errorLevel% == 0 (
	call stage3a.bat
) else (
	elevate -k stage2a.bat
)
