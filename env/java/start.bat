@echo off

if "%1" == "3" goto jdk3
if "%1" == "4" goto jdk4
if "%1" == "5" goto jdk5
if "%1" == "6" goto jdk6
if "%1" == ""  goto jdk6
goto err

:jdk3
set jdk_ver=1.3.1_17
goto jdk

:jdk4
set jdk_ver=1.4.2_10
goto jdk

:jdk5
set jdk_ver=1.5.0_08
goto jdk

:jdk6
set jdk_ver=1.6.0_26
goto jdk

:err
echo Invalid JDK version
exit /b 1

:jdk
title JDK %jdk_ver%
set JAVA_HOME=%NBU_BUILD_ROOT%\dev\java\jdk\%jdk_ver%

set path=%JAVA_HOME%\bin;%path%
