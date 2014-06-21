@echo off

setlocal

set _f=%tmp%\flexlm-users.dat
set lmutil="R:\Mcu_Ngp\Utilities\FlexLM\lmutil.exe"

set groups=WR_COMPILER_PPC FL_SE_PXX_VE_Cfg41 WR_WORKBENCH DIAB_PPC tornado2 FL_P_T22_STD_Cfg1

: FL_SE_LX_ENT_AD_Cfg39 FL_SE_LX_ENT_PD_Cfg38
: set groups=WR_COMPILER_PPC FL_SE_PNE_VE_Cfg30 WR_WORKBENCH FL_SE_PD_GPP_LE_Cfg26 DIAB_PPC tornado2 FL_P_T22_STD_Cfg1
: set groups=FL_SE_AD_GPP_LE_Cfg27 WR_CONNECTION_TS WR_CONNECTION_UA WR_DEBUGGER WR_DEBUG_ALL WR_TOS_LX_2 WR_TOS_VX_6
: UU_SE_PNE_VE_Cfg30    licenses=2  users=PNE_BSP_USERS  resources=WR_COMPILER_PPC WR_WORKBENCH
: FL_SE_PNE_VE_Cfg30    licenses=9  users=PNE_USERS      resources=WR_COMPILER_PPC WR_WORKBENCH
: FL_SE_PD_GPP_LE_Cfg26 licenses=2  users=?              resources=WR_WORKBENCH

: set groups=WR_COMPILER_PPC FL_SE_PNE_VE_Cfg28 UU_SE_PNE_VE_Cfg28 WR_WORKBENCH FL_SE_PD_GPP_LE_Cfg26 DIAB_PPC tornado2 FL_P_T22_STD_Cfg1
: UU_SE_PNE_VE_Cfg28    licenses=2  users=PNE_BSP_USERS  resources=WR_COMPILER_PPC WR_WORKBENCH
: FL_SE_PNE_VE_Cfg28    licenses=5  users=?              resources=WR_COMPILER_PPC WR_WORKBENCH
: FL_SE_PD_GPP_LE_Cfg26 licenses=2  users=?              resources=WR_WORKBENCH

if "%1" == "-a" goto all

(for %%f in (%groups%) do %lmutil% lmstat -c 27000@bsp_server -f %%f) > %_f%
type %_f% | grep -v "lmutil - Copyright" | grep -v "Flexible License Manager" | grep -v "Detecting lmgrd processes" | grep -v "vendor: wrsd" | grep -v "floating license"
exit /b

:all
%lmutil% lmstat -c 27000@bsp_server -a > %_f%
type %_f% | grep -v "lmutil - Copyright" | grep -v "Flexible License Manager" | grep -v "Detecting lmgrd processes" | grep -v "vendor: wrsd" | grep -v "floating license"
exit /b
