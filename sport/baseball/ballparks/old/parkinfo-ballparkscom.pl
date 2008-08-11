#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;


# grep -Pi '((?:<[Bb]>(tenant|opened|night game|(first|last)[^:]game|surface|capacity|architect|demolish|builder|construction|owner|cost|financing|location|dimensions|fences)).*$|<h2.*$|<title.*$)' */*.htm* | ./parkinfo-ballparkscom.pl

my %teams = qw{
  alpkdc  	anahei  	arling  	bennet  	
  bosbpk  	bpkarl  	clevel  	columb  	
  comis2  	comisk  	county  	detbpk  	
  dodger  	exhibi  	fenway  	griffi  	
  hilltp  	huntin  	jacobs  	kauffm  	
  kcymun  	kingdo  	league  	lloyds  	
  memori  	metrod  	metrop  	minbpk  	
  nyybpk  	oakbpk  	oaklan  	oriole  	
  oriopk  	pologr  	rfksta  	seabpk  	
  sheast  	shibep  	sickss  	skydom  	
  sports  	sthsid  	tigers  	tropic  	
  wrigla  	yankee  	
};


my $fields = "tenant|opened|night game|(first|last)[^:]game|surface|capacity|architect|demolish|builder|construction|owner|cost|financing|location|dimensions|fences";
  while (<>) {
    # ((?:<(?:<[^>]*>\s*)(${fields}))|<h2[^>]*>|<title[^>]*>)
    s/&amp;/&/g;
    s/&#189;/and one-half/g;

    m/^([^:]*):\s*((?:[^:]*:)|<h2[^>]*>|<title[^>]*>)\s*(.*?)(?:<[^>]*>\s*)*$/io or do { warn "Bad Match: $_"; next; };
    (my ($team, $field, $val)) = ($1, $2, $3);

    $team   =~ s!.*/([^/]*)\.html?$!$1!o;
    $field  =~ s/<title[^>]*>/title/igo;
    $field  =~ s/<h2[^>]*>/name/igo;
    $field  =~ s/<[^>]*>//go;
    $field  =~ s/:$//o;
    $field  =  lc $field;
    $val    =~ s/<[^>]*>//go;

    for my $subval (split ';',$val) {
	$subval =~ s/^\s*(.*?)\s*$/$1/o;
	printf "%-15s | %-10s | %s\n", $team, $field, $subval;
    }
}
    
#
