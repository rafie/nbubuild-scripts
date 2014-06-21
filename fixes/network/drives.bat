@echo off

net use n: \\Storage\Software       /persistent:yes < nul
net use r: \\Storage\NBU            /persistent:yes < nul
: net use U: \\bronze\%USERNAME%      /persistent:yes < nul
: net use U: \\rvil-ccav\%USERNAME%   /persistent:yes < nul
net use y: \\vbu\legacy /persistent:yes < nul

if exist r:\%USERNAME% (
	net use h: \\storage\NBU\%USERNAME% /persistent:yes < nul
) else (
	net use h: \\storage\users\%USERNAME% /persistent:yes < nul
)

exit /b 0
