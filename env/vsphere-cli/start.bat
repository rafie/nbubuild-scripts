@echo off

set VSPHERE_CLI_DIR=D:\sys\vm\vsphere-cli\5.5
set PERL5LIB=%VSPHERE_CLI_DIR%\Perl\lib;%VSPHERE_CLI_DIR%\Perl\site\lib

set VSPHERE_CLI_PATH=%VSPHERE_CLI_DIR%\Perl\site\bin;%VSPHERE_CLI_DIR%\Perl\bin

set path=%VSPHERE_CLI_PATH%;%path%
