#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;


use DateTime;
use DateTime::TimeZone;
use DateTime::TimeZoneCatalog
use DateTime::LeapSecond;
use DateTime::Format::Epoch;
use DateTime::Format::Epoch::ActiveDirectory;
use DateTime::Format::Epoch::DotNet;
use DateTime::Format::Epoch::JD;
use DateTime::Format::Epoch::MacOS;
use DateTime::Format::Epoch::RataDie;
use DateTime::Format::Epoch::TAI64;
use DateTime::Format::Epoch::Unix;

# References:
# - http://www.twinsun.com/tz/tz-link.htm
# - http://datetime.perl.org/
# - http://cr.yp.to/libtai/tai64.html




# ===========================================================================
#
#  Give the epoch landmark at the start of each month
#
# ===========================================================================


my @epochtags = qw{ year111_sec      activeDirectory_sec dotNet_sec   julianDay_day
                    macOSClassic_sec rataDie_day         tai64_sec    unix_sec };
my %epochs;
my $year111_t   = DateTime->new(year=>1, month=>1, day=>1, time_zone=>'UTC');
my $year111_sec = DateTime::Format::Epoch->new(epoch          => $dt,
	unit => 'seconds',   type => 'bigint', skip_leap_seconds => 1,
	start_at       => 0, local_epoch    => undef,   );
@epochs{@epochtags} = (
	 $year111_sec,
	 DateTime::Format::Epoch::ActiveDirectory->new(),
	 DateTime::Format::Epoch::DotNet->new(),
	 DateTime::Format::Epoch::MacOS->new(),
	 DateTime::Format::Epoch::TAI64->new(),
	 DateTime::Format::Epoch::Unix->new(),
	 DateTime::Format::Epoch::JD->new(),
	 DateTime::Format::Epoch::RataDie->new(),);





# ===========================================================================
#
#  Alternate Calendars 
#
# ===========================================================================




# ===========================================================================
#
#  Holidays
#
# ===========================================================================

# DateTime::Event::Chinese->new_year_for_greogrian_year(%args)
# http://search.cpan.org/dist/DateTime-Event-Easter/lib/DateTime/Event/Easter.pm



# ===========================================================================
#
#  Dump all the time zone transitions
#
# ===========================================================================

# print Dumper([DateTime::TimeZone->all_names]);
# print Dumper([DateTime::TimeZone->categories]);
# print Dumper([DateTime::TimeZone->links]);
# my $tz  = DateTime::TimeZone->new( name => 'America/New_York' );
# Time-consumingly push out TZ transitions until the year...
# $tz->_generate_spans_until_match(2500, 65000204800, 'EST');
# my @spankeys = qw( utc_start utc_end local_start local_end offset is_dst );
# for my $span (@{$tz->{spans}}) {
#     my $start = $span->[0];
#     my $utc   = $tzepoch->parse_datetime($start);
#     #$utc->{utc_rd_secs} = $start; $utc->{utc_rd_days} =3;
#     #$utc->_normalize_seconds();
#      #utc_rd_secs
#    printf "%s %s %s\n", $start,$tzepoch->parse_datetime($start), $utc->strftime("%a, %d %b %Y %H:%M:%S %z %s");
# }




# ===========================================================================
#
#  For each month from 1 to 2600, 
#
# ===========================================================================





# ===========================================================================
#
#  For each day from 1850 to 2150 
#
# ===========================================================================



# is_leap_year 
# week number
# day of year
# dst in time zones

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
#
# iso week date


Phases of the Moon 


	
# Help Calendar find additional events in your area.
# US zip code:   
# US Holidays
# US Holidays
# Add to Calendar
# Australian Holidays
# Australian Holidays
# Add to Calendar
# Austrian Holidays
# Austrian Holidays
# Add to Calendar
# Brazilian Holidays
# Brazilian Holidays
# Add to Calendar
# Canadian Holidays
# Canadian Holidays
# Add to Calendar
# China Holidays
# China Holidays
# Add to Calendar
# Christian Holidays
# Christian Holidays
# Add to Calendar
# Danish Holidays
# Danish Holidays
# Add to Calendar
# Dutch Holidays
# Dutch Holidays
# Add to Calendar
# Finnish Holidays
# Finnish Holidays
# Add to Calendar

# French Holidays
# French Holidays
# Add to Calendar
# German Holidays
# German Holidays
# Add to Calendar
# Greek Holidays
# Greek Holidays
# Add to Calendar
# Hong Kong (C) Holidays
# Hong Kong (C) Holidays
# Add to Calendar
# Hong Kong Holidays
# Hong Kong Holidays
# Add to Calendar
# Indian Holidays
# Indian Holidays
# Add to Calendar
# Indonesian Holidays
# Indonesian Holidays
# Add to Calendar
# Irish Holidays
# Irish Holidays
# Add to Calendar
# Islamic Holidays
# Islamic Holidays
# Add to Calendar
# Italian Holidays
# Italian Holidays
# Add to Calendar

#  Japanese Holidays
# Japanese Holidays
# Add to Calendar
# Jewish Holidays
# Jewish Holidays
# Add to Calendar
# Malaysia Holidays
# Malaysia Holidays
# Add to Calendar
# Mexican Holidays
# Mexican Holidays
# Add to Calendar
# New Zealand Holidays
# New Zealand Holidays
# Add to Calendar
# Norwegian Holidays
# Norwegian Holidays
# Add to Calendar
# Philippines Holidays
# Philippines Holidays
# Add to Calendar
# Polish Holidays
# Polish Holidays
# Add to Calendar
# Portuguese Holidays
# Portuguese Holidays
# Add to Calendar
# Russian Holidays
# Russian Holidays
# Add to Calendar

# Singapore Holidays
# Singapore Holidays
# Add to Calendar
# South Africa Holidays
# South Africa Holidays
# Add to Calendar
# South Korean Holidays
# South Korean Holidays
# Add to Calendar
# Spanish Holidays
# Spanish Holidays
# Add to Calendar
# Swedish Holidays
# Swedish Holidays
# Add to Calendar
# Taiwan Holidays
# Taiwan Holidays
# Add to Calendar
# Thai Holidays
# Thai Holidays
# Add to Calendar
# UK Holidays
# UK Holidays
# Add to Calendar
# Vietnamese Holidays
# Vietnamese Holidays
# Add to Calendar


