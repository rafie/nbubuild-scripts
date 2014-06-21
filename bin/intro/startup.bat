@echo off

: --- setup

net use r: \\Storage\NBU /user:RADVISION\nbubuild Mason1
path r:\build\sys\scripts\bin;%PATH%
call set-nbu-build-env.bat

: --- your code here

: --- tear down
net use r: /d

