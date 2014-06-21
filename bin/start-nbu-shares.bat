if exist \\storage\NBU\%USERNAME% net use h: \\storage\NBU\%USERNAME% /persistent:yes
if not exist \\storage\NBU\%USERNAME% net use h: \\storage\users\%USERNAME% /persistent:yes

net use i: \\2000application\CCase  /persistent:yes
net use n: \\Storage\Software       /persistent:yes
net use r: \\Storage\NBU            /persistent:yes
net use U: \\bronze\%USERNAME%      /persistent:yes
net use y: \\rvil-nbu-tools\storage /persistent:yes

: net use v: \\rvil-nbu-tools\nbu-views     /persistent:yes
