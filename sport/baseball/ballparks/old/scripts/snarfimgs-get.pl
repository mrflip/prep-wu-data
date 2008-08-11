#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;

my $parkinfodir  = '/Users/flip/now/GusGorman/apps/BaseballBrainiac/pysrc/retrosheet/info/parks';
my $datadir      = '/work/DataSources/Data_MLB/sportslogos.net/sportslogos.net';

my $dumpfilename = "$parkinfodir/scripts/parkinfo-sportslogos.txt";
my $dumpfile     = new IO::File; $dumpfile->open(">$dumpfilename") or die "Can't write to  $dumpfilename: $!";
my $csvfilename  = "$parkinfodir/scripts/parkinfo-sportslogos.csv";
my $csvfile      = new IO::File; $csvfile->open(">$csvfilename")   or die "Can't write to  $csvfilename: $!";

my %fixnames = (
    "Anaheim Angels"		=> "Los Angeles Angels of Anaheim",
    "Boston Americans"		=> "Boston Red Sox",
    "Boston Beaneaters"		=> "Atlanta Braves",
    "Boston Bees"		=> "Atlanta Braves",
    "Boston Braves"		=> "Atlanta Braves",
    "Boston Doves"		=> "Atlanta Braves",
    "Boston Rustlers"		=> "Atlanta Braves",
    "Boston Somersets"		=> "Boston Red Sox",
    "Brooklyn Dodgers"		=> "Los Angeles Dodgers",
    "Brooklyn Robins"		=> "Los Angeles Dodgers",
    "Brooklyn Superbas"		=> "Los Angeles Dodgers",
    "California Angels"		=> "Los Angeles Angels of Anaheim",
    "Cincinnati Redlegs"	=> "Cincinnati Reds",
    "Cleveland Naps"		=> "Cleveland Indians",
    "Houston Colt .45s"		=> "Houston Astros",
    "Philadelphia Athletics"	=> "Oakland Athletics",
    "Kansas City Athletics"	=> "Oakland Athletics",
    "Los Angeles Angels"	=> "Los Angeles Angels of Anaheim",
    "Milwaukee Braves"		=> "Atlanta Braves",
    "Montreal Expos"		=> "Washington Nationals",
    "New York Highlanders" 	=> "New York Yankees",
    "Seattle Pilots"		=> "Milwaukee Brewers",
    "Tampa Bay Rays"		=> "Tampa Bay Devil Rays",
    "Chicago White Stockings"	=> "Chicago White Sox",
    "Cleveland Blues"		=> "Cleveland Indians",        
    "New York Giants"		=> "San Francisco Giants",
);

my %franchIDmap = (
    "Arizona Diamondbacks"	 =>"ARI",
    "Atlanta Braves"    	 =>"ATL",
    "Baltimore Orioles"   	 =>"BAL",
    "Boston Red Sox"		 =>"BOS",
    "Chicago Cubs"		 =>"CHC",
    "Chicago White Sox"		 =>"CHW",
    "Cincinnati Reds"		 =>"CIN",
    "Cleveland Indians"		 =>"CLE",
    "Colorado Rockies"		 =>"COL",
    "Detroit Tigers"		 =>"DET",
    "Florida Marlins"		 =>"FLA",
    "Houston Astros"		 =>"HOU",
    "Kansas City Royals"	 =>"KCR",
    "Los Angeles Angels of Anaheim" =>"ANA",
    "Los Angeles Dodgers"	 =>"LAD",
    "Milwaukee Brewers"		 =>"MIL",
    "Minnesota Twins"		 =>"MIN",
    "New York Mets"		 =>"NYM",
    "New York Yankees"		 =>"NYY",
    "Oakland Athletics"		 =>"OAK",
    "Philadelphia Phillies"	 =>"PHI",
    "Pittsburgh Pirates"	 =>"PIT",
    "San Diego Padres"		 =>"SDP",
    "San Francisco Giants"	 =>"SFG",
    "Seattle Mariners"		 =>"SEA",
    "St. Louis Cardinals"	 =>"STL",
    "Tampa Bay Devil Rays"	 =>"TBD",
    "Texas Rangers"		 =>"TEX",
    "Toronto Blue Jays"		 =>"TOR",
    "Washington Nationals"	 =>"WSN",
    "Washington Senators"	 =>"WAS",
    "St. Louis Browns"		=> "FIX_SLB",
    "American League"		=> "_AL",
    "National League"		=> "_NL",
    );

# SELECT RPAD(L.franchName,40,' '), F.franchID, MIN(T.yearID) AS beg, MAX(T.yearID) AS end, 
# 	GROUP_CONCAT(DISTINCT T.lgID SEPARATOR ' | ') AS lgs,
# 	RPAD(GROUP_CONCAT(DISTINCT CONCAT(T.teamID, ' (',T.lgID,')') SEPARATOR ' | '),30,' ') AS teamIDs, 
# 	GROUP_CONCAT(DISTINCT T.name SEPARATOR ' | ') AS teamNames, F.*, COUNT(DISTINCT T.teamID) AS numteams, T.lgID
#   FROM 		Parks_logos L
#   LEFT JOIN	vizsagedb_baseballdatabank.TeamsFranchises F ON F.franchName = L.franchName
#   LEFT JOIN vizsagedb_baseballdatabank.Teams           T on T.franchID   = F.franchID
#   WHERE 	sl_lgID IN (53,54) AND L.franchName NOT IN ('ALCS', 'ALDS', 'NLCS', 'NLDS', 'American League', 'National League')
#   GROUP BY	L.franchName, F.franchID, F.franchName  -- T.name, 
#   ORDER BY	lgs, F.franchName ASC, L.franchName ASC

for my $filename (<>) {
    (chomp $filename);
    my $fh  = new IO::File;
    $fh->open("<$filename") or die "Can't read from $filename: $!";

    local $/;
    $_ = <$fh>;

    m{<span class="click">([^<]*)</span>}si or warn "Bad match in $filename";
    my $title = $1; 
    m{img[^>]*src="((?:http://(?:[^\.]*\.)?sportslogos.net|..)/([^\.]*)/([^\./]*\.gif)"[^>]*alt=.*?$)\n}io ; my $line = $1;
    m{img[^>]*src="(?:http://(?:[^\.]*\.)?sportslogos.net|..)/([^\.]*)/([^\./]*\.gif)"[^>]*alt="\s*(.*?)\s*(?:/>|\w+=)}sio or warn "Bad match in $filename: $line"; #"};
    (my ($dir, $rmt, $named)) = ($1, $2, $3);
    $rmt =~ m/(\w+)\.gif/; my $logoID = $1;

    # a couple files have null records
    next if ($named =~ m/^(Uniform|Logo) +- +/); 

    # the following funny chars are left in: ()@/.,-&#\s
    $named =~ s/&\#\d+;//go; $named =~ tr/'\*\n\r"//d; #'; 
    $named =~ tr/;/,/; $named =~ tr/\/\xe3\xe9\xed\xF4\xFA\xFCç/-aeiouuc/; $named =~ s/\s+/ /g;                                        
    $title =~ s/&\#\d+;//go; $title =~ tr/'\*\n\r"//d; #'; 
    $title =~ tr/;/,/; $title =~ tr/\/\xe3\xe9\xed\xF4\xFA\xFCç/-aeiouuc/; $title =~ s/\s+/ /g;

    # get $name, $role, $type, $curr, $years
    ($title =~ m/(.*)(alternate|anniversary|cap|championship|event|home|home|memorial|miscellaneous|pennant|practice|primary|program|road|road|script|stadium|ticket stub|unused|promo item|helmet) (logo|jersey|cap|pennant|program|ticket stub|promo item) in use (\w+) (\d+-\d+|\d+)/) 
	or warn "Bad match to title $title in $filename";
    (my ($name, $role, $type, $curr, $years)) = ($1, ucfirst lc $2, ucfirst lc $3, $4, $5);
    # get name, loc, desc
    ($named =~ m/(.*?) (?:logo|jersey|cap|pennant|program|ticket stub|uniform|promo item) - (?:\(([^\)]*)\) )?(.*)/i) or warn "Bad match to named $named in $filename";
    (my ($name2, $loc, $desc)) = ($1,  ($2||''), $3);
    # get ($sl_lgID, $sl_teamID)
    $dir =~ m{logos/(\d+)/(\d+)/};
    (my ($sl_lgID, $sl_teamID)) = ($1||'', $2||'');

    # Fix desc
    $desc =~ s/\s*-\s+/, /;
    # Fix loc 
    $loc =~ s/[\d\-\s]+$//;
    $loc =~ s/B\.P\.?/BP/;
    $loc =~ s/(Alt\.|Alte?rnate)/Alt/;
    $loc =~ s/Alt\W+(Home|Road)/$1_Alt/;
    $loc =~ s/BP\W+Home\W+Alt/Home_Alt_BP/;
    $loc =~ s/(\w+)\s*(?:\W+|and)\s*(\w+)/$1_$2/;
    $loc = '' if (($loc =~ m/alt/i) && ($role =~ m/alternate/i));
    $loc = '' if (($loc =~ m/cap/i) && ($role =~ m/cap/i));

    # Fix years, beg, end
    if ($years =~ m/^\d\d$/) { 
	$years = 'NULL-NULL';
    } else {
	for ($curr) {     
	    /^from$/    && do { if ($years =~ m/^\d{4}$/) { $years = "$years-$years"; }; last; };
	    /^in$/      && do { $years = "$years-$years"; last; };
	    /^since$/   && do { $years = "$years-curr";    last; };
	    warn "unknown value for curr $curr in $filename";
	}
    }
    (my ($beg, $end)) = ($years =~ m!(.{4})-(.{4})!);

    # Fix name, franchID
    $name=~ s/^\s+//; $name=~ s/\s+$//; 
    my $franchID = '';
    if ( ($sl_lgID eq '53') || ($sl_lgID eq '54') ) {
	$name = $fixnames{$name} if exists $fixnames{$name};
	$franchID = $franchIDmap{$name} || '';
    }
    # funny franchise mismatches
    # The Baltimore Orioles 	were in NYY (AL) from 1901-1902 as New York Yankees (AL)	and BAL (AL) from 1954-2006 as Baltimore Orioles (AL)	and BLO (NL) from 1892-1899 as Baltimore Orioles (NL)
    # The Milwaukee Brewers 	were in BAL (AL) from 1901-1901 as Baltimore Orioles (AL)	and MIL (AL,NL) from 1970-curr as Milwaukee Brewers (AL,NL
    # The Washington Nationals 	were in WNL (NL) from 1886-1889 as Washington Nationals (NL)	and WSN (NL) from 2005-2006 as Washington Nationals (NL)
    # The Washington Senators 	were in WAS (NL) from 1892-1899 as Washington Senators (NL)	and MIN (AL) from 1901-1960 as Minnesota Twins (AL)	and TEX (AL) from 1961-1971 as Texas Rangers (AL)
    # The Cincinnati Reds	were in CIN (NL) from 1890-2006 as Cincinnati Reds (NL) 	and CNR (NL) from 1876-1880 as Cincinnati Reds (NL)
    # The Cleveland Blues	were in CBL (NL) from 1879-1884 as Cleveland Blues (NL) 	and CLE (AL) from 1901-1901 as Cleveland Indians (AL)
    # The Philadelphia Athletics were in OAK (AL) from 1901-1954 as Oakland Athletics (AL)	and ATH (NL) from 1876-1876 as Philadelphia Athletics (NL)
    # The St. Louis Browns	were in BAL (AL) from 1902-1953 as Baltimore Orioles (AL)	and STL (NL) from 1892-1898 as St. Louis Cardinals (NL)
    for ($franchID) {
	/^BAL$/   && do { 
	    if    (($end ne 'curr') && ($end <= 1899)) { ($name,$franchID)=('Baltimore Orioles','BLO'); }
	    elsif (($end ne 'curr') && ($end <= 1902)) { ($name,$franchID)=('New York Yankees', 'NYY'); }  last; 
	};
	/^MIL$/   && do { 
	    if    (($end ne 'curr') && ($end <= 1901)) { ($name,$franchID)=('Baltimore Orioles','BAL'); }  last; 
	};
     	/^WSN$/   && do { 
	    # sl.net has them as Senators 05-54
	    if    (($end ne 'curr') && ($end <= 1889)) { ($name,$franchID)=('Washington Nationals','WNL'); } 
	    elsif (($end ne 'curr') && ($end <= 1954)) { ($name,$franchID)=('Minnesota Twins',     'MIN'); }  last; 
	};
     	/^WAS$/   && do { 
	    if    (($end ne 'curr') && ($end <= 1960)) { ($name,$franchID)=('Minnesota Twins','MIN'); }
	    elsif (($end ne 'curr') && ($end <= 1971)) { ($name,$franchID)=('Texas Rangers'  ,'TEX'); }  last; 
	};
	/^FIX_SLB$/ && do { 
	    if    (($end ne 'curr') && ($end <= 1898)) { ($name,$franchID)=('St. Louis Cardinals', 'STL'); } 
	    elsif (($end ne 'curr') && ($end <= 1953)) { ($name,$franchID)=('Baltimore Orioles',   'BAL'); }  last; 
	};
    }

    my $savefile   = sprintf "%s %s - %s %s%s - %s.gif", $name, $years, $role, $type, ($loc?" ($loc)":''), $desc;
    my $savepath = "$datadir/$dir/$savefile";
    my $url      = "http://sportslogos.net/$dir/$rmt";
    
    printf $dumpfile "%-30s |%-3s|%-12s|%-14s|%-14s|%-8s|%-8s|%-3s|%-3s|%-5s|%-40s|%-60s|%-50s|%-50s\n", 
    	$name, $franchID, $years, $role, $type, $loc, $logoID, $sl_lgID, $sl_teamID, $curr, $desc, $savefile, $filename, $url; 
    printf $csvfile  "%s\n", join ',', map { ($_ eq 'NULL' ? 0 : "\"$_\"") } ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, ($end eq 'curr'?'9999':$end), $loc, $desc, $logoID, $savefile, $filename, $url); 
    
    if ( -f "$savepath" ) {
	print "Skipping \"$savepath\"\n";
    } else {
	system("wget -nv -erobots=off --no-clobber -a $datadir/snarfimgs-log.txt \"$url\" -O \"$savepath\"");
    }
    
}
    # printf STDERR "Not fetching, uncomment\n";

# These are missing, I'm just stuffing a random file in there
# CHW 	1917 is also 1919-1929 and 1931, 1936-1938
# CLE 	1980 is also 1951-1972
# CHC	(1905, 1915, 1917)?
# STL	(1920, 1921)?

# egrep '(Chicago White.*Primary.*19..","(1918|1930|1935)"|Cleveland In.*Primary.*19..","1950"|St. Louis.*Primary.*19..","1919"|Chicago Cub.*Primary.*19..","(1903|1914|1916)).*lo=' parkinfo-sportslogos.csv | sort -u
my @missinglogos = (
	   ["Chicago Cubs",		"CHC","54","54","Primary","Logo","in",  '1904', '1905', "","Unknown, using placeholder - A blue olde English style C","7247","Chicago Cubs 1903-1903 - Primary Logo - A blue olde English style C.gif","logo.php?lo=7247","http://sportslogos.net/images/logos/54/54/full/7247.gif"													      ],
	   ["Chicago Cubs",		"CHC","54","54","Primary","Logo","from",'1915', '1915', "","Unknown, using placeholder - Sillouetted Cub with bat inside a blue C","2920","Chicago Cubs 1908-1914 - Primary Logo - Sillouetted Cub with bat inside a blue C.gif","logo.php?lo=2920","http://sportslogos.net/images/logos/54/54/full/2920.gif"										      ],
	   ["Chicago Cubs",		"CHC","54","54","Primary","Logo","in",  '1917', '1917', "","Unknown, using placeholder - A red C with blue trim and a blue bear cub walking inside","7249","Chicago Cubs 1916-1916 - Primary Logo - A red C with blue trim and a blue bear cub walking inside.gif","logo.php?lo=7249","http://sportslogos.net/images/logos/54/54/full/7249.gif"						      ],
	   ["Chicago White Sox",	"CHW","53","55","Primary","Logo","in",  '1919', '1929', "","Unknown, using placeholder - A blue S with four white sock on it, with an o and an x inside","7147","Chicago White Sox 1918-1918 - Primary Logo - A blue S with four white sock on it, with an o and an x inside.gif","logo.php?lo=7147","http://sportslogos.net/images/logos/53/55/full/7147.gif"			      ],
	   ["Chicago White Sox",	"CHW","53","55","Primary","Logo","in",  '1931', '1931', "","Unknown, using placeholder - A red S with an O and an X inside outlined in blue","7146","Chicago White Sox 1930-1930 - Primary Logo - A red S with an O and an X inside outlined in blue.gif","logo.php?lo=7146","http://sportslogos.net/images/logos/53/55/full/7146.gif"						      ],
	   ["Chicago White Sox",	"CHW","53","55","Primary","Logo","from",'1936', '1938', "","Unknown, using placeholder - SOX written diagonally in red, with a baseball in the O and a bat behin","7148","Chicago White Sox 1932-1935 - Primary Logo - SOX written diagonally in red, with a baseball in the O and a bat behin.gif","logo.php?lo=7148","http://sportslogos.net/images/logos/53/55/full/7148.gif"	      ],
	   ["Cleveland Indians",	"CLE","53","57","Primary","Logo","from",'1951', '1972', "","Unknown, using placeholder - Chief Wahoo with tan skin, red headband and feather","720","Cleveland Indians 1946-1950 - Primary Logo - Chief Wahoo with tan skin, red headband and feather.gif","logo.php?lo=720","http://sportslogos.net/images/logos/53/57/full/720.gif"						      ],
	   ["St. Louis Cardinals",	"STL","54","72","Primary","Logo","from",'1920', '1921', "","Unknown, using placeholder - Fancy red interlocking STL","eq4b3gtidxf3q8je0h7y","St. Louis Cardinals 1900-1919 - Primary Logo - Fancy red interlocking STL.gif","logo.php?lo=eq4b3gtidxf3q8je0h7y","http://sportslogos.net/images/logos/54/72/full/eq4b3gtidxf3q8je0h7y.gif"                                                ],
	   ["American League",  	"_AL","53","488","Primary","Logo","from","1901","curr","","No Logo, using initial 1969 version - An Eagle with banner perched on ringed baseball with 12 stars","1975","American League 1969-1976 - Primary Logo - An Eagle with banner perched on ringed baseball with 12 stars.gif","logo.php?lo=1975","http://sportslogos.net/images/logos/53/488/full/1975.gif" ],
	   ["National League",  	"_NL","54","489","Primary","Logo","from","1876","curr","","No Logo, using initial 1969 version - An Eagle with a shield with 12 stars holding a bat and a glove","1984","National League 1969-1992 - Primary Logo - An Eagle with a shield with 12 stars holding a bat and a glove.gif","logo.php?lo=1984","http://sportslogos.net/images/logos/54/489/full/1984.gif" ],
    );


for my $missinglogo (@missinglogos) {
    (my ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, $end, $loc, $desc, $logoID, $savefile, $filename, $url)) = 
	@$missinglogo;
    ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, $end, $loc, $desc, $logoID, $savefile, $filename, $url) = 
	($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, $end, $loc, $desc, "${beg}_$logoID", $savefile, $filename, $url);

    printf $dumpfile "%-30s |%-3s|%-12s|%-14s|%-14s|%-8s|%-8s|%-3s|%-3s|%-5s|%-40s|%-60s|%-50s|%-50s\n", 
    	$name, $franchID, "$beg-$end", $role, $type, $loc, $logoID, $sl_lgID, $sl_teamID, $curr, $desc, $savefile, $filename, $url; 
    printf $csvfile  "%s\n", join ',', map { ($_ eq 'NULL' ? 0 : "\"$_\"") } ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, ($end eq 'curr'?'9999':$end), $loc, $desc, $logoID, $savefile, $filename, $url); 
}

# I maked a logo for the rest of the leagues too
my @extralogos = (
	   ['AA', '1882', '1891', 'American Association', ],
	   ['FL', '1914', '1915', 'Federal League',       ],
	   ['NA', '1871', '1875', 'National Association', ],
	   ['PL', '1890', '1890', 'Players League',       ],
	   ['UA', '1884', '1884', 'Union Association',    ],
	);
for my $extralogo (@extralogos) {
    my ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, $end, $loc, $desc, $logoID, $savefile, $filename, $url);
    ($franchID, $beg, $end, $name) = @$extralogo;
    ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, $end, $loc, $desc, $logoID, $savefile, $filename, $url) =
	($name, "_$franchID", 'xtra', $franchID, 'Primary', 'Logo', 'for', $beg, $end, '', 
	 "A placeholder logo for the $name baseball league, active from $beg-$end", "_xtra_$franchID", "$franchID.png", 'synthesized', "../extralogos/$franchID.png");

    printf $dumpfile "%-30s |%-3s|%-12s|%-14s|%-14s|%-8s|%-8s|%-3s|%-3s|%-5s|%-40s|%-60s|%-50s|%-50s\n", 
    	$name, $franchID, "$beg-$end", $role, $type, $loc, $logoID, $sl_lgID, $sl_teamID, $curr, $desc, $savefile, $filename, $url; 
    printf $csvfile  "%s\n", join ',', map { ($_ eq 'NULL' ? 0 : "\"$_\"") } ($name, $franchID, $sl_lgID, $sl_teamID, $role, $type, $curr, $beg, ($end eq 'curr'?'9999':$end), $loc, $desc, $logoID, $savefile, $filename, $url); 
}

$dumpfile->close();
$csvfile->close();
