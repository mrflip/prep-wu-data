#!/usr/bin/perl
# Author: Philip (flip) Kromer
# Copyright 2007

use strict; 
use warnings;
use Data::Dumper;
use Mail::Box::Manager;

my $lemmafile = shift @ARGV or die "Usage: $0 < lemmma.txt";
open(LEMMAFILE, "<$lemmafile") or die("Can't open lemma file $lemmafile: $!");


#       main|@	PoS	lemma	ppm	Range	disp
# ----------------------------------------------------
# 	best	Adv	:	81	100	0.96
# 	bet	Verb	%	23	96	0.81
# 	@	@	bet	21	93	0.79
# 	@	@	bets	0	25	0.80
# 	@	@	betting	2	72	0.88
# 	better	Adv	:	143	100	0.95
# 	Betty	NoP	%	14	90	0.62
# 	@	@	Betty	13	90	0.62


my %mainwordfreq;
my %word_equiv_map;
my $mainword = '';
my $word     = '';
my $freq     = 0;
my @lines = <LEMMAFILE>;
while (my $line = lc shift @lines) {
    $line =~ tr/#*~\'\243//d;
    next if ($line =~ m/\[see /);
    my @fields = split "\t", $line; shift @fields;
    my $gotmainword = ($fields[0] ne '@');

    $word = ($gotmainword) ? $fields[0] : $fields[2];
    $word =~ s{[\(/\)]}{ }g;  # cruft -> spaces
    # Sometimes there's multiple words "a bit" in one entry.  Split into discrete words
    # reverse is so first word ends up as next main (first word's the one like its neighbors)
    my @words = reverse (split /\s+/, $word); 
    # and uniqify
    my %seen = (); @words = grep { ! $seen{ $_ }++ } @words; 
    for $word (@words) { 
	# Naive adverb?
	my $got_ly_adverb = ($word eq $mainword."ly");
	if (($gotmainword) && (! $got_ly_adverb)) {
	    # take a new mainword
	    $mainword = $word; 
	    # strip out cruft, make sure cruftless mainword is registered
	    $mainword =~ y/[A-Za-z0-9]//cd;          
	    $word_equiv_map{$mainword} = $mainword;  
	    # register the frequency contribution
	    $mainwordfreq{$mainword} = ($mainwordfreq{$mainword}||0) + $fields[3]; 
	} elsif (($gotmainword) && ($got_ly_adverb)) {
	    # Naive Adverb detected! 
	    # if mainword, collapse into last mainword freq but don't change mainword.
	    $mainwordfreq{$mainword} = ($mainwordfreq{$mainword}||0) + $fields[3]; 
	}
	# Map from word to mainword
	$word_equiv_map{$word} = $mainword;
	# printf STDERR "   %-20s=>%-20s | %d %d | %6d, %s\n", "'$word'", "'$mainword'", $gotmainword, $got_ly_adverb, $fields[3], $mainwordfreq{$mainword};
	# if ($word =~ m/[^a-z0-9]/) {}
    }
}


# now make all word freqs to their main mainwordfreq
my %wordfreq;
map { $wordfreq{$_} = $mainwordfreq{$word_equiv_map{$_}} } (keys %word_equiv_map);



print "    # Hash from words to canonical form of those words\n";
print "    # Only word forms of three or more letters (orig or mapped), \n";
print "    # and with frequency > 10ppm, are included.\n\n";
print "    \%_word_equiv_map = (\n    ";
my $i = 1;
for $word (sort keys %word_equiv_map) {
    $mainword = $word_equiv_map{$word};
    next if ((length $word < 3) || (length $mainword < 3));
    $word =~ s/'/\\'/g;
    printf "%-15s=>%-15s", "'$word'", "'$mainword',";
    print "\n    " if (!($i%4));  # newline every 5 terms
    $i++;
}
print "\n    );\n\n";

print "    # Hash from canonical form words to frequency in parts per million\n";
print "    # Only canonical word forms of three or more letters, and with frequency > 10ppm, are included.\n";
print "    # This is only the mapped words. Translate first with word_equiv_map()\n\n";
print "    \%_word_freq = (\n    ";
$i = 1;
# decreasing sort by freq.
for $word (sort { -($mainwordfreq{$a} <=> $mainwordfreq{$b}) }  keys %mainwordfreq) {
    next if (length $word < 3);
    $word =~ s/'/\\'/g;
    printf "%-19s=>%6d,    ", "'$word'", $mainwordfreq{$word};
    print "\n    " if (!($i%4));  # newline every 5 terms
    $i++;
}
print "\n    );\n\n";
