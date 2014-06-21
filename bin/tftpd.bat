@echo off

setlocal
if not exist c:\tftp md c:\tftp
start R:\Mcu_Ngp\Utilities\tftpd\tftpd64.exe
