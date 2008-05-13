#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;

my $xml   = XML::Simple->new(RootName => 'units', GroupTags=>{units=>'unit'},
			   KeyAttr=>{unit=>'name'}, 
			   ForceArray=>['unit']);
my $units = $xml->XMLin('Auxtable-Constants-Units.xml'); #->{units};
print Dumper($units);



Convert[Foot, Meter]/Meter // N[#, 18] & // NumberForm[#, 18] &


sub SlurpMMConstantsList() {
# slurp
    local $/; 
    $_=<>; 

    my %basicunits;
    for my $m (m/StyleBox\["\\<\\"([^\]]*)\\"\\>", "MSG"\]/igs) {
	$m =~ s/\\?[\r\n]//g; 
	next if $m =~ m/ is an abbreviation for/;
	$m =~ s/(\w+) volume unit/unit of volume in the $1 traditional systemtem/;

	(my ($name, $flavor, $of, $measure)) = ($m =~ m/(.*) is (.*?) (of |multiplier)(.*)\./);
	my $system = ''; my $fundamental = '';

	if ($of eq 'multiplier') { $measure=$of; $of=''; }

	if ($measure =~ /^(.*) in the (.*) systemtem/) { 
	    ($measure, $system) = ($1, $2); 
	} elsif ($flavor =~ /the (\w+) (?:(\w+) )?(unit|measure)/) {
	    ($flavor, $fundamental, $system) = ("the $3", $1, $2||'');
	}
	

	if (defined $name) {
	    printf "%-40s %-30s %-20s %-14s\n", ($measure, $name, $system, $fundamental, ); # $flavor, $of, 
	} else {
	    warn "$m";
	}

	@{$basicunits{$name}}{qw{measure name systemtem funamental}} = ($measure, $name, $system, $fundamental, );
    }



    my $xmldecl = qq{<?xml version='1.0' standalone='yes'?>\n<?xml-stylesheet href="" type="text/xsl"?>};
    my $xmlw = XML::Simple->new(RootName => 'units', GroupTags=>{units=>'unit'},
				KeyAttr=>{unit=>'name'}, 
				ForceArray=>['unit']);
    $xmlw->XMLout({unit=>\%basicunits},      OutputFile => 'Auxtable-Constants-Units.xml');
}
