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

print "\nFixing IPv6 configuraiton...\n";

my %PREFIXES = (
	'2001::/32' =>     { prec =>  5, label => 5 },
	'::/96' =>         { prec => 20, label => 3 },
	'2002::/16' =>     { prec => 30, label => 2 },
	'::/0' =>          { prec => 40, label => 1 },
	'::ffff:0:0/96' => { prec => 45, label => 4 },
	'::1/128' =>       { prec => 50, label => 0 });

my %prefixes = ();
my $show = systema("netsh interface ipv6 show prefix");
foreach my $x ($show->out)
{
	next if ! ($x =~ /(\d+)\s+(\d+)\s+(.+)/);

	my $prec = $1;
	my $label = $2;
	my $prefix = $3;
	
	$prefixes{$prefix} = { prec => $prec, label => $label };
}

for my $p (keys %PREFIXES)
{
	if (! exists $prefixes{$p})
	{
		my $label = $PREFIXES{$p}{label};
		my $prec = $PREFIXES{$p}{prec};
		systemx("netsh interface ipv6 add prefixpolicy $p $prec $label");
	}
	elsif ($prefixes{$p}{prec} != $PREFIXES{$p}{prec})
	{
		my $label = $prefixes{$p}{label};
		my $prec = $PREFIXES{$p}{prec};
		systemx("netsh interface ipv6 set prefixpolicy $p $prec $label");
	}
}

exit(0);
