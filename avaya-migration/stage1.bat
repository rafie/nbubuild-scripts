@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use File::Copy::Recursive qw(dircopy rcopy);

use Scaffolds::System;
use Scaffolds::Util;

log_hello();

my $root = $ENV{NBU_BUILD_ROOT};

query_global_username();

print "\nCopying scripts to local drive...\n";
dircopy("$root/sys/scripts/avaya-migration", "c:/avaya-migration") or die $!;

# uninstall ClearCase 7 client
print "\nUninstalling ClearCase client...\n";
chdir("$root/sys/scripts/ccase/setup/client/windows/7.1.2.3") or die $!;
systemi("uninstall.bat")->ordie("Failed to uninstall ClearCase client.");

# add GLOBAL users to local Administrators group
print "\nAdding GLOBAL user to local Administrators group...\n";
add_global_user_to_local_admins() or die "User is not a local admin and cannot be added to Administrators group. Aborting.\n";
add_local_admins();

# switch to global.avaya.com domain
print "\nSwitching to GLOBAL domain...\n";
chdir("$root/sys/scripts/avaya-migration") or die $!;;
systemi("rv-to-avaya.bat")->ordie("Failed to move to global.avaya.com domain.");

print "\nStage 1 completed successfully.\n";
print "You can reboot now.\n";
print "Please remember to login with your GLOBAL credentials.\n";

exit(0);

sub query_global_username
{
	return if $ENV{GLOBAL_USERNAME};
	print "Please enter your GLOBAL username [" . $ENV{USERNAME} . "]: ";
	my $global_username = <>;
	chomp($global_username);
	$global_username = $ENV{USERNAME} if ! $global_username;
	systema("setx GLOBAL_USERNAME $global_username -m");
	$ENV{GLOBAL_USERNAME} = $global_username;
}

sub add_global_user_to_local_admins
{
	my $cred = "GLOBAL\\" . $ENV{GLOBAL_USERNAME};
	return 1 if is_admin($cred);
	return 1 if systemi("net localgroup Administrators $cred /add")->ok;
	return 0;
}

sub add_local_admins
{
	systema("net user rvroot RvShos42 /add /passwordchg:yes /expires:never");

	systema("net localgroup Administrators rvroot /add");
	systema("net localgroup Administrators GLOBAL\\rvroot /add");

	return 0;
}

sub is_admin
{
	my ($cred) = @_;
	
	my $localg = systema("net localgroup Administrators");
	$localg->ordie;
	foreach ($localg->out)
	{
		return 1 if $_ eq $cred;
	}
	
	return 0;
}
