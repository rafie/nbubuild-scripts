@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Scaffolds::System;

my $version = "1.4.4";

my $root = $ENV{NBU_BUILD_ROOT};
my $installer_dir = "$root/pkg/dev/clearcase/installation-manager/windows/$version/x86";

print "Installing IBM Install Manager $version ...\n";
chdir("$installer_dir");
systema("installc --launcher.ini silent-install.ini -configuration \@user.home/.eclipse -acceptLicense")->ordie("Installation failed.");
print "OK.\n";
exit(0);
