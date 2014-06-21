@echo off

set OPENSSL_VER=0.9.8q
if not "%1"=="" set OPENSSL_VER=%1

title OpenSSL %OPENSSL_VER%

set OPENSSL_PATH=%NBU_BUILD_ROOT%\dev\libs\open-ssl\win32\%OPENSSL_VER%
set OPENSSL_BIN_PATH=%OPENSSL_PATH%\bin
set OPENSSL_CONF=%OPENSSL_BIN_PATH%\openssl.cfg

set PATH=%OPENSSL_BIN_PATH%;%PATH%
