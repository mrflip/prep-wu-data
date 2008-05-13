#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
# use Text::CSV_XS;
use IO::File;

use DateTime;
use DateTime::TimeZone;
use DateTime::TimeZoneCatalog;
use DateTime::LeapSecond;
use DateTime::Span;
use DateTime::Set;
use DateTime::SpanSet;
use DateTime::Format::Epoch;
use DateTime::Format::Epoch::ActiveDirectory;
use DateTime::Format::Epoch::DotNet;
use DateTime::Format::Epoch::MJD;
use DateTime::Format::Epoch::MacOS;
use DateTime::Format::Epoch::RataDie;
use DateTime::Format::Epoch::TAI64;
use DateTime::Format::Epoch::Unix;

use DateTime::Util::Calc qw(
    min max search_next moment dt_from_moment mod binary_search
);
# ===========================================================================
#
# References:
#
# - http://www.twinsun.com/tz/tz-link.htm
# - http://datetime.perl.org/
# - http://cr.yp.to/libtai/tai64.html
# - http://en.wikipedia.org/wiki/Full_moon_cycle
#
# ===========================================================================

# ===========================================================================
#
# Plan:
#  -- date, tai, jd, 


# ===========================================================================
#
#  Length of time to look at
#
# ===========================================================================

use vars qw{$begyear $endyear};
$begyear = 0;
$endyear = 10000;
my $begcal = DateTime->new(year=>2006,   month=>1, day=>1, time_zone=>'UTC');
my $endcal = DateTime->new(year=>2006+1, month=>1, day=>1, time_zone=>'UTC');
$endcal = $endcal->subtract( nanoseconds => 1 );

#
# 
#

# my $caldays  = DateTime::Set->from_recurrence( 
#         recurrence => sub {
#             return $_[0] if $_[0]->is_infinite;
#             return $_[0]->truncate( to => 'day' )->add( days => 1 )
#         },
# 	start => $begcal, before => $endcal ,
#         #span => DateTime::Span->from_datetimes(start => $begcal, before => $endcal ),
#     );
# my $daysiter;
# $daysiter = $caldays->iterator;
# while ( my $dt = $daysiter->next ) {
# }


my @caldays;
my $oneday = DateTime::Duration->new( days =>1 );
for (my $day=$begcal->clone();
     DateTime->compare($day, $endcal)<0;
     $day->add_duration($oneday)) {
    push @caldays, $day->clone;
}

# ===========================================================================
#
#  Give the value for many popular epoch at the start of each month
#
# ===========================================================================

use vars qw{ %epochs @epochtags %epochtagfmts };

#
# Define epochs
# 
sub make_epochs() {
    @epochtags = ( 
	'ModJulnDay_d',       	# number of days          since 1858-11-17T00:00:00 in UTC
	'rataDie_d',         	# number of days          since 0000-12-31T00:00:00                    
	'rataDie_s',         	# number of seconds       since 0000-12-31T00:00:00
	'tai64_s',           	# for 2^62 < s < 2^63, the second beginning exactly s - 2^62 seconds after 1970 TAI; for s < 2^62, the second beginning 2^62 - s seconds before 1970 TAI.  That was confusing.  Go read: http://cr.yp.to/libtai/tai64.html
	'unix_s',           	# number of seconds       since 1970-01-01T00:00:00    
	'activeDirectory_s',	# number of 10^-7 seconds since 1601-01-01T00:00:00  
	'dotNet_s',      	    	# number of microseconds  since 0001-01-01T00:00:00     
	'macOSClassic_s',   	# number of seconds       since 1904-01-01T00:00:00
	);
    @epochtagfmts{@epochtags} = qw{ 15s 15s 15s 21s 15s 21s 21s 15s };
    my $rataDie_0   = DateTime->new(year=>0, month=>12, day=>31, time_zone=>'UTC');
    my $rataDie_s = DateTime::Format::Epoch->new(epoch=> $rataDie_0, unit =>'seconds', type => 'bigint', skip_leap_seconds => 1, start_at => 0, local_epoch => undef, );
     @epochs{@epochtags} = (
 	DateTime::Format::Epoch::MJD->new(),
 	DateTime::Format::Epoch::RataDie->new(),
 	$rataDie_s,
	# DateTime::Format::Epoch::TAI64->new(),
 	DateTime::Format::Epoch::Unix->new(),
 	DateTime::Format::Epoch::ActiveDirectory->new(),
 	DateTime::Format::Epoch::DotNet->new(),
 	DateTime::Format::Epoch::MacOS->new(),
 	);
}


sub dump_epochs($) {
    my $caldays = shift;
    # make a flat printf string and dump them.
    my $fmt = join ' ',map { "$_=%-$epochtagfmts{$_}" } @epochtags;
    for my $day (@$caldays) {
	printf "date=%18s %s, $fmt\n", '"'.$day.'"', $day->leap_seconds, (map { '"'.($_->format_datetime($day)).'"' } @epochs{@epochtags});
    }
}


# ===========================================================================
#
#  Laandmarks: year 0s, wraparounds, 9999's, etc
#
# ===========================================================================


use vars qw{ %landmarks };
use DateTime::Format::Epoch::JD;
sub make_landmarks() {

    # Add the epoch start dates to the days computed.
    map { $landmarks{"Start of $_ epoch"} = $epochs{$_}->parse_datetime(0) } (grep { !/tai64_s|rataDie_s/ } @epochtags); 

    # Add julian day 0.
    $landmarks{"Start of Julian Day epoch"} = DateTime::Format::Epoch::JD->new()->parse_datetime(0);

    # Add the wraparound moments for the 32-bit epochs
    my @overflowers = ( -(2**32+1), -(2**32), -(2**31), (2**31-1), (2**31), (2**32-1),  (2**32), );  
    for my $secs (@overflowers) { 
	$landmarks{sprintf "MacOS Classic hits value %s", $secs} = $epochs{macOSClassic_s}->parse_datetime($secs);
    }
    for my $secs (@overflowers, 2**31) { 
	$landmarks{sprintf "Unix 32-bit time_t hits value %s", $secs} = $epochs{unix_s}->parse_datetime($secs);
    }

    # -9999-00-00 00:00:00   *	Shaped like a date, but isn't.
    # -9999-01-01 00:00:00   *	Shaped like a date, but isn't.
    #  0000-00-00 00:00:00   *	Shaped like a date, but isn't.
    #  0000-01-01 00:00:00   *	Shaped like a date, but isn't.
    #  9999-12-31 99:99:99   *	Shaped like a date, but isn't.
    #  9999-99-99 99:99:99   *	Shaped like a date, but isn't.

    #  1000-01-01 00:00:00	mySQL day 1: mySQL says this is the earliest date it supports, though it appears to recognize dates from Gregorian 200 on
    #   200-01-01 00:00:00	mySQL day 1: mySQL appears to recognize dates from Gregorian 200 on, though it says 1000-01-01 is the earliest date it supports
    #  1901-01-01 00:00:00	mySQL earliest value of YEAR type
    #  2055-01-01 00:00:00	mySQL latest value of YEAR type
    #  2055-12-31 23:59:59	mySQL latest value of YEAR type
    #  9999-12-31 00:00:00 	mySQL doomsday: largest mySQL year (first day of year)
    #  9999-12-31 23:59:59   	mySQL doomsday: largest mySQL year (last day of year).  Often used as an 'infinity' date

    # Add the day before each mar. 1st and the day after every feb. 29th.
#     for my $year (($begyear/4)..($endyear/4)) {
# 	$year *= 4;
# 	my $feb28   = DateTime->new(year=>$year, month=>2, day=>28, time_zone=>'UTC');
# 	# Years ending in 100 can trip up some naive leap-year finding tools
# 	if ( ($year%4 == 0) && ($year%100 == 0) ) {
# 	    if ($feb28->is_leap_year) {
# 		$landmarks{sprintf "Year %s *is* a leap year. (Feb 28)", $year} = DateTime->new(year=>$year, month=>2, day=>28, time_zone=>'UTC');
# 		$landmarks{sprintf "Year %s *is* a leap year. (Feb 29)", $year} = DateTime->new(year=>$year, month=>2, day=>29, time_zone=>'UTC');
# 		$landmarks{sprintf "Year %s *is* a leap year. (Mar  1)", $year} = DateTime->new(year=>$year, month=>3, day=>1,  time_zone=>'UTC');
# 	    } else {
# 		$landmarks{sprintf "Year %s *is not* a leap year. (Feb 28)", $year} = DateTime->new(year=>$year, month=>2, day=>28, time_zone=>'UTC');
# 		$landmarks{sprintf "Year %s *is not* a leap year. (Mar  1)", $year} = DateTime->new(year=>$year, month=>3, day=>1,  time_zone=>'UTC');
# 	    }
# 	}
# 	# my $dayafterfeb28   = DateTime->new(year=>$year, month=>2, day=>28, time_zone=>'UTC')->add(      days => 1 );
# 	# my $daybeforemar01  = DateTime->new(year=>$year, month=>3, day=>1,  time_zone=>'UTC')->subtract( days => 1 ); 
# 	# my $isleapyear_hard = (DateTime->compare_ignore_floating($dayafterfeb28, $daybeforemar01) == 0);
# 	# my $isleapyear_ym4g = ;
# 	#     
# 	# printf "%4d %s %s %0d %0d %0d %0d %s\n", $year, $dayafterfeb28, $daybeforemar01, 
# 	# 	$isleapyear_hard, $isleapyear_easy, $isleapyear_ym4, $isleapyear_ym4g, 
# 	# 	( ($isleapyear_hard==$isleapyear_easy) && ($isleapyear_hard==$isleapyear_ym4g) ? '' : '!!!!!!!!');
#     }

    # Add all the leap seconds

    %landmarks = ();
    my $foo;
    print $DateTime::VERSION;

    my $ls_idx = 0;
    for my $year (1972..$endyear) {
	my $sec_before = DateTime->new(year=>$year, month=>6, day=>30, hour=>23, minute=>59, second=>59, time_zone=>'UTC');
	my $sec_after  = DateTime->new(year=>$year, month=>7, day=>1,  hour=>0,  minute=>0,  second=>0,  time_zone=>'UTC');
	my $ls_delta   = ($sec_after->leap_seconds - $sec_before->leap_seconds);
	if ($ls_delta) {
	    my $ls_tai  = $epochs{tai64_s}->format_datetime($sec_before) + 1;
	    my $tag = sprintf "Leap second #%s happened just before %s %s as TAI second %s: %s", 
		$ls_idx+1, $sec_after->month_abbr, $year, $ls_tai, $sec_before;
	    printf "$tag\n";
	    # my $sec_of  = DateTime->new(year=>$year, month=>6, day=>30,  hour=>23,  minute=>59,  second=>60,  time_zone=>'UTC');
	    $landmarks{$tag . " Just before transition:"} = $sec_before;
	    # $landmarks{$tag . " Leap Second:"}            = $sec_of;
	    $landmarks{$tag . " Just after  transition:"} = $sec_after;
	    $ls_idx++;
	}
	
	$sec_before = DateTime->new(year=>$year,   month=>12, day=>31, hour=>23, minute=>59, second=>59, time_zone=>'UTC');
	$sec_after  = DateTime->new(year=>$year+1, month=>1,  day=>1,  hour=>0,  minute=>0,  second=>0,  time_zone=>'UTC');
	$ls_delta   = ($sec_after->leap_seconds - $sec_before->leap_seconds);
	if ($ls_delta) {
	    my $ls_tai  = $epochs{tai64_s}->format_datetime($sec_before) + 1;
	    my $tag = sprintf "Leap second #%s happened just before %s %s as TAI second %s: %s", 
		$ls_idx+1, $sec_after->month_abbr, $year+1, $ls_tai, $sec_before;
	    printf "$tag\n";
	    my $sec_of  = DateTime->new(year=>$year, month=>12, day=>31,  hour=>23,  minute=>59,  second=>60,  time_zone=>'UTC');
	    $sec_of  = $epochs{tai64_s}->parse_datetime($ls_tai);
	    $landmarks{$tag . " Just before transition:"} = $sec_before;
	    $landmarks{$tag . " Leap Second:"}            = $sec_of;
	    $landmarks{$tag . " Just after  transition:"} = $sec_after;
	    $ls_idx++;
	}
    }
#     for my $ls_idx (0..$#DateTime::LeapSecond::RD) {
#	my $ls_day   = $DateTime::LeapSecond::RD[$ls_id];
# 	# take the ratadie_day and turn it into tai seconds.
# 	my $ls_secs  = &( $epochs{rataDie_d}->parse_datetime($ls_day) );
# 	# take that and the two preceding seconds -- that's 59:59, 59:60 and 00:00 
# 	my @ls_dates = map { &( $ls_secs + $_ ) } (-2, -1, 0);
# 	(my ($ls_mo, $ls_yr)) = ($ls_dates[1]->month_abbr, $ls_dates[1]->year);
# 	@landmarks{(0,1,2)} = @ls_dates;
# 	printf "Leap second #%s happened in %s %s at Rata Die day %s: %s\n", $ls_idx+1, $ls_mo, $ls_yr, $ls_tai, $ls_dates[0];
# 	printf "Leap second #%s happened in %s %s at Rata Die day %s: %s\n", $ls_idx+1, $ls_mo, $ls_yr, $ls_tai, $ls_dates[1];
# 	printf "Leap second #%s happened in %s %s at Rata Die day %s: %s\n", $ls_idx+1, $ls_mo, $ls_yr, $ls_tai, $ls_dates[2];
#     }

    &dump_epochs([sort values %landmarks]);
}


# last friday of a month


# How can I calculate the last business day (payday!) of a month?

# Start from the end of the month and then work backwards until we reach a weekday.

# my $dt = DateTime->last_day_of_month( year => 2003, month => 8 );

# # day 6 is Saturday, day 7 is Sunday
# while ( $dt->day_of_week >= 6 ) { $dt->subtract( days => 1 ) }

# print "Payday is ", $dt->ymd, "\n";




# ===========================================================================
#
#  Lunar Calendar
#
# Expect this to take about 6s per lunar cycle.  Really.
# 
# ===========================================================================

use lib '.';
use Lunar11665 	qw(:phases);  
use DateTime::Util::Astro::Moon	qw(nth_new_moon lunar_phase lunar_longitude MEAN_SYNODIC_MONTH);

sub lunar_phase_after() { &DateTime::Event::Lunar1165->lunar_phase_after(@_); }

sub make_lunar() {
    # Because of the high-precision math, these calculations run /very/
    # slowly, so we're going to reach in and hint the lunar calculations
    # heavily.
    
    my $lunarmonth_secs = MEAN_SYNODIC_MONTH*24*60*60;
    printf "Mean Synodic Month: %s days, %11.6f seconds.  Phase Tolerance %s\n", 
    	MEAN_SYNODIC_MONTH, $lunarmonth_secs, Lunar11665->LUNAR_PHASE_DELTA;

    # find three points during the month just before a phase, to 
    my @phases = map { 
	[
	 ('New Moon', 'First Quarter (Waxing Half Moon)', 'Full Moon', 'Last Quarter (Waning Half Moon)')[$_],
	 (NEW_MOON, FIRST_QUARTER, FULL_MOON, LAST_QUARTER)[$_],
	 ( 0 + ($_ * Math::BigInt->bone()/4)) * 24*60*60,
	 $_
	]} (0..3);

    # Find exact quarters for each Lunar month. New moon of 2003/12/23 is Lunation ::Lunar #24773 and Mathematica #1002  -> 23771
    my @moonidxs = (0..50000);
    # Seed the date of the previous new moon
    my $last_month = &datetosecs(Lunar11665->new_moon_before(datetime => &nth_new_moon($moonidxs[0]), on_or_after => 1));
    printf "%-19s,%-5s, %-8s, ".("%-19s,%-14s,%-10s,%-6s, "x4)."\n", 
    	qw{estdt LunNum MoLen 
		m0date   m0RataDie   m0Ph   m0mofr 
		m90date  m90RataDie  m90Ph  m90mofr 
		m180date m180RataDie m180Ph m180mofr 
		m270date m270RataDie m270Ph m270mofr 
		};
    for my $newmoon_idx (@moonidxs) {
	# Day the new moon falls on
	my $newmoon      = &nth_new_moon($newmoon_idx) - DateTime::Duration->new(days=>1); my $newmoon_secs;
	printf "%-19s,", $newmoon;
 	for my $phase (@phases) {
	    (my ($name, $phasedegs, $qtrpt, $idx)) = @$phase; 
 	    my $moon = Lunar11665->lunar_phase_after(datetime => $newmoon, phase    => $phasedegs, on_or_after => 1);
	    if ($idx == 0) { # record the new moon
		$newmoon_secs = &datetosecs($moon);
		printf "%5d, %8.6f, ", $newmoon_idx, ($newmoon_secs-$last_month)/(24*60*60);
	    }
	    printf "%-19s,%14s,%10.5f,%6.4f, ", 
	    	$moon, &datetosecs($moon), 
	    	mod(&lunar_phase($moon)+180,360)-180, 
	    	(&datetosecs($moon)-$newmoon_secs) / ($newmoon_secs-$last_month);
	}
	print "\n";
	$last_month = $newmoon_secs;
    }

#     my $newmoon_days = &datetosecs(&nth_new_moon(0));
#     for my $day (600000..605000) {
# 	my $dt = $epochs{rataDie_d}->parse_datetime($day);
# 	printf "%s, %8.4f \n", $dt, &lunar_phase($dt);
#     }
}


# Math::BigRat
# bignum

# ===========================================================================
#
#  Alternate Calendars 
#
# ===========================================================================


# gregorian
# julian
# islamic
# chinese
# hebrew
# persian
# 
# moon
# fiscal
# astronomical
# Phases of the Moon 


# ===========================================================================
#
#  Holidays
#
# ===========================================================================

# DateTime::Event::Chinese->new_year_for_greogrian_year(%args)
# http://search.cpan.org/dist/DateTime-Event-Easter/lib/DateTime/Event/Easter.pm
                  
# US            Australian    Austrian      Brazilian     Canadian      China         
# Christian     Danish        Dutch         Finnish       French        German        
# Greek         Hong Kong     Indian        Indonesian    Irish         Islamic       
# Italian       Japanese      Jewish        Malaysia      Mexican       New Zealand   
# Norwegian     Philippines   Polish        Portuguese    Russian       Singapore     
# South Africa  South Korean  Spanish       Swedish       Taiwan        Thai          
# UK            Vietnamese    


# ===========================================================================
#
#  Dump all the time zone transitions
#
# ===========================================================================


# DST transition table
# DST offsets by day

sub make_tztransitions() {
    print Dumper([DateTime::TimeZone->all_names]);
    print Dumper([DateTime::TimeZone->categories]);
    print Dumper([DateTime::TimeZone->links]);
    my $tz  = DateTime::TimeZone->new( name => 'America/New_York' );

    # Time-consumingly push out TZ transitions until the year...
    $tz->_generate_spans_until_match($endcal->year, $endcal->utc_rd_as_seconds, '');
    my @spankeys = qw( utc_start utc_end local_start local_end offset is_dst tz3name );
    for my $span (@{$tz->{spans}}) {
	my $spanstart   = $epochs{rataDie_s}->parse_datetime($span->[0]);
	printf "%s %s %s\n", $spanstart, (join '-',@$span), $spanstart->utc_rd_as_seconds;
    }
}

# ===========================================================================
#
#  For each month from 1 to 2600, 
#
# ===========================================================================


# info on each day
# info on each month
# is_leap_year 
# week number
# day of year
# dst in time zones
# iso week date


# my $oneday = DateTime::Duration->new( days =>1 );
# for (my $date=$begcal;
#      DateTime->compare($date, $endcal)<0;
#      $date->add_duration($oneday)) {
#     printf "<day date=%-25s weekinyear="" dayinyear="" >\n"

# }


# ===========================================================================
#
#  For each day from 1850 to 2150 
#
# ===========================================================================


# ===========================================================================
#
#  Some utility functions
#
# ===========================================================================

use vars qw{$rataDie_0 $rataDieSecsNoLeap};
$rataDie_0           = DateTime->new(year=>0, month=>12, day=>31, time_zone=>'UTC');
# note that this is different than the utc_rd_as_seconds, which skips leap seconds
$rataDieSecsNoLeap = DateTime::Format::Epoch->new(
    epoch=> $rataDie_0,     unit =>'seconds', type => 'bigint', 
    skip_leap_seconds => 1, start_at => 0,    local_epoch => undef, );
sub secstodate($) { return $rataDieSecsNoLeap->parse_datetime ($_[0]); }
sub datetosecs($) { return $rataDieSecsNoLeap->format_datetime($_[0]); }


make_epochs();
# make_landmarks();
# make_lunar();
