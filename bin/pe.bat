@echo off

setlocal
if defined ProgramFiles(x86) (
	set ProcessExplorer_path=R:\Mcu_Ngp\Utilities\ProcessExplorer\latest
) else (
	set ProcessExplorer_path=R:\Mcu_Ngp\Utilities\ProcessExplorer\11.33
)
start %ProcessExplorer_path%\procexp.exe
