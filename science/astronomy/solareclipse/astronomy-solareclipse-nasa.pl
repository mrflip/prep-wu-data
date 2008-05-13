#!/usr/bin/perl -w

use strict;

use DateTime;
use DateTime::LeapSecond;
use DateTime::Format::Epoch;
use DateTime::Format::Epoch::MJD;
use DateTime::Calendar::Julian;
#
# This just munges it into csv and adds the MJD
#
# Usage: 
# cat SE[0-9\-]*.html | astronomy-solareclipse-nasa.pl  | sort -n > \
#    astronomy-solareclipse-nasa.csv

my %monthnames = qw{Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 9 Oct 10 Nov 11 Dec 12};

sub fixdms($) {
    my $dms = shift;
    #(my ($dd, $dm, $ds, $dir)) = ($dms =~ m/([\+\-])?\s*(\d+)\.(\d+)([nsew])/i);
    # north is plus, east is plus
    # $sg * ($dd + ($dm + ($ds/60))/60)

    (my ($deg, $dir)) = ($dms =~ m/([\s\d\+\-\.]+)([nsew])$/i);
    # printf STDERR "$deg $dir $dms\n";
    my $sg = (($dir =~ /[sw]/i) ? -1 : 1);
    return sprintf "%7.1f", ($sg * $deg);
}

#                                          C m  g  j m d t  d l s e g  e l l s s p c
#                                         {5 27 20 5 3 2 10 7 7 5 4 10 8 7 7 4 4 5 4};
my $fmt = join ',', map { "%-".$_."s" } qw{5 26 20 5 3 2 8  7 5 5 4 10 8 7 7 4 4 5 4};
printf "$fmt\n", map { "\"$_\"" } 
    qw{cat MJD GregDate JGY M D TD deltaT Lun Sar ETy Gamma EclMag Lat Lng SA SAz PW CtlDur};

while (<>) {
    if (m!<a href="../5MCSEmap/[\+\-]?\d{4}--?\d{4}/[\+\-]?\d+-\d+-\d+.gif">!) {
	s![\r\n]+$!!; #chomp
	s!</?a[^>]*>!!ig;
	s/(  *)/,$1/g;
	my @fields = split ',', $_;

	# extract the MJD
	(my ($catno, $yr,$mo,$dy)) = map { $_ =~ s/\s//g; $_ } (@fields[0..3]);
	(my ($hr,$min,$sec)) = split ':',$fields[4];
	# printf "%s - %s - %s - %s - %s - %s\n", $yr,$mo,$dy,$hr,$min,$sec;
	my $dt;
	if (($yr < 1582) ||
	    (($yr == 1582) && ($monthnames{$mo} <= 10)) ||
	    (($yr == 1582) && ($monthnames{$mo} == 10) && ($dy < 15))) {
	    $dt  = DateTime::Calendar::Julian->new(
		year=>$yr, month=>$monthnames{$mo}, day=>$dy, 
		hour=>$hr, minute=>$min, second=>$sec,
		time_zone=>'UTC');
	    $dt = DateTime->from_object( object => $dt );
	} else {
	    $dt  = DateTime->new(
		year=>$yr, month=>$monthnames{$mo}, day=>$dy, 
		hour=>$hr, minute=>$min, second=>$sec,
		time_zone=>'UTC');
	}
	my $mjd = DateTime::Format::Epoch::MJD->new();
	$fields[0] = sprintf "%05d, %2.17f,%s", 
		$catno, $mjd->format_datetime($dt), $dt;

	#fix the lat-lng
	@fields[11..12]  = map { &fixdms($_) } @fields[11..12];

	if (($#fields >=16) && 
	    ((my ($cdm, $cds)) = ($fields[16] =~ m/(\d+)m(\d+)s/))) {
	    $fields[16] = ($cdm*60 + $cds);
	}
	$fields[15] = '     ' if (!defined $fields[16]);
	$fields[16] = '     ' if (!defined $fields[16]);

	# (my ($lat,$lng))= 
	printf  "%s\n", (join ',',@fields);
	
    }
}







