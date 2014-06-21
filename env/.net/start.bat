@echo off

if "%1" == "2"   goto dotnet2
if "%1" == "3.5" goto dotnet35
if "%1" == "4"   goto dotnet4
if "%1" == ""    goto dotnet4
goto err

:dotnet2
set dotnet_ver=v2.0.50727
goto setup

:dotnet35
set dotnet_ver=v3.5
goto setup

:dotnet4
set dotnet_ver=v4.0.30319
goto setup

:err
echo Invalid .NET version
exit /b 1

:setup
title .NET %dotnet_ver%

set FrameworkDir=%windir%\Microsoft.NET\Framework\
set FrameworkDir=%windir%\Microsoft.NET\Framework\
set FrameworkDIR32=%windir%\Microsoft.NET\Framework\

set dotnet_dir=%FrameworkDir%\%dotnet_ver%

set path=%dotnet_dir%;%path%
