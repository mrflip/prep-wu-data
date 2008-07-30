#!/usr/bin/perl5.8.8 -w

binmode STDOUT, ":utf8";

use strict; use warnings;
use YAML::Syck 	 		qw{LoadFile DumpFile};
use Data::Dumper;
use IO::File;
use InfiniteMonkeyWrench; 
use InfiniteMonkeyWrench_Conversions; 
use List::Util qw(sum);

sub main();
sub process_weatherstations( $ );

sub main() {
    my $imw      = &munge_from_schemata('schema/ncdc-stations.imw.yaml');
    my $stations = &process_weatherstations($imw);
    printf STDERR ("Dumping stations...\n");
    DumpFile('ncdc-weather-data/parsed/NCDC_Global_Hourly_Weather_Stations2.yaml', $stations);
    printf STDERR ("All done!\n");
}

sub process_weatherstation_info( $$ ) {
    (my ($stns, $stns_in)) = @_;
    
    while (@{$stns_in}) {
	my %stn_in = %{ pop @{$stns_in} };
	my $stn_id = 'ncdcid-' . $stn_in{USAF_weatherstation_code} . '-' . $stn_in{WBAN_weatherstation_code};
	my %stn    = %{$stns->{$stn_id}->{station_info} || {}};

	my @passthru_fields = qw(USAF_weatherstation_code WBAN_weatherstation_code station_name 
                                 country_code_wmo country_code_fips us_state ICAO_call_sign);
	@stn{@passthru_fields} = @stn_in{@passthru_fields};
	$stn{lat}       = ($stn_in{lat}  eq "99999" ? undef : &sign_and_num($stn_in{lat_sign},  $stn_in{lat}) /1000 );
        $stn{lng}       = ($stn_in{lng}  eq "99999" ? undef : &sign_and_num($stn_in{lng_sign},  $stn_in{lng}) /1000 );
        $stn{elevation} = ($stn_in{elev} eq "99999" ? undef : &sign_and_num($stn_in{elev_sign}, $stn_in{elev})*10   );

	$stns->{$stn_id}->{station_info} = \%stn;
    }
    return $stns;
}


sub process_weatherstation_inventory ( $$ ) {
    (my ($stns, $stns_in)) = @_;
    
    while (@{$stns_in}) {
	# Find this record
	my %stn_in = %{ pop @{$stns_in} };
	my $stn_id = 'ncdcid-' . $stn_in{USAF_weatherstation_code} . '-' . $stn_in{WBAN_weatherstation_code};
	my %stn    = %{$stns->{$stn_id}->{station_inventory} || {}};
	# Process it
	$stn{data_inventory_by_month}->{ $stn_in{data_inventory_year} } =
	    [ map { int($_) } @{$stn_in{data_inventory_months}} ]; 
	# save it back out
	$stns->{$stn_id}->{station_inventory} = \%stn;
    }
    return $stns;
}

sub analyze_weatherstations( $ ) {
    (my ($stns,)) = @_;
    for my $stn (map { $_->{station_inventory} } values %$stns) {
	for my $year (keys %{$stn->{data_inventory_by_month}}) {
	    $stn->{data_inventory_by_year}->{$year} = sum @{$stn->{data_inventory_by_month}->{$year}};
	}
	$stn->{data_inventory_total} = sum values %{$stn->{data_inventory_by_year}};
    }
    
}

sub process_weatherstations( $ ) {
    (my ($imw,)) = @_;
    my %stns = ();
    printf STDERR ("Processing station info...\n");
    process_weatherstation_info     ( \%stns, $imw->{station_info} );
    printf STDERR ("Processing station inventory...\n");
    process_weatherstation_inventory( \%stns, $imw->{station_inventory} );
    printf STDERR ("Analysing...\n");
    analyze_weatherstations(\%stns);
    return \%stns;
}
&main();
1;
