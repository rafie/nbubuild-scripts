@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;
use Switch;

use Scaffolds::System;
use Scaffolds::Command;
 
my $nop;
my $show;
my $quiet;
my $enable_inherit;
my $disable_inherit;
my $users_file;
my $files_file;
my $raw;
my $hide_inherit;

my @users;
my @files;

while (@ARGV)
{
	my $a = $ARGV[0];
	if ($a eq '-n')
	{
		shift;
		$nop = 1;
	}
	elsif ($a eq '--inherit')
	{
		shift;
		$enable_inherit = 1;
	}
	elsif ($a eq '--no-inherit')
	{
		shift;
		$disable_inherit = 1;
	}
	elsif ($a eq '--users')
	{
		shift;
		$users_file = shift;
	}
	elsif ($a eq '--files')
	{
		shift;
		$files_file = shift;
	}
	elsif ($a eq '-s' || $a eq '--show')
	{
		shift;
		$show = 1;
	}
	elsif ($a eq '--hide-inherit')
	{
		shift;
		$hide_inherit = 1;
	}
	elsif ($a eq '-q')
	{
		shift;
		$quiet = 1;
	}
	elsif ($a eq '--raw')
	{
		shift;
		$raw = 1;
	}
	elsif ($a eq '-h' || $a eq '--help')
	{
		print_help();
		exit(1);
	}
	else
	{
		last;
	}
}

@users = read_list($users_file) if $users_file;
@files = read_list($files_file) if $files_file;

if ($show)
{
	push @files, @ARGV;
	die "No files specified\n" if $#files < 0;
	
	show_perms(@files);
	exit 0;
}

my $perm_arg = shift or die "No permissions specified.\n";
my ($icacls_op, $icacls_perm) = calc_perm($perm_arg);

if ($#ARGV == 1)
{
	push @users, shift;
	push @files, shift;
}
else
{
	while (@ARGV)
	{
		my $a = $ARGV[0];
		if ($a eq '--')
		{
			shift;
			push @files, @ARGV;
			last;
		}
		else
		{
			push @users, shift;
		}
	}
}

die "No users specified\n" if $#users < 0;
die "No files specified\n" if $#files < 0;

my $inherit_opt;
if ($enable_inherit || $disable_inherit)
{
	$inherit_opt = "/inheritance:" . $enable_inherit ? "e" : "r";
}

my $user_opts;
foreach my $user (@users)
{
	$user = fix_user($user);
	if ($icacls_perm)
	{
		$user_opts .= "$user:$icacls_perm ";
	}
	else
	{
		$user_opts .= "$user ";
	}
}

my $ok = 1;
for my $file (@files)
{
	if (! -e $file)
	{
		print "$file does not exist.\n";
		next;
	}
	
	my $cmd = "icacls $file $icacls_op $user_opts $inherit_opt";
	if ($nop)
	{
		print "$cmd\n";
	}
	else
	{
		my $icacls = systema($cmd);
		print $icacls->errText if $icacls->failed;
		$ok = $ok && $icacls->ok;
	}
}

show_perms(@files) if ! $quiet;

exit($ok ? 1 : 0);

sub calc_perm
{
	my ($perm) = @_;
	my %perms = ();
	my $icacls_perm = "(OI)(CI)";
	
	my $op = substr($perm, 0, 1);
	$perm = substr($perm, 1);
	
	die "Incorrect permisions spefified: $perm\n" if $op ne "+" && $op ne "-";

	if ($op eq "+")
	{
		$icacls_op =  "/grant:r";
		if ($perm eq "all")
		{
			$icacls_perm .= "F";
			return ($icacls_op, $icacls_perm);
		}
	}
	elsif ($op eq "-" && $perm eq "")
	{
		return ("/remove", "");
	}
	elsif ($op eq "-")
	{
		$icacls_op =  "/deny";
	}
	else
	{
		die "Incorrect permisions spefified: $perm_arg\n";
	}

	my $p;
	while ($perm ne "")
	{
		my $c = substr($perm, 0, 1);
		switch ($c)
		{
		case "r" { $p .= "RX" }
		case "w" { $p .= "M" }
		case "x" { $p .= "X" }
		else     { die "Incorrect permission: $c\n" }
		}
		$perm = substr($perm, 1);
	}
	
	die "Empty permission set.\n" if ! $p;
	$icacls_perm .= $p;
	return ($icacls_op, $icacls_perm);
}

sub fix_user
{
	my ($user) = @_;
	
	if ($user =~ /([^\\]+)\\(.+)/)
	{
		return "\"" . $ENV{COMPUTERNAME} . "\\$2\"" if $1 eq ".";
		return "\"$user\"";
	}

	return $user;
#	return $user if $user eq "BUILTIN";
#	my $domain = $ENV{USERDOMAIN};
#	return "\"$domain\\$user\"";
}

sub translate_perm
{
	my ($perm) = @_;
	
	my $inherited = 1 if $perm =~ /\(I\)/;

	$perm =~ s/\(OI\)//g;
	$perm =~ s/\(CI\)//g;
	$perm =~ s/\(IO\)//g;
	$perm =~ s/\(NP\)//g;
	$perm =~ s/\(I\)//g;
	return ($perm, $inherited) if ! ($perm =~ /^\([^()]*\)$/);
	return ("all", $inherited) if $perm eq "(F)";
	my $p;
	$p .= "r" if $perm =~ /R/;
	$p .= "w" if $perm =~ /W/ || $perm =~ /M/;
	$p .= "x" if $perm =~ /X/;
	return ($p, $inherited);
}

sub show_perms
{
	my (@files) = @_;

	for my $f (@files)
	{
		my $cmd = systema("icacls $f");
		if ($cmd->failed)
		{
			print "$f: error\n\n";
			next;
		}
		my @out = $cmd->out;
		$out[0] =~ /(\S+)\s+(.*)/;
		my $f1 = $1;
		$out[0] = $2;
		pop(@out);
		pop(@out);
		
		print "$f1\n";
		my @suka;
		for my $p (@out)
		{
			my ($user, $perm);
			if ($p =~ /\s*([^:]*):(.*)/)
			{
				$user = $1;
				$perm = $2;
			}
			else
			{
				$user = "*unknown*";
				$p =~ /\s*(.*)/;
				$perm = $1;
			}
			my ($perm1, $inherited) = translate_perm($perm);
			next if $inherited && $hide_inherit;
			$perm = $perm1 if ! $raw;
			push @suka, "$user: $perm";
			# print "\t$user: $perm\n";
		}
		for (uniq(@suka))
		{
			print "\t$_\n";
		}
		print "\n";
	}
}

sub uniq
{
    return sort keys %{{ map { $_ => 1 } @_ }};
}

sub print_help
{
	print <<END;
Change file system permissions.

usage:
wchmod [options] permissions user file
wchmod [options] permissions users -- files
wchmod [-s|--show] <files>
wchmod [-n] [-h|--help]

permissions: 
  [+-][r][w][x]
  [+-]all
  -

options:
  --users FILE     read user names from FILE
  --files FILE     read file names from FILE
  --inherit        enable inherited permissions
  --no-inherit     remove inherited permissions
  --hide-inherit   don't show inherited permissions
  -s|--show        show permissions of <files>
  -q               don't show permissions after change
  -n               no operation: just print commands
END
} 
