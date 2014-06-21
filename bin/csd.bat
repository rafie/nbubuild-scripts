@echo off

call cs.bat /d /e %1.cs
call mdbg.bat %1.exe
