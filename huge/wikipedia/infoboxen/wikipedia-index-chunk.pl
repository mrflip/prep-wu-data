#!/usr/bin/env perl-588 -w -CLADS

use strict;
use IO::File;

#
# Split the xml file into chunks of about MAX_APPROX_SIZE,
# but wait for the end appropriate second-level tag to do so.
# Files will be slightly over MAX_APPROX_SIZE
#

# About how big do we make this thing?
use constant MB => (2**20);
use constant MAX_APPROX_SIZE => 100; # in MB.  For 100, a 14GB dump gets you 140 chunks.

# Leading / Trailing tags to add at continuation
use constant FAKEHEAD   => "<mediawiki>\n";
use constant FAKETAIL   => "</mediawiki>\n";

# Wait for this page boundary to split
use constant SPLITAT    => "</page>";

# Files will have form CHUNKBASE###CHUNKSUFFIX
use constant CHUNKBASE   => "enwiki-chunk-";
use constant CHUNKSUFFIX => ".xml";
    
# Split at the next convenient exit point
my $bytes     = 0;
my $megabytes = 0;
my $chunk     = 0;
my $linenum   = 0;
my $currpage  = '';
my $oversize  = 0;

# Let's autoflush so we can watch the world go by
$| = 1;

print "Splitting giant XML:\n";

my $fh;
sub get_chunk_file($) {
    (my ($chunk)) = @_;
    my $outchunkname = CHUNKBASE.sprintf("%03d",$chunk).CHUNKSUFFIX;
    open $fh, ">:encoding(utf-8)", $outchunkname or die "Can't open '$outchunkname': $!";
    print "    Starting chunk $outchunkname... ";
    return $fh;
}
&get_chunk_file($chunk);
while (my $line = <>) {
    print $fh $line;
    
    # record file offset
    $linenum++;
    $bytes += length($line);
    if ($bytes >= MB) { $megabytes++; $bytes -= MB; };
    
    if ($megabytes >= (MAX_APPROX_SIZE * ($chunk+1))) {
	$oversize = 1;
    }

    #
    # Page end
    #
    if ( ((my $page_offset = index($line,SPLITAT)) != -1) && ($oversize) ) {
	print $fh FAKETAIL;
	close $fh;
	printf "    chunk $chunk finished at line %9d, size %5dMiB+%6dB, page %s.\n",
		$., ${megabytes}, ${bytes}, ${currpage};
	$chunk++;
	&get_chunk_file($chunk);
	print $fh FAKEHEAD;
	$oversize = 0;
    }
    # last if $chunk > 4; # uncomment (and turn down MAX_APPROX_SIZE) for testing.
    
    #
    # Why not track titles too
    #
    if ((my $page_offset = index($line,'<title>')) != -1) {
	$line =~ m!<title>(.*?)</title>(.*)!io;
	$currpage = $1;
    };

}
printf "    all     Finished at line %9d, size %5dMiB+%6dB, page %s.\n",
		$., ${megabytes}, ${bytes}, ${currpage};
close $fh;
