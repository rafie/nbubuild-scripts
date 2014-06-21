
use strict;

use Archive::Zip qw(:ERROR_CODES :CONSTANTS);;
use Archive::Zip::Tree;
use File::Basename;
use Sys::Hostname;
use Win32::FileSecurity;
use Win32::Lanman;
use Win32::Perms;
use Win32::TieRegistry;

use Scaffolds::System;
use Scaffolds::Command;
use Scaffolds::Util;

our $VERSION = "3.0.0";

my $root = $ENV{NBU_BUILD_ROOT};

Archive::Zip::setErrorHandler(sub {});

our $rvexec = "$root/sys/scripts/bin/.experimental/rvexec.bat";

our $local_host = lc(hostname);
our $local_stgloc = $ENV{DEVITO_CCSTG} ? $ENV{DEVITO_CCSTG} : "c:\\ccstg";
our $local_stgloc_share_name = "ccstg";
our $local_unc_stgloc = "\\\\$local_host\\$local_stgloc_share_name";

our $domain = $ENV{USERDOMAIN};
our $win_common_group = "$domain\\Domain Users";

our $mcu_versions = "r:/Mcu_Ngp/Versions_8.X/V8.0/Versions";

our %ccase_setups = (
	'RADVISION' =>  {
		'unix_region' => 	 "radvision", 
		'windows_region' =>  "radvision_nt", 
		'view_server' =>	 "rvil-ccview",
		'global_stgloc' =>	 "\\\\rvil-ccview\\cm\\views\\NBU",
		'local_ux_stgloc' => "/cm/views/NBU",
		'unix_group' =>		 "rvil_ccusers",
		},
	'GLOBAL' => {
		'unix_region' => 	 "ccav_unix", 
		'windows_region' =>  "ccav_win", 
		'view_server' =>	 "rvil-ccview",
		'global_stgloc' =>	 "\\\\rvil-bronze\\CC_AV\\views",
		'local_ux_stgloc' => "/net/rvil-bronze/CC_AV/views",
		'unix_group' =>		 "rvccgrp01",
		},
	);

my %ccase_setup = %{$ccase_setups{$domain}};

our $view_server = $ccase_setup{'view_server'};

our $global_stgloc = $ccase_setup{'global_stgloc'};
our $local_ux_stgloc = $ccase_setup{'local_ux_stgloc'};

our $ccase_unix_region = $ccase_setup{'unix_region'};
our $ccase_win_region = $ccase_setup{'windows_region'};

our $unix_group = $ccase_setup{'unix_group'};

my $name;
my $raw_flag = 0;
my $dyn_flag = 1;
my $nop_flag = 0;
my $on_server_flag = 0;
my $global_stg_flag = 0;
my $arc;
my $configspec;
my $fromspec;
my $mcuver;
my $user = $ENV{USERNAME};
our $verbose = 0;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-name')
	{
		shift;
		$name = shift;
	}
	elsif ($a eq '-raw')
	{
		shift;
		$raw_flag = 1;
	}
	elsif ($a eq '-dyn' || $a eq '-dynamic')
	{
		shift;
		$dyn_flag = 1;
	}
	elsif ($a eq '-snap' || $a eq '-snapshot')
	{
		shift;
		$dyn_flag = 0;
		die "Snapshot views are not supported.\n";
	}
	elsif ($a eq '-global')
	{
		shift;
		$global_stg_flag = 0; # disabled
	}
	elsif ($a eq '-server')
	{
		shift;
		$on_server_flag = 1;
	}
	elsif ($a eq '-spec')
	{
		shift;
		$configspec = shift;
	}
	elsif ($a eq '-fromspec')
	{
		shift;
		$fromspec = 1;
	}
	elsif ($a eq '-mcu')
	{
		shift;
		$mcuver = shift;
	}
	elsif ($a eq '-arc')
	{
		shift;
		$arc = shift;
	}
	elsif ($a eq '-verbose')
	{
		shift;
		$verbose = 1;
	}
	elsif ($a eq '-n')
	{
		shift;
		$nop_flag = 1;
	}
	else
	{
		last if ! other_options($a);
	}
}

$name = "mcu_$mcuver" if !$name && $mcuver;

$name = shift if !$name;

die "error: view name not specified.\n" if ! $name;
my $tag = ($raw_flag ? "" : $user . "_") . $name;

$configspec = "$tag.cspec" if $fromspec;

my $mcu_cspec;
if ($mcuver)
{
	$mcu_cspec = "${mcu_versions}/$mcuver/configspec.txt"; 
	die "error: invalid mcu version: $mcuver.\n" if ! -f $mcu_cspec;
	
	$configspec = $mcu_cspec if !$configspec;
}

die "error: invalid configspec.\n" if $configspec && ! -f $configspec;

if (! $on_server_flag)
{
	if ($arc)
	{
		create_local_view_from_arc($arc);
	}
	else
	{
		create_local_view();
	}
}
else
{
	die "View archives are not supported for remote views.\n" if $arc;
	create_remote_view();
}

if ($configspec)
{
	my $setcs = command("cleartool setcs -tag $tag $configspec", "cannot set configspec", 0);
	if (! $nop_flag && $setcs->retcode)
	{
		my $rmview = new Scaffolds::System("cleartool rmview -tag $tag");
		die "error: cannot set configspec.\n";
	}
}

create_ccase_explorer_link($tag) if ! $nop_flag;

print "view $tag created.\n";
exit(0);

#----------------------------------------------------------------------------------------------

sub find_stgloc
{
	# this is kind of tricky, since there's no one-stop config for the storage location

	my $stg;
#	if (! $ENV{DEVITO_CCSTG})
#	{
		# look in registry (HKCU\Software\Atria\ClearCase\CurrentVersion\clearviewtool)
		$stg = find_stgloc_in_reg();
		return $stg if keys %$stg;
	
		# look for a local view and deduce from its stgloc
		$stg = find_local_view();
		return $stg if keys %$stg;
#	}
	
	# create a stgloc at $local_stgloc. If directory exists, fail.
	$stg = make_stgloc();
	return $stg if keys %$stg;
	return {};
}

#----------------------------------------------------------------------------------------------

sub print_stgloc
{
	my ($stg) = @_;
	return if ! keys %$stg;
	print "local: " . $stg->{local} . "\n";
	print "global: " . $stg->{global} . "\n";
}

#----------------------------------------------------------------------------------------------

sub find_stgloc_in_reg
{
	my ($locstg, $globstg);

	verbose("check registry (HKCU/Software/Atria/ClearCase/CurrentVersion/clearviewtool) for storage location");

	my $key = $Registry->{q"HKEY_CURRENT_USER\Software\Atria\ClearCase\CurrentVersion\clearviewtool"} or return {};
	$globstg = $key->{"Last View Dir"} or return {};
	return {} if ! $globstg;

	my ($share, $share_path) = get_share_name($globstg);
	my $net_share = new Scaffolds::System("net share $share");
	foreach ($net_share->out)
	{
		$locstg = $1 if /Path *(.*)/;
	}
	return {} if ! $locstg || ! -d $locstg; # path should actually exist
	return { local => $locstg . "\\$share_path", global => $globstg };
}

#----------------------------------------------------------------------------------------------

# from UNC spec (\\host\share\dir) extract (share, dir)

sub get_share_name
{
	my ($d) = @_;
	my @p;
	my $d1;
	while (1)
	{
		$d1 = $d;
		$d = dirname($d);
		last if $d eq $d1;
		push @p, basename($d1);
	}
	@p = reverse(@p);
	my $host = $p[0];
	my $share = $p[1];
	shift @p;
	shift @p;
	return ($share, join("\\", @p));
}

#----------------------------------------------------------------------------------------------

sub find_local_view
{
	my $localhost = lc(hostname);
	my $lsview = new Scaffolds::System("cleartool lsview -short -quick -host $localhost");
	my $view = $lsview->out(0);
	return {} if ! $view;
	my $lsview = new Scaffolds::System("cleartool lsview -long $view");
	my ($locstg, $globstg);
	foreach ($lsview->out)
	{
		$globstg = $1 if /Global path\: (.*)/;
		$locstg = $1 if /View server access path\: (.*)/;
	}
	
	return {} if !$locstg || !$globstg;

	$globstg = dirname($globstg);
	$locstg = dirname($locstg);
	return { local => $locstg, global => $globstg };
}

#----------------------------------------------------------------------------------------------

sub make_stgloc
{
	my $ok = create_dir_with_share($local_stgloc, $local_stgloc_share_name, 'ClearCASE Views Storage');
	if ($ok)
	{
		my $key = $Registry->{q"HKEY_CURRENT_USER\Software\Atria\ClearCase\CurrentVersion\clearviewtool"};
		$key->{"Last View Dir"} = $local_unc_stgloc;
		return { local => $local_stgloc, global => $local_unc_stgloc };
	}
	return {};
}

#----------------------------------------------------------------------------------------------

sub create_dir_with_share
{
	my ($dir, $share, $desc) = @_;

	if (-d $dir)
	{
		# if dir is empty, remove it and later recreate, to setup the right permissions
		systema("net share $share /d");
		rmdir($dir) or return 0; # will fail if dir is not empty
	}
	mkdir($dir) or return 0;

	add_file_permissions($dir, $win_common_group, [qw(FULL GENERIC_ALL)]) or return 0; # directories get FULL GENERIC_ALL
	add_file_permissions($dir, "GLOBAL\\rvccgrp01", [qw(FULL GENERIC_ALL)]) or return 0; # directories get FULL GENERIC_ALL
	return add_share($dir, $share, $desc, $win_common_group);
}

#----------------------------------------------------------------------------------------------

sub add_file_permissions
{
	my ($dir, $group, $perm_list) = @_;
	my @new_perm = @{$perm_list};
	my %perm = ();
	Win32::FileSecurity::Get($dir, \%perm) or return 0;
	$perm{$group} = Win32::FileSecurity::MakeMask(@new_perm) or return 0;
	Win32::FileSecurity::Set($dir, \%perm) or return 0;
	return 1;
}

#----------------------------------------------------------------------------------------------

# returns 0 on failure

sub add_share
{
	my ($dir, $share, $desc, $group) = @_;

	my $perms = new Win32::Perms() or return 0;;
	$perms->Allow($group, FULL_SHARE) or return 0;;
	$perms->Allow("GLOBAL\\rvccgrp01", FULL_SHARE) or return 0;;

	my $rc = Win32::Lanman::NetShareAdd("\\\\$local_host",
		{	netname => $share,
			type => Win32::Lanman::STYPE_DISKTREE,
			remark => $desc,
			security_descriptor => $perms->GetSD(SD_RELATIVE),
			permissions => 0, # Win32::Lanman::ACCESS_ALL,
			max_uses => -1,
			path => $dir});

	$perms->Close();
	
	return !! $rc;
}

#----------------------------------------------------------------------------------------------

sub create_local_view
{
	my ($lstg, $gstg);
	if (! $global_stg_flag)
	{
		my $stg = find_stgloc();
		die "error: failed to determine storage location.\n" if ! keys %$stg;
		$lstg = $stg->{local};
		$gstg = $stg->{global};
	}
	else
	{
		# this is currently disabled (also: not tested)
		$lstg = $gstg = $global_stgloc;
	}

	my $hpath = "$lstg\\$tag.vws";
	my $gpath = "$gstg\\$tag.vws";
	die "error: view exists.\n" if -d $hpath;

	my $region = $ccase_win_region;
	my $host = $local_host;

	my $mkview_cmd = "cleartool mkview -tag $tag -tmode unix -region $region -shareable_dos " . 
		"-host $host " . 
		"-hpath $hpath -gpath $gpath $hpath";
	if (! $nop_flag)
	{
		my $mkview = new Scaffolds::System($mkview_cmd);
		die "cannot create view.\n" if $mkview->retcode;
	}
	else
	{
		print "$mkview_cmd\n";
	}
}

#----------------------------------------------------------------------------------------------

sub create_local_view_from_arc
{
	my ($arc) = @_;
	
	my ($lstg, $gstg);
	if (! $global_stg_flag)
	{
		my $stg = find_stgloc();
		die "error: failed to determine storage location.\n" if ! keys %$stg;
		$lstg = $stg->{local};
		$gstg = $stg->{global};
	}
	else
	{
		# this is currently disabled (also: not tested)
		$lstg = $gstg = $global_stgloc;
	}

	my $hpath = "$lstg\\$tag.vws";
	my $gpath = "$gstg\\$tag.vws";
	die "error: view exists.\n" if -d $hpath;

	my $region = $ccase_win_region;
	my $host = $local_host;

	my $zip = Archive::Zip->new($arc) or die "invalid archive: $arc\n";
	die "View directory $hpath exists: cannot extract archive.\n" if -e $hpath;
	if (! $nop_flag)
	{
		mkdir($hpath);
		$zip->extractTree('', "$hpath/");

		my $ccase = $Registry->{q"HKEY_LOCAL_MACHINE\SOFTWARE\Atria\ClearCase\CurrentVersion"} or die "Cannot find ClearCase key in registry\n";
		my $host_data = $ccase->{"HostData"} or die "Cannot find ClearCase HostData configuration.\n";
		my $fix_prot = "$host_data\\etc\\utils\\fix_prot.exe";
		die "Cannot find fix_prot" if ! -e $fix_prot;
		
		systema("\"$fix_prot\" -force -root -r -chown $domain\\$user -chgrp $domain\\$unix_group $hpath")->ordie("Error changing view files permissions.");
	}

	my $reg_cmd = "cleartool register -view -host $host -hpath $hpath $hpath";
	my $mktag_cmd = "cleartool mktag -view -tag $tag -region $region -host $host -gpath $gpath $hpath";

	if (! $nop_flag)
	{
		systema($reg_cmd)->ordie("cannot register view.");
		my $mktag = systema($mktag_cmd);
		if ($mktag->retcode)
		{
			systema("cleartool unregister -view $hpath");
			die "cannot create view tag.\n";
		}
	}
	else
	{
		print "$reg_cmd\n";
		print "$mktag_cmd\n";
	}
}

#----------------------------------------------------------------------------------------------

sub create_remote_view
{
	my $unix_path = "$local_ux_stgloc/$tag.vws";
	my $unc_path = "$global_stgloc\\$tag.vws";
	$unc_path =~ s/\\/\\\\/g;
	my $unix_ct = "/opt/rational/clearcase/bin/cleartool";
	my $unix_fixprot = "/opt/rational/clearcase/linux_x86/etc/utils/fix_prot";

	my $mkview = "$unix_ct mkview " .
		"-tag $tag " .
		"-tmode transparent " .
		"-region $ccase_unix_region " .
		"-host $view_server " .
		"-hpath $unix_path " .
		"-gpath $unix_path " .
		"$unix_path";
	
	my $mktag = "$unix_ct mktag -view " .
		"-tag $tag " .
		"-reg $ccase_win_region " .
		"-host $view_server " .
		"-gpath $unc_path " .
		"$unix_path";

	rcommand_try("cannot connect to server");
	rcommand($mkview, "cannot create view on server");
	rcommand($mktag, "cannot create view tag on server");
	rcommand("$unix_ct endview -server $tag", "cannot stop view");
	rcommand("$unix_fixprot -force -r -chown $user -chgrp $unix_group -chmod 775 $unix_path", "cannot setup view permissions on server");
	rcommand("$unix_fixprot -force -root -chown $user -chgrp $unix_group $unix_path", "cannot setup view permissions on server");

	my $startview_cmd = "cleartool startview $tag";
	if (! $nop_flag)
	{
		my $setcs = new Scaffolds::System($startview_cmd);
		die "error: cannot start view\n" if $setcs->retcode;
	}
	else
	{
		print "$startview_cmd\n";
	}
}

#----------------------------------------------------------------------------------------------

sub command
{
	my ($cmd, $err, $abort_on_fail) = @_;
	$abort_on_fail = 1 if ! defined $abort_on_fail;
	if (! $nop_flag)
	{
		my $c = new Scaffolds::System($cmd);
		die "error: $err\n" if $c->retcode && $abort_on_fail;
		return $c;
	}
	else
	{
		print "$cmd\n";
		return 1;
	}
}

#----------------------------------------------------------------------------------------------

sub rcommand
{
	my ($cmd, $err, $abort_on_fail) = @_;
	$abort_on_fail = 1 if ! defined $abort_on_fail;
	my $rcmd = "$rvexec --no-try --no-ask $view_server $cmd";
	if (! $nop_flag)
	{
		my $c = new Scaffolds::System($rcmd);
		die "error: $err\n" if $c->retcode && $abort_on_fail;
		return $c;
	}
	else
	{
		print "$rcmd\n";
		return 1;
	}
}

#----------------------------------------------------------------------------------------------

sub rcommand_try
{
	my ($err, $abort_on_fail) = @_;
	$abort_on_fail = 1 if ! defined $abort_on_fail;
	my $rcmd = "$rvexec --try --ask $view_server";
	if (! $nop_flag)
	{
		my $c = new Scaffolds::System($rcmd);
		die "error: $err\n" if $c->retcode && $abort_on_fail;
		return $c;
	}
	else
	{
		print "$rcmd\n";
		return 1;
	}
}

#----------------------------------------------------------------------------------------------

sub verbose
{
	my ($text) = @_;
	print "$text\n" if $verbose;
}

#----------------------------------------------------------------------------------------------

sub create_ccase_explorer_link
{
	my ($name) = @_;

	my $fh = File::Temp->new(SUFFIX => '.reg');
	print $fh <<TEXT;
REGEDIT4

[HKEY_CURRENT_USER\\Software\\Atria\\ClearCase\\CurrentVersion\\ClearCase Explorer\\ViewsPage\\General\\$name]
"Tooltip"="$name"
"AccessString"="M:\\$name"
"IconKey"=dword:0000001e
"Default"=dword:00000000
"Visible"=dword:00000001
"Redefined"=dword:00000000
"Dependency"=""
"Version"=dword:00000001
"Removed"=dword:00000000
"Type"="view"
"SnapshotView"=dword:00000000
"IntegrationView"=dword:00000000
"UcmView"=dword:00000000
"ProjectName"=""
"LastFolder"=""
"UsesDriveMapping"=dword:00000000

TEXT
	my $fname = $fh->filename;
	close $fh;

	my $import = systema("reg import $fname");
	return $import->ok;
}

#----------------------------------------------------------------------------------------------

sub print_help
{
	print <<END;
Create a view.

usage:
ct1 mkview [-name <name>] [-raw] [-spec <file>] [-mcu <version>] [-arc archive.zip]
           [-dynamic | -snapshot] [-server] [-n] [-verbose]
ct1 mkview [-h | -help | -v | -version]

options:
  -name <name>   view name
  -raw           don't add username prefix to view name
  -spec <file>   configspec file
  -mcu <ver>     create view for mcu version <ver> 
                  (take configspec from r:\Mcu_Ngp\Versions_8.X\V8.0\Versions)
  -arc <zip>     view archive (.zip file)
  -dynamic       create dynamic view (default)
  -snapshot      create snapshot view
  -server        create view on server (rvil-ccview) [*]
  -verbose       be verbose: explain everything.
  -n             do nothing, just print commands
  -h             print this message
  -v             print version

[*] Creating a view on the server requires one to enter their password.
    It is possible to automate the process and aviod the password prompt.
    For more information, search http://nbuwiki for ct-mkview.
END
}

