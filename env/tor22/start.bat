@echo off

set wind_host_type=x86-win32
set wind_base=c:\tornado2.2
set path=%wind_base%\host\%wind_host_type%\bin;%path%

set diablib=%wind_base%\host\diab
set path=%diablib%\win32\bin;%path%
