#!/usr/bin/perl

# To get the files
# wget -erobots=off -r -l1 --no-clobber --relative --no-host-directories --cut-dirs=2 http://www.retrosheet.org/boxesetc/MISC/PKDIR.htm

# To run the script
# (for foo in PK_* ; do cat "$foo" | ./parkinfo.pl ; done ) > parkinfo.txt 

# to compare with BDB
# SELECT teamID, MIN(yearID), MAX(yearID), count(*), park FROM `Teams` 
# GROUP BY park, teamID
# ORDER BY park, teamID

use Data::Dumper;
use XML::Simple;


my $xmlparks = XMLin('parkinfo-fromparkcodes.xml', KeyAttr=>'siteID', SuppressEmpty=>'');
#print Dumper($xmlparks);

%lghash = qw{A AL N NL n NA a AA U UA P PL F FL};

# Snarf park file 
$_=join "",<>; 
@files = split /<HTML/, $_;

for $_ (@files) {
    (my ($name, $city, $state, $rest)) = m!<TITLE>.*</TITLE>.*<H1>(.*) in (.*), (.*)</H1>(.*)!s;
    $city  =~ s/^St. /Saint /;
    $state =~ s/Japan/JAP/i;
    $rest  =~ m!<A href="../(\d{4})/!; $firstyear = $1; #"

    my @nameyears = ($firstyear,);
    my @names     = ($name,); 
    for my $match ($rest =~ m!Originally known as ([^\n]*?)\n!g) { @names = ($1,); }
    for my $match ($rest =~ m!Name changed to ([^\n]*)\n!mg)     { 
	$match =~ m!([^\n]*) in (\d+)!; 
	push @names, $1; push @nameyears, $2; 
    }

    my %parks = ();
    #                          <A href="../1871/Y_1871.htm">1871</A> <A href="../1871/TWS301871.htm">OLY n</A> <A href="../1871/PKL_BAL011871.htm">LOG</A>     1    1    0   15    7     31   14   15  295  296   1.154
    for my $match ($rest =~ m!(<A[^>]+>[^<]+</A> <A href="../\d+/T\w{3}\d\d+\.htm">[\w ]{3} \w</A> <A href="../\d+/PKL_\w{3}\d+\.htm">LOG)!mg) {
	$match =~        m!<A[^>]+>[^<]+</A> <A href="../(\d+)/T(\w{3})(\d)\d+\.htm">([\w ]{3}) (\w)</A> <A href="../\d+/PKL_(\w{5})\d+\.htm">LOG!;
	($year, $team, $foo, $franch, $lg, $parkID) = ($1,$2,$3,$4,$5,$6);
	$parks{$franch.'_'.$team.'_'.$lg} = [$franch, $team, $lg, $foo];
	$parkyears{$franch.'_'.$team.'_'.$lg}{$year}++;
    }
    # take last year seen as end of name intervals
    push @nameyears, $year+1;

    my $fmt = "%-6s\t%-3d\t%4s\t%-4d\t%-38s\t%-5s\t%-22s\t%-7s\t%-6s\t%-5s"; # \t%-5s\t%-5s\t%-10s\n";
    #printf $fmt,  qw{siteID Name City State	Fr Team Lg beg  end dur};

    $xmlpark = $xmlparks->{Sites}{$parkID};

    # # check if names agree
    $okname = 0; for $name (@names) { last if ($okname = ($name eq $xmlpark->{name})); }

    for my $franchteamyear (sort keys %parks) {
	(my ($franch, $team, $lg, $foo)) = @{$parks{$franchteamyear}};
	my @years = (sort {$a <=> $b} keys %{$parkyears{$franchteamyear}});
	my $beg = $years[0];
	my $end = $years[-1];

	# print each site-team-sitename combo
	for $i (0..$#names) {
	    my ($name, $begnameyear, $endnameyear) = ($names[$i], $nameyears[$i], $nameyears[$i+1]-1);
	    $begnameyear = ($beg > $begnameyear ? $beg : $begnameyear);
	    $endnameyear = ($end < $endnameyear ? $end : $endnameyear);
	    next if ($endnameyear < $begnameyear);

	    my $tenure = (1 + $endnameyear - $begnameyear);

	    # print STDERR "Bad City $parkID\n"   if ( ($city ne $xmlpark->{city}) || ($state ne $xmlpark->{state}) );
	    # print STDERR "Bad league $parkID\n" if ( $lghash{$lg} ne $xmlpark->{leagueID} );
	    # printf STDERR "%5s\t%-4s\t%-19s%2s\t%2s\t%-39s\t%-39s\t%-10s\t%-10s\t%s\n", $parkID, $team,
	    #               "$city,", $state, $lghash{$lg}, $name, $xmlpark->{name}, 
	    #                $xmlpark->{start}, $xmlpark->{end}, $xmlpark->{aka} unless $okname;

	    printf "%5s\t%s", $parkID, $team;
	    printf "\t%-36s", $name;
	    printf "\t%-19s%2s", "$city,", $state;
	    printf " %2s", $lghash{$lg};
	    printf "\t%-4d %-4d %-10s %-10s", $begnameyear, $endnameyear, $xmlpark->{start}, $xmlpark->{end}; #, $tenure
	    printf "\t%-50s %s", $xmlpark->{aka}, $xmlpark->{comment};

	    print "\n";
	}
    }
}




CREATE TABLE `Parks`		(
`parkID`	CHAR( 7 ) NOT NULL ,
`currname`	CHAR( 50 ) NULL ,
`city`		CHAR( 25 ) NULL ,
`city_pc`	CHAR( 25 ) NULL ,
`state`		CHAR( 5 ) NULL ,
`state_pc`	CHAR( 5 ) NULL ,
`beg_bdb`	CHAR( 12 ) NULL ,
`beg_pc`	CHAR( 12 ) NULL ,
`beg_rsh`	CHAR( 12 ) NULL ,
`end_bdb`	CHAR( 12 ) NULL ,
`end_pc`	CHAR( 12 ) NULL ,
`end_rsh`	CHAR( 12 ) NULL ,
`url`		VARCHAR( 100 ) NULL ,
`href`		VARCHAR( 100 ) NULL ,
`lat`		DOUBLE NULL ,
`lng`		DOUBLE NULL ,
`leagueID`	CHAR( 8 ) NULL ,
`range`		VARCHAR( 10 ) NULL ,
`active`	CHAR( 2 ) NULL ,
PRIMARY KEY ( `parkID` ) ,
INDEX ( `currname` , `city` , `state` , `lat` , `lng` , `leagueID` )
) ENGINE = MYISAM ;
