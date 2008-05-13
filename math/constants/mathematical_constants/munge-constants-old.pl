#!/usr/bin/perl -w

use strict;
use IO::File;

#
# Pulled out all files that weren't !text! !bignumber!
# and pushed all the actual constant values over to the left hand side
#
# so each input file is
#   'stuff that is not a number'
#   'exactly one line with a leading digit and possible - sign then many digits'
#   '...digits only...'
#   'a last line that might have a ";" on the end'
#
#


#
# Usage:
#   for file in *.TXT ; do
#     cat $file | ./munge-constants.pl > headerfooter/$file.head.txt ;
#   done
# 
sub grabsimpleconstants($) {
    my $filename = shift;
    my $infile = new IO::File;
    $infile->open("<$filename") or die "Crapsticks, can't open $filename: $!";

    # we'll go HEADER, (first line), DIGITS, LAST
    my $phase      = "HEADER";
    my $digitlines = 0;
    
    # printf "\n%s\n  %s\n%s\n\n", "-"x25, $filename, "-"x25;
    printf "%-25s:", $filename;
    for my $line (<$infile>) {
	$line =~ s/[\x0a\x0d]+$//;  #chomp

	# skip things that aren't a line of numbers + acceptable cruft.
	next if ( ($phase eq "HEADER") && ($line !~ m/^-?[\d\.]+[\s\\]*$/o) );

	#OK -- got the first number line.  Emit it and move to DIGITS
	if ($phase eq "HEADER") {
	    $phase = "DIGITS"; 
	    # print "$line\n";
	    print 'h';
	    $digitlines=1;
	    next;
	}

	# ... lines with digits only, maybe a \ at end ...
	if ( ($phase eq "DIGITS") && ($line =~ m/^\d+\\?$/o) ) {
	    # print "$line\n";
	    #print 'd';
	    $digitlines++;
	    next;
	}

	# ... last line ...
	if ( ($phase eq "DIGITS") && ($line =~ m/^\d+[\:\;]?\s*$/o) ) {
	    $phase = "LAST";
	    # print "$line\n";
	    printf " <d x %d>\tl", $digitlines;
	    next;
	}

	if ( (($phase eq "DIGITS") || ($phase eq "LAST")) && ($line =~ m/^\s*$/o) ) {
	    print (($phase eq "DIGITS") ? (sprintf " <d x %d>\tw", $digitlines) : ('w'));
	    $phase = "LAST";
	    next;
	}
	    
	warn "Fucked up line '$line' in $filename";
    }
    if ($phase eq "DIGITS") { printf " <d x %d>\t", $digitlines; }
    print "\n"
}

for my $filename (@ARGV) {
    &grabsimpleconstants($filename);
}

# Need to cat in from E.txt


my $schema_story_template = <<HERE;
This is one of a large collection of mathematical constants computed to ridiculous precision.
They were gathered from the longstanding ftp.sunet.se server; I believe they were shared by
various people in the early days of USENET and aggregated by Simon Plouffe.  If you know
corrected credit / contributor information please share.


	  digits:
	  
HERE
