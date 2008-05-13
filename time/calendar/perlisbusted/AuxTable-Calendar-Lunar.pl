#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
# use Text::CSV_XS;
use IO::File;

use DateTime;
use DateTime::Format::Epoch;

use DateTime::Util::Calc qw(
    min max search_next moment dt_from_moment mod binary_search
);

# ===========================================================================
#
# References:
#
#  -- http://search.cpan.org/dist/DateTime-Event-Lunar/
#  -- http://search.cpan.org/dist/DateTime-Util-Astro/
#  -- http://scienceworld.wolfram.com/astronomy/Lunation.html and linked pages
#
# ===========================================================================


# ===========================================================================
#
#  Lunar Calendar
#
# 
# ===========================================================================

use lib '.';
use DateTime::Event::Lunar 	qw(:phases);  
use DateTime::Util::Astro::Moon	qw(nth_new_moon lunar_phase lunar_longitude MEAN_SYNODIC_MONTH);

sub print_lunarinfo() {
    my $lunarmonth_secs = MEAN_SYNODIC_MONTH*24*60*60;
    printf "Mean Synodic Month: %s days, %11.6f seconds.  Phase Tolerance %s\n", 
    	MEAN_SYNODIC_MONTH, $lunarmonth_secs, DateTime::Event::Lunar->LUNAR_PHASE_DELTA;

}

# ===========================================================================
#
# Find exact quarters for each Lunar month. 
#  -- Because of the high-precision math, these calculations run /very/
#     slowly.
#     Expect this to take about 6s per lunar cycle.  Really.
#
# ===========================================================================
sub make_lunar(@) {
    (my ($begmoon_idx, $endmoon_idx)) = @_;
    
    # Our four phases
    my @phases = map { 
	[
	 ('New Moon', 'First Quarter (Waxing Half Moon)', 'Full Moon', 'Last Quarter (Waning Half Moon)')[$_],
	 (NEW_MOON, FIRST_QUARTER, FULL_MOON, LAST_QUARTER)[$_],
	 $_
	]} (0..3);
    # junk: ( 0 + ($_ * Math::BigInt->bone()/4)) * 24*60*60,
    # junk: New moon of 2003/12/23 is Lunation ::Lunar #24773 and Mathematica #1002  -> 23771
    
    my @moonidxs = ($begmoon_idx..$endmoon_idx);
    # Seed the date of the previous new moon
    my $last_month = &datetosecs(DateTime::Event::Lunar->new_moon_before(datetime => &nth_new_moon($moonidxs[0]), on_or_after => 1));
    # Dump a header
    printf "%-19s,%-5s, %-8s, ".("%-19s,%-14s,%-10s,%-6s, "x4)."\n", 
    	qw{estdt LunNum MoLen 
		m0date   m0RataDie   m0Ph   m0mofr 
		m90date  m90RataDie  m90Ph  m90mofr 
		m180date m180RataDie m180Ph m180mofr 
		m270date m270RataDie m270Ph m270mofr 
		};
    for my $newmoon_idx (@moonidxs) {
	# Get an estimate of the new moon's day.
	my $newmoon      = &nth_new_moon($newmoon_idx) - DateTime::Duration->new(days=>1); my $newmoon_secs;
	# Then get the exact (well, to ~10^-5 degrees of phase) time that moon appears
 	for my $phase (@phases) {
	    (my ($name, $phasedegs, $idx)) = @$phase; 
 	    my $moon = DateTime::Event::Lunar->lunar_phase_after(datetime => $newmoon, phase => $phasedegs, on_or_after => 1);
	    if ($idx == 0) { 
		# record the new moon
		$newmoon_secs = &datetosecs($moon);
		printf "%5d, %8.6f, ", 
			$newmoon_idx, 	 	 	 	 	 	 	# The index of this lunation (new moon)
			($newmoon_secs-$last_month)/(24*60*60); 	 	 	# Length of this synodic lunar month
	    }
	    printf "%-19s,%14s,%10.5f,%6.4f, ", 
	    	$moon, 									# Date
	    	&datetosecs($moon), 						        # Rata Die seconds	
	    	mod(&lunar_phase($moon)+180,360)-180, 					# Actual resultant lunar phase
	    	(&datetosecs($moon)-$newmoon_secs) / ($newmoon_secs-$last_month);	# Fraction of the actual synodic month to this moon
	}
	print "\n";
	$last_month = $newmoon_secs;
    }
}



# ===========================================================================
#
#  Some utility functions
#
# ===========================================================================

# KLUDGE -- Global variables
use vars qw{$rataDie_0 $rataDieSecsNoLeap};
$rataDie_0           = DateTime->new(year=>0, month=>12, day=>31, time_zone=>'UTC');
# note that this is different than the utc_rd_as_seconds, which skips leap seconds
$rataDieSecsNoLeap = DateTime::Format::Epoch->new(
    epoch=> $rataDie_0,     unit =>'seconds', type => 'bigint', 
    skip_leap_seconds => 1, start_at => 0,    local_epoch => undef, );
sub secstodate($) { return $rataDieSecsNoLeap->parse_datetime ($_[0]); }
sub datetosecs($) { return $rataDieSecsNoLeap->format_datetime($_[0]); }

sub estimate_moon_idx($) {
    my $date       = shift;
    my $rataDieSecs = &datetosecs($date);

    # rataDieSecs -> (-1.4872477209978674`*^11) + (29.53058867        ) n1
    # n1          -> (5.036295542962732*^9)     + (0.03386319220300189) rataDieSecs
    return (5036295542.962732 + (0.03386319220300189 * $rataDieSecs));
}

# ===========================================================================
#
#  Setup
#
# ===========================================================================
use English;
sub dumpusage() {
    warn ("Usage:
  $EXECUTABLE_NAME [start new moon index] [end new moon index]
where a new moon index is counted from lunation #1 on January 11, 1 (Gregorian) (see http://search.cpan.org/dist/DateTime-Util-Astro-Moon/)
-or- 
  $EXECUTABLE_NAME [start date] [end date]
where dates are pretty flexible; the timezone will default to UTC if you're being all precise and stuff.");
    exit(1);
} 

#use DateTime::Format::DateParse;
use DateTime::Format::DateManip;
sub parseargs(@) {
    my @idxs;
    if    (scalar @_ != 2) {
	dumpusage();
    }
    for my $i (0,1) {
	my $arg = $_[$i];
	if ($arg =~ /^[\-\+]?\d+$/) {
	    $idxs[$i] = $arg;
	}
	else {
	    my $date = DateTime::Format::DateManip->parse_datetime($arg);
	    print STDERR "Generating moon phases ".(('beginning','ending')[$i])." at $date.\n"; 
	    # my $enddate = DateTime::Format::DateParse->parse_datetime( $arg2, 'UTC' );
	    
	    $idxs[$i] = &estimate_moon_idx($date);

use DateTime::Format::Epoch::JD;
	    my $d = DateTime::Format::Epoch::JD->new()->format_datetime($date);

	    printf "%s %s\n", &datetosecs($date), $d;
	}
    }
    printf "b: %s e:%s\n", @idxs;
    return \@idxs;
}


&parseargs(@ARGV);
exit(0);
make_lunar(${&parseargs(@ARGV)});
