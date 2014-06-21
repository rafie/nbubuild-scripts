@echo off

setlocal
: pushd %NBU_BUILD_ROOT%\pkg\sys\hane-nfsd

net stop "NFS Server"
regedit /s nfsd.reg
xcopy /q /y exports "%ProgramFiles%\nfsd\" > nul
net start "NFS Server"
