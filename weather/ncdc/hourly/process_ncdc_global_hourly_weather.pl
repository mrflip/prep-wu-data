#!/usr/bin/perl5.8.8 -w

binmode STDOUT, ":utf8";

use strict; # use warnings;
use YAML::Syck 	 		qw{LoadFile DumpFile Load Dump};
use Data::Dumper;
use IO::File;
use File::Basename;  use File::Path;
use InfiniteMonkeyWrench; 
use InfiniteMonkeyWrench_Conversions; 
use List::Util qw(sum);
use PerlIO::gzip;
use DateTime;
    
use constant RAW_DIR => "ncdc-weather-data/raw-isd-lite";
use constant OUT_DIR => "ncdc-weather-data/parsed/isd_lite_by_cc_yr";
use constant YEARS   => (1950..2008); # 725320-14842-2007.gz
sub main();

#
# 475115 files
#    923 files / 16m

sub main() {
    printf STDERR ("Loading stations...\n");
    my $stations = LoadFile('ncdc-weather-data/parsed/NCDC_Global_Hourly_Weather_Stations2.yaml');
    my $fh = new IO::File;

    # input files are organized by year/USAF-WBAN
    for my $year (YEARS) {
	my $year_dir = RAW_DIR . "/$year";
	printf STDERR "Examining directory $year_dir\n";
	opendir(DIR, $year_dir);
	my @files = grep(/\d{6}-\d{5}-\d{4}\.gz$/,readdir(DIR)); # \d{6}-\d{5}-
	closedir(DIR);
	for my $file (@files) {
	    # Get station info
	    (my ($USAF_id, $WBAN_id)) = ($file =~ m/(\d{6})-(\d{5})-\d{4}\.gz$/);
	    my $stn_id = "ncdcid-$USAF_id-$WBAN_id";
	    my $stn = {};
	    # inventory not included
	    $stn->{station_info} = $stations->{$stn_id}->{station_info};

	    # skip existing files
	    my $outfilename = &filename_from_station($stn,$year);
	    next if ( (-f $outfilename) || (-f "$outfilename.bz2") || (-f "$outfilename.gz") );

	    # Read, parse raw data
	    open RAW_FILE, "<:gzip", "$year_dir/$file" or do { warn "Couldn't read '$year_dir/$file': $!"; next; };
	    $stn = &analyze_weatherstations($stn, \*RAW_FILE, $year);
	    close RAW_FILE;

	    # Dump it to file
	    mkpath(dirname($outfilename));
	    $fh->open("> $outfilename") or die "Couldn't open '$outfilename': $!";
	    printf STDERR "  $outfilename\n";
	    DumpFile($fh, $stn);
	    $fh->close;
	}
    }
}

sub filename_from_station( $$ ) {
    (my ($stn,$year)) = @_;
    my $cc = $stn->{station_info}->{country_code_fips} || 'xx';
    $cc .= "_$stn->{station_info}->{us_state}" if $stn->{station_info}->{us_state};
    my $filename = sprintf("%s/%s/%s/%s_%03d_%04d_%04d_%06d-%05d.yaml", OUT_DIR,
	$cc,
	$year,
	$cc,
	$stn->{station_info}->{lat}||999, $stn->{station_info}->{lng}||9999, $year,
	$stn->{station_info}->{USAF_weatherstation_code},
	$stn->{station_info}->{WBAN_weatherstation_code}
	);
    $filename =~ s/ /@/g; # [^a-zA-Z0-9\-_\.
    return $filename;
}

sub scale_and_null($$$) {
    (my ($val, $scale, $null)) = @_;
    return ($val eq $null ? undef : 1.0*($val||0)/$scale);
}

sub fixdatetime( $$$$ ) {
    (my ($yr, $mo, $day, $hr)) = @_;
    my $dt = DateTime->new(year => $yr, month => $mo, day => $day, hour => $hr, time_zone  => 'GMT' );
    return ($dt->datetime).'Z';
}

sub print_weatherstation( $$ ) {
    return filename_from_station($_[0], $_[1]);
}

#
# NOTE: As best I can tell, the time info is GMT
#   ( http://www1.ncdc.noaa.gov/pub/data/ish/ish-tech-report.pdf )
#
# also, NOTE: the somewhat brittle things like: fields are 6 chars which seems to
# include a blank; the null -9999 vals are matched against a leading blank;
#
use constant ISDLITE_FMT => 'A4  xA2xA2xA2A6    A6    A6    A6    A6    A6    A6    A6    ';
#  		Sample line: 1902 12 27 20  -117 -9999  9671   320    21     8 -9999 -9999' 
sub analyze_weatherstations( $$$ ) {
    (my ($stn,$fh, $year)) = @_;
    my @fields   = qw(
        observation_datetime
	air_temperature dew_point_temperature sea_level_pressure
	wind_direction wind_speed_rate  sky_condition_total_coverage_code
	rain_depth_one_hour rain_depth_six_hour );
    my $i = 0;
    while (my $line = <$fh>) {
	chomp $line; $i++;
	if (length($line) != 61) {
	    printf STDERR "Fuck you, line '%s'... you're too short for this ride. (%s line %s)\n",
		$line, print_weatherstation($stn, $year), $i;
	    return {};
	}
	my @vals     = unpack(ISDLITE_FMT, $line);
	my %record;
	my $year     = $vals[0];
	@record{@fields} = (
	    &fixdatetime   (@vals[0..3]),
	    &scale_and_null($vals[4], 10, ' -9999'), #temp
	    &scale_and_null($vals[5], 10, ' -9999'), #dewpt
	    &scale_and_null($vals[6], 10, ' -9999'), #press
	    &scale_and_null($vals[7],  1, ' -9999'), #wind dir
	    &scale_and_null($vals[8], 10, ' -9999'), #wind spd
	    &scale_and_null($vals[9],  1, ' -9999'), #sky code
	    (($vals[10]||0)==-1) ? -1 : &scale_and_null($vals[10], 10, ' -9999'), 
	    (($vals[11]||0)==-1) ? -1 : &scale_and_null($vals[11], 10, ' -9999')
	    );
	push @{$stn->{weather_data}->{$year}}, \%record;
    }
    return $stn;
}

&main();
1;
