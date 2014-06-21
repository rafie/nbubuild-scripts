@echo off

if "%1"=="-kw" goto kw
r:\Mcu_Ngp\Utilities\PsTools\2.4\psservice.exe \\bsp_server -u RADVISION\%USERNAME% restart "FLEXlm Service 1"
exit /b

:kw
r:\Mcu_Ngp\Utilities\PsTools\2.4\psservice.exe \\rvil-nbu-tools -u RADVISION\%USERNAME% restart "Klocwork 8.0 License Server"
exit /b
