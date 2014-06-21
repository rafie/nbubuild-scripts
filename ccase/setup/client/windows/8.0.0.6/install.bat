@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use File::Copy;
use File::Temp qw(tempdir);

use Scaffolds::System;
use Scaffolds::Util;

my $is_x64 = !! $ENV{"ProgramFiles(x86)"};

my $services = systema("net start");
if ($services->outText =~ /Atria/)
{
	print "ClearCase client already installed.\n";
	exit(0);
}

my $profile = shift;

$profile = $ENV{USERDOMAIN} eq "GLOBAL" ? "avaya" : "radvision" if ! $profile;

my $ccver = "8.0.0.6";
my $imver = "1.6.2";

my $root = $ENV{NBU_BUILD_ROOT};
my $ccase = "$root/sys/scripts/ccase/setup/client/windows/$ccver";
my $inst_mgr = "$root/sys/scripts/ccase/setup/installation-manager/windows/$imver";

my $progs = $ENV{"ProgramFiles(x86)"};
if (! $progs || ! -d $progs)
{
	# this is 32-bit environment
	$progs = $ENV{ProgramFiles};
	die "Error: cannot determine Program Files directory.\n" if ! $progs || ! -d $progs;
}

my $installer_dir = "$progs/IBM/Installation Manager/eclipse";
print "Installing IBM Install Manager $imver ...\n";
systemx("perl $inst_mgr/install.bat") if ! -f "$installer_dir/IBMIMc.exe";
print "OK.\n";

chdir($installer_dir) or die "Error: cannot find Installation Manager.\n";

my $installer="IBMIMc.exe --launcher.ini silent-install.ini -acceptLicense -ShowVerboseProgress";

my $vs_installed = -d $ENV{VS90COMNTOOLS} || -d $ENV{VS100COMNTOOLS} || -d $ENV{VS110COMNTOOLS};
my $resp_name = "clearcase_response_nt_i386_" . ($vs_installed ? "vs" : "no-vs") . ($is_x64 ? "" : "_x86");

print "Installing ClearCase client $ccver..\n";

# checking on old Rational directoty
# this should be moved out of the way as it will break installation
my $olddir = "$progs\\IBM\\RationalSDLC";
if (-d $olddir)
{
	my $tempdir = tempdir("RationalSDLC.XXXXX", DIR => "$olddir\\..");
	rmdir($tempdir);
	move($olddir, $tempdir);
}

systema("$installer -input $ccase/$profile/$resp_name.xml")->ordie("Installation failed.");
print "OK.\n";

# sometimes installer fails to write correct values to registry
my $arch = $is_x64 ? "" : "-x86";
systema("reg import " . u2w("$ccase/$profile/post-fix$arch.reg"));

print "Please reboot your machine.\n";
		
exit(0);
