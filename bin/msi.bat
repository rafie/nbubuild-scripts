@rem ='
@echo off
setlocal
call set-nbu-build-env.bat
%NBU_BUILD_PERL%\bin\perl.exe -S %0 %*
exit /b %errorlevel%
@rem ';
#line 9

use strict;

use Getopt::Long;
use Pod::Usage;
use Win32::OLE;

use Scaffolds;

my $help;
my $install;
my $uninstall;
my $list;
my $gui;
my $verbose;

my $opt = GetOptions (
	'help|?|h' => \$help,
	'i|install' => \$install,
	'u|uninstall' => \$uninstall,
	'gui|revo' => \$gui,
	'l|list' => \$list,
	'v|verbose' => \$verbose,
	) or pod2usage(-exitstatus => 1, -verbose => 99, -sections => "SYNOPSIS|OPTIONS");
pod2usage(-exitstatus => 0, -verbose => 2) if $help;

my $n = 0;
++$n if $install;
++$n if $uninstall;
++$n if $list;
die "Conflicting options.\n" if $n > 1;

if ($install)
{
}

if ($uninstall)
{
}

if ($list)
{
	foreach (sort(get_packages()))
	{
		print "$_\n";
	}

}

if ($gui)
{
	system("start R:/Mcu_Ngp/Utilities/Revo/curr/Revouninstaller.exe");
}

exit 0;

sub get_packages
{
	my $installer = Win32::OLE->new("WindowsInstaller.Installer") or die;
	
	my $products = $installer->Products;
	my $n = $products->Count();
	my @packs;
	for (my $i = 0; $i < $n; ++$i)
	{
		my $code = $products->Item($i);
		my $name = $installer->ProductInfo($code, "ProductName");
		push @packs, $name;
	}
	return @packs;
}

sub get_packages_wmic
{
	my $list = systema("wmic product get name | cat");
	my @packs = $list->out();
	shift @packs;
	return @packs;
}

__END__

=head1 NAME

msi - Microsoft Installer human-friendly interface

=head1 SYNOPSIS

msi [options]

=head1 OPTIONS

=over 12

=item B<-h|--help>

Print a brief help message and exits.

=item B<-i|--install> package.msi

Installs package.msi.

=item B<-u|--uninstall> package-name

Uninstalls package named package-name. Use quotes if package name contains spaces.

=item B<-l|--list>

Display installed packages.

=cut
