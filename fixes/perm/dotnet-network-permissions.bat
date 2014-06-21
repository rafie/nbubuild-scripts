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
use Scaffolds::Util;

print "\nFixing .NET network permissions...\n";

our $windir = w2u($ENV{SystemRoot});
my $dotnet = find_dotnet_1();

my $caspol_w = u2w("$dotnet/caspol.exe");

systemx("$caspol_w -q -machine -addgroup LocalIntranet_Zone -url \"file://\\\\storage\\NBU\\*\" FullTrust -name \"Celerra (intranet)\"");
systemx("$caspol_w -q -machine -addgroup Internet_Zone -url \"file://\\\\storage\\NBU\\*\" FullTrust -name \"Celerra (internet)\"");
systemx("$caspol_w -q -machine -addgroup Internet_Zone -url \"file://\\\\nx1\\main\\*\" FullTrust -name \"Nexenta (internet)\"");
systemx("$caspol_w -q -machine -addgroup Internet_Zone -url \"file://\\\\vmware-host\\Shared Folders\\*\" FullTrust -name \"VMware Shared Folders (internet)\"");

# workaround for .net code what won't run from a network drive
systemx("setx COMPLUS_LoadFromRemoteSources 1 -m");

exit(0);

sub find_dotnet
{
	my $is_x64 = $ENV{"ProgramFiles(x86)"} ? 1 : 0;
	my $framework = $is_x64 ? "Framework64" : "Framework";
	
	my @dotnet_dirs = (
		"$windir/Microsoft.NET/$framework/v4.0.30319",
		"$windir/Microsoft.NET/$framework/v2.0.50727");
	
	my $dotnet;
	for my $dir (@dotnet_dirs)
	{
		if (-d $dir)
		{
			$dotnet = $dir;
			last;
		}
	}
	
	die "Cannot locate .NET framework.\n" if ! $dotnet;
	
	return $dotnet;
}

sub find_dotnet_1
{
	my $dotnet = "$windir/Microsoft.NET/Framework/v2.0.50727";
	die "Cannot locate .NET framework.\n" if ! $dotnet;
	return $dotnet;
}
