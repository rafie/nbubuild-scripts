@echo off

arp -a > %tmp%\arp
arp -d
ipconfig /displaydns > %tmp%\dnscache
ipconfig /flushdns
net stop dnscache
net start dnscache
