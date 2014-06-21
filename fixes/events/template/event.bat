@echo off

setlocal
set op=%1

if "%1" == "" (echo invalid op: '%op%' >> c:\root\cfg\events\log & exit /b 1)

echo %date% %time% %op% >> c:\root\cfg\events\log

: echo op=%op%

if "%EVENTS_LIST%" == "1" goto list
if "%EVENTS_PRINT%" == "1" goto print
for /F %%f in ('dir /b /s /o:n %op%\??-*.bat') do @call %%f
exit /b

:list
for /F %%f in ('dir /b /s /o:n %op%\??-*.bat') do @echo %%f
exit /b

:print
for /F %%f in ('dir /b /s /o:n %op%\??-*.bat') do (@echo. & echo # %%f & echo. & type %%f)
exit /b
