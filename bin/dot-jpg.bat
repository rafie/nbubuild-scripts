@echo off

setlocal
set src=%1.dot
set jpg=%src%.jpg
shift
R:\Mcu_Ngp\Utilities\Graphviz\2.21\bin\dot.exe -Tjpg -O %src% %$
if exist %jpg% start %jpg%
