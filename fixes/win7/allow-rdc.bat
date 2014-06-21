@echo off

net localgroup "Remote Desktop Users" "%USERDOMAIN%\Domain Users" /add
