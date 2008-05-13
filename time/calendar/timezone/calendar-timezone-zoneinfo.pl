#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;

# Run As
#
# cat zone.tab | ./AuxTable-CountryTZLatLng.pl > AuxTable-CountryTZLatLng.csv
#

sub DMStoDegrees($$$$) {
    (my ($sgn, $deg, $min, $sec)) = @_;
    return ($sgn eq '-' ?-1:1) * (1.0 * $deg + ($min/60) + ($sec/3600));
}

for my $line (<>) {
    next if $line =~ m/^#/;
    chomp $line;

    (my ($cc, $coords, $tz, $comments)) = split "\t", $line;
    $comments ||= '';

    (my ($latSgn,$latDD,$latMM,$latSS,$lngSgn,$lngDD,$lngMM,$lngSS)) = 
	($coords =~ m/^([\+\-])(\d\d)(\d\d)(\d\d)?([\+\-])(\d\d\d)(\d\d)(\d\d)?$/);
    $latSS ||= '0';
    $lngSS ||= '0';
    my $lat = &DMStoDegrees($latSgn,$latDD,$latMM,$latSS);
    my $lng = &DMStoDegrees($lngSgn,$lngDD,$lngMM,$lngSS);

    # print join "\t", ($cc, $tz, $lat, $lng, $coords, $latSgn,$latDD,$latMM,$latSS, $lngSgn,$lngDD,$lngMM,$lngSS, $comments);

    print join ',', (map { "\"$_\"" } ($cc, $tz, $lat, $lng, $comments));
    print "\n";

}
