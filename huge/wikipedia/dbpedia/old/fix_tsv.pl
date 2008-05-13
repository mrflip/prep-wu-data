#!/usr/bin/env perl
use strict; use warnings;

# time cat infobox_en.csv \
#     | ~/ics/code/munge/huge/wikipedia/dbpedia/fix_tsv.pl \
#     > infobox_en.tsv 2>err.log
#
# real    2m1.740s        user    1m51.446s       sys     0m11.333s       pct     100.00


my $rawfilename = $ARGV[0];
die ("usage: $0 /path/to/infoboxen_en.csv") unless $rawfilename;
my $propsfilename = $rawfilename; $propsfilename =~ s/\.csv//; $propsfilename .= "_props.tsv";
my $valsfilename  = $rawfilename; $valsfilename  =~ s/\.csv//; $valsfilename  .= "_vals.tsv";
open RAWFILE,   "<$rawfilename"   or die ("Couldn't open '$rawfilename': $!");
open PROPSFILE, ">$propsfilename" or die ("Couldn't open '$propsfilename': $!");
open VALSFILE,  ">$valsfilename"  or die ("Couldn't open '$valsfilename': $!");    

my $id = 1;
my ($obj, $prop, $val, $rel);
RAWLINE: while (my $line = <RAWFILE>) {
    my $i = 0;
    while ($line !~ m/^[^\t]+\t[^\t]+\t.*\t[rl]$/so) {
	$line .= <RAWFILE>;
	last if ($i++ > 1000);
    }
    chomp $line;
    # escape newlines
    $line =~ s/\n/\\n/gso;
    # undo the crappy _percent_\x\x encoding
    $line =~ s/_percent_25/%/gsoi;
    $line =~ s/%25/%/gsoi;
    $line =~ s/_percent_([0-7][a-f\d])/%$1/gsoi;
    # turn 8-bit characters into entities
    # $line =~ s/%([89a-f][a-f\d])(?:%([89a-f][a-f\d]))+/'&#'.hex($2).';'/egsoi;
    # turn 7-bit characters into ascii
    $line =~ s/%([0-7][a-f\d])/chr(hex($1))/egsoi;

    # # correct lines with embedded \t
    # if ($line !~ m/^([^\t]+)\t([^\t]+)\t([^\t]*)\t([rl])$/so) {
    # 	if (($obj, $prop, $val, $rel) = ($line =~ m/^([^\t]+)\t([^\t]+)\t(.*)\t([rl])$/so)) {
    # 	    $val =~ s/\t/\\t/gso;
    # 	    # warn "Repaired line '$line'";
    # 	} else {
    # 	    warn "Crappy line '$line'";
    # 	    next RAWLINE;
    # 	}
    # } else {
    # 	($obj, $prop, $val, $rel) = ($1, $2, $3, $4);
    # }
    ($obj, $prop, $val, $rel) = ($line =~ m/^([^\t]+)\t([^\t]+)\t(.*)\t([rl])$/so);
    $val =~ s/\t/\\t/gso;
    
    print PROPSFILE (join "\t", ($id, $obj, $prop, $rel))."\n";
    print VALSFILE  (join "\t", ($id, $val))."\n";
    $id++;
}


