@echo off

net use r: /d
net use n: /d
net use y: /d

net use r: \\storage\NBU /persistent:yes
net use n: \\storage\Software /persistent:yess
net use y: \\vbu\legacy /persistent:yes
