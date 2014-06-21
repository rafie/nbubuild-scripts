@echo off

if "%1" == "-h" goto help
if "%1" == "help" goto help

if "%1" == "old" goto old
if "%1" == "classic" goto classic
if "%1" == "others" goto others

cleartool mount -persistent \adapters
cleartool mount -persistent \boardInfra
cleartool mount -persistent \bspLinux8548
cleartool mount -persistent \bspLinuxIntel
cleartool mount -persistent \bspLinuxARM
cleartool mount -persistent \configInfra
cleartool mount -persistent \dialingInfo
cleartool mount -persistent \dspApps
cleartool mount -persistent \dspIcsVideo
cleartool mount -persistent \dspInfra
cleartool mount -persistent \dspIntelInfra
cleartool mount -persistent \dspNetraAudio
cleartool mount -persistent \dspNetraInfra
cleartool mount -persistent \dspNetraVideo
cleartool mount -persistent \dspUCGW
cleartool mount -persistent \dspTools
cleartool mount -persistent \freemasonBuild
cleartool mount -persistent \loggerInfra
cleartool mount -persistent \map
cleartool mount -persistent \mcu
cleartool mount -persistent \mediaCtrlInfo
cleartool mount -persistent \mf
cleartool mount -persistent \mpc
cleartool mount -persistent \mpInfra
cleartool mount -persistent \mpDsp
cleartool mount -persistent \mvp
cleartool mount -persistent \nbu.contrib
cleartool mount -persistent \nbu.dsp
cleartool mount -persistent \nbu.infra
cleartool mount -persistent \nbu.media
cleartool mount -persistent \nbu.meta
cleartool mount -persistent \nbu.prod.mcu
cleartool mount -persistent \nbu.proto.jingle-stack
cleartool mount -persistent \nbu.tests
cleartool mount -persistent \nbu.tools
cleartool mount -persistent \NBU_COMMON_CORE
cleartool mount -persistent \NBU_FEC
cleartool mount -persistent \NBU_H323_STACK
cleartool mount -persistent \NBU_ICE
cleartool mount -persistent \NBU_RTP_RTCP_STACK
cleartool mount -persistent \NBU_SIP_STACK
cleartool mount -persistent \NetraVideoCODEC
cleartool mount -persistent \rvfc
cleartool mount -persistent \securityApp
cleartool mount -persistent \securityInfra
cleartool mount -persistent \swInfra
cleartool mount -persistent \swAudioCodecs
cleartool mount -persistent \swVideoCodecs
cleartool mount -persistent \users
cleartool mount -persistent \web

cleartool mount -persistent \TBU_PVOB_2

exit /b

: -----------------------------------------------------------------------------
:classic

cleartool mount -persistent \audioMsgUtilily
cleartool mount -persistent \bsp8144
cleartool mount -persistent \bsp8548
cleartool mount -persistent \bsp755
cleartool mount -persistent \dpm
cleartool mount -persistent \dsp
cleartool mount -persistent \dsp8144Audio
cleartool mount -persistent \dsp8144Video
cleartool mount -persistent \dspC64Audio
cleartool mount -persistent \dspC64Video
cleartool mount -persistent \megacoOld
cleartool mount -persistent \NBU_SCCP_STACK
cleartool mount -persistent \upgradeUtility

exit /b

: -----------------------------------------------------------------------------
:others

cleartool mount -persistent \ecs
cleartool mount -persistent \gw
cleartool mount -persistent \gw323

exit /b

: -----------------------------------------------------------------------------
:old

cleartool mount -persistent \AudioMessageUtility
cleartool mount -persistent \DPM
cleartool mount -persistent \DSP_NG
cleartool mount -persistent \MPCsys
cleartool mount -persistent \NBU_BOARD_INFRA
cleartool mount -persistent \NBU_BUILD
cleartool mount -persistent \NBU_Config
cleartool mount -persistent \NBU_MEDIA_CTRL_INFRA
cleartool mount -persistent \NBU_Megaco
cleartool mount -persistent \NBU_SW_INFRA
cleartool mount -persistent \NMS_New
cleartool mount -persistent \pomp
cleartool mount -persistent \RV755_BSP
cleartool mount -persistent \RVLOGGER
cleartool mount -persistent \SECURITY
cleartool mount -persistent \TAMAR_BSP

exit /b

: -----------------------------------------------------------------------------
:help

echo mount-nbu-vobs [classic ^| others ^| old]
echo.
echo (none):  mount all contemporary VOBs
echo classic: mount VOBs specific to MCU Classis
echo old:     mount really old VOBs
echo others:  mount VOBs of products like gw and ecs
exit /b
