
my $s;
while (<>)
{
	chomp;
	
	my $s1 = $s . " $_";
	if (length($s1) > 500)
	{
		system("e $s");
		$s = " $_";
	}
	else
	{
		$s = $s1;
	}
}

system("e $s") if $s;
