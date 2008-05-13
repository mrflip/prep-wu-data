( grep -h ^210'[1-5]' * | cut -d, -f1,3,4,7,8,11,12,15,16,19,20; echo; echo "---"; echo; head -300 lunar-kronberg.flat | perl -e 'local $/; $_= <>; s/[\r\n]+/!!/g; $_.="!!"; my @moons=split /Lunation number/,$_; shift @moons; for my $moon (@moons) { (my ($lun,)) = ($moon =~ m/^\s*([\+\-]?\d+)\s*!!/); print $lun+24724,", "; my $i=0; for my $qtr ($moon =~ m/\w+ (?:moon|quarter)\s*JDE =[^!]*!!/go) { print ""; my @qtrinfo = (my ($jd, $d, $m, $y, $h, $min)) = ($qtr =~ m/\s*\w+ (?:moon|quarter)\s*JDE =\s*(\d+\.\d+)\s*(\d+)-(\d+)-(\d+),[\s\d\.]+ =\s*(\d+)h\s*(\d+)m/); $rdsecs=((24*60*60)*($jd-1721425.5)); printf "%02d-%02d-%02dT%02d:%02d:00,%14s, ",$y,$m,$d,$h,$min,int($rdsecs); } print "\n"; }' )
