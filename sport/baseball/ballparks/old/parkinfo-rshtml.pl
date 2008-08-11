#!/usr/bin/perl -w

# To get the files
# wget -erobots=off -r -l1 --no-clobber --relative --no-host-directories --cut-dirs=2 http://www.retrosheet.org/boxesetc/MISC/PKDIR.htm

# To run the script
# cat data/PK_*[0-9].htm | ./parkinfo-fromrshtml.pl
# This should convince you we're handling all the available information:
# cat data/PK_*[0-9].htm | \
#    grep -Pv '^(<A href="../\d+/(PKL_\w+|Y_\d+)\.htm|Year Team\s+|<PRE>Originally known|Name changed to|</?(H1|HTML|HEAD|BODY|!DOCTYPE|TITLE>)|(</?PRE\s*>)+\s+-+\s+This Park)' | \
#    sort -u |more


use Data::Dumper; $Data::Dumper::Sortkeys = 1;
use XML::Simple qw(:strict);
use strict;

my %lghash = qw{A AL N NL n NA a AA U UA P PL F FL};

# Snarf park file 
local $/ = undef;
my @files = split /<HTML/, join "",<>;
my %parks = ();

for $_ (@files) {
    my ($name, $city, $state, $rest, $year, $team, $foo, $franch, $lg, $parkID, $firstyear);

    # info in header
    ($name, $city, $state, $rest) = m!<TITLE>.*</TITLE>.*<H1>(.*) in (.*), (.*)</H1>(.*)!s or next;
    $city      =~ s/^St. /Saint /;
    $state     =~ s/Japan/JAP/i;
    $rest      =~ m!<A href="../(\d{4})/!; #";
    $firstyear = $1; 

    # names this park has had
    my @nameyears = ($firstyear,);
    my @names     = ($name,); 
    for my $match ($rest =~ m!Originally known as ([^\n]*?)\n!g) { @names = ($1,); }
    for my $match ($rest =~ m!Name changed to ([^\n]*)\n!mg)     { 
	$match =~ m!([^\n]*) in (\d+)!; 
	push @names, $1; push @nameyears, $2; 
    }

    # teams that played in this park.
    my %parkteams = (); my %parkyears = ();
    for my $match ($rest =~ m!(<A[^>]+>[^<]+</A> <A href="../\d+/T\w{3}\d\d+\.htm">[\w ]{3} \w</A> <A href="../\d+/PKL_\w{3}\d+\.htm">LOG)!mg) {
	$match =~        m!<A[^>]+>[^<]+</A> <A href="../(\d+)/T(\w{3})(\d)\d+\.htm">([\w ]{3}) (\w)</A> <A href="../\d+/PKL_(\w{5})\d+\.htm">LOG!;
	($year, $team, $foo, $franch, $lg, $parkID) = ($1,$2,$3,$4,$5,$6);
	$parkteams{$franch.'_'.$team.'_'.$lg} = [$franch, $team, $lg, $foo];
	$parkyears{$franch.'_'.$team.'_'.$lg}{$year}++;
    }

    # next unless ($parkID);

    # basic park info
    $parks{park}{$parkID}->{currname}  = $names[-1];
    $parks{park}{$parkID}->{city}      = $city;
    $parks{park}{$parkID}->{state}     = $state;
    $parks{park}{$parkID}->{beg}       = $firstyear;
    # take last year seen as end of name intervals
    push @nameyears, $year+1;
    $parks{park}{$parkID}->{end}       = $year;

    # record of teams
    $parks{park}{$parkID}->{team} = [];
    for my $franchteamlg (sort keys %parkteams) {
	(my ($franch, $team, $lg, $foo)) = @{$parkteams{$franchteamlg}};
	my @years = (sort {$a <=> $b} keys %{$parkyears{$franchteamlg}});
	my $beg = $years[0];
	my $end = $years[-1];
	#my $tenure = (1 + $endnameyear - $begnameyear);
	push @{$parks{park}{$parkID}->{team}}, {franch => $franch, team => $team, lg =>  $lghash{$lg}, beg => $beg, end=>$end}
    }

    # record of names
    $parks{park}{$parkID}->{name} = [];
    for my $i (0..$#names) {
	my ($name, $begnameyear, $endnameyear) = ($names[$i], $nameyears[$i], $nameyears[$i+1]-1);
	push @{$parks{park}{$parkID}->{name}}, {name => $name, beg => $begnameyear, end=>$endnameyear}
    }

    # These parks have non-unique names
    # grep -P "currname=\"(Athletic|Columbia|League Park|Oakdale|Recreation|Union Grounds|Wrigley)" parkinfo-fromrshtml.xml
    # Athletic Park		KAN01 0	MIN01 0	WAS04 0
    # Columbia Park		ALT01 0	PHI10 0
    # League Park *		TOL01 0	CLE02 1	CIN04 0	CLE03 1	CIN05 0	CLE05 1	CLE06 1	
    # Oakdale Park		JER01 0	PHI03 0	
    # Recreation Park *   	DET01 0	PHI04 0	PIT04 0	COL01 0	COL02 0	
    # Union Grounds		STL04 1	NYC01 0
    # Wrigley Field		CHI11 1	LOS02 0	
    # so let's fabricate one. 'push' to fix the canonical name, unshift to fix the 
    sub fix_dupe_name($$) { 
	(my ($canonical, $park))=@_; 
	my $namerec = $park->{name}->[-1];
	$namerec->{name} =~ m/^(.*?)( (?:I|II|III|IV|V|VI))?$/; 
	my $newname    = sprintf("%s (%s)%s", $1, $park->{city}, $2||'');
	my $newnamerec = { name => $newname, beg => $namerec->{beg}, end=>$namerec->{end} };
	if ($canonical) { unshift @{$park->{name}}, $newnamerec; }
	else            { push    @{$park->{name}}, $newnamerec; $park->{currname} = $newname}
    }
    my %dupenames = qw{
	KAN01 0	MIN01 0	WAS04 0		
	ALT01 0	PHI10 0
	CLE02 1	CLE03 1	CLE05 1	CLE06 1	TOL01 0	CIN04 0	CIN05 0				
	JER01 0	PHI03 0				
	DET01 0	PHI04 0	PIT04 0	COL01 0	COL02 0				
	STL04 1	NYC01 0			
	CHI11 1	LOS02 0				
    };
    if (exists $dupenames{$parkID}) {
	fix_dupe_name($dupenames{$parkID}, $parks{park}{$parkID});
    }
}

my $xmlw = XML::Simple->new(OutputFile => 'parkinfo-fromrshtml.xml', 
	      RootName => 'parks_rshtml', KeyAttr => 'parkID');
$xmlw->XMLout(\%parks, KeyAttr => 'parkID');
