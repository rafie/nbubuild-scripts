@rem ='
@echo off
ccperl %0 %*
exit /b %errorlevel%
@rem ';

use POSIX qw/strftime/;

my $br = $ENV{CLEARCASE_ID_STR};
my $br0 = $br =~ /.*[\\\/]0$/;
my $user = $ENV{CLEARCASE_USER};
my $brname = $ENV{CLEARCASE_BRTYPE};
my $fname = $ENV{CLEARCASE_PN};
my $date = strftime("%d-%b-%Y", localtime);

if ($br0)
{
	open F, "<$fname";
	my @content = <F>;
	close F;
	open F, ">$fname";
	print F "= {by $user\@$brname; $date}\n* \n";
	print F join("", @content);
	close F;
}
exit 0;
