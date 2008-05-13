#!/usr/bin/env perl -w -CLADS
use strict;

my %tags = ();
my $total_tags = 0;
while (my $line = <>) {
    $line =~ s/_/ /g;
    if ($line =~ m/^\s+- template: .{{\W*(\w+)/) {
	# Using [\w\s]+(?:\}\}|\|) (get everything before pipe) might make a better name.
	# note that we killed off initial whitespace.
	my $tag = lc $1; $tags{$tag}->{name} = $tag;
	$tags{$tag}->{total}++;  $total_tags++;

	# classify
	my @opens = ($line =~ m/(\{\{)/g); my @closes = ($line =~ m/(\}\})/g);
	#if ($line =~ m/cquote/) { printf STDERR "%d %d %s", $opens, $closes, $line; }
	if    ( ($#opens == 0) && ($#closes == 0) ) { $tags{$tag}->{simple}++;     }
	elsif ( ($#opens == $#closes) )             { $tags{$tag}->{balanced}++;   }
	else                                        { $tags{$tag}->{unbalanced}++; }
    } elsif ($line =~ m/^\s+- template_bad: .*{{\W*(\w+)/) {
	my $tag = lc $1; $tags{$tag}->{name} = $tag;
	$tags{$tag}->{total}++;  $total_tags++;
	$tags{$tag}->{broken}++;
    };
}

my $min_count = 10;
printf "## Analyzed %s tags with %s occurrences\n", (scalar keys %tags), $total_tags;
print "## Skipping unbroken simple tags with fewer than $min_count occurrences\n";
for my $tag (sort { $a->{total} <=> $b->{total} } values %tags) {
    # count non-simple
    my $non_simple = ( ($tag->{total}||0) - ($tag->{simple}||0) );
    # skip boring 
    next unless ( $non_simple || ($tag->{total} >= $min_count) );

    # percent of all tags
    my $pct = 100*($tag->{total} / ($total_tags));
    my $pct_s = ($pct < 0.1) ? '' : (sprintf "(%5.1f%%)", $pct);

    # percentages of this tag
    my $tag_type = '-';
    for my $type (qw{simple balanced unbalanced broken}) {
	# coerce to defined
	$tag->{$type} ||= 0;
	# percentage
	$tag->{"pct_${type}"}   = 100*($tag->{$type} / $tag->{total});
	$tag->{"pct_s_${type}"} = ($tag->{"pct_${type}"} < 0.1) ? '-' : (sprintf "(%5.1f%%)", $tag->{"pct_${type}"});
	# classify
	$tag_type = $type if (($tag->{"pct_${type}"} > 99.5) && ($tag->{total} > 10));
    }
  
    # dump
    printf("%-10s All:%7s %8s s:%7s %8s v %6s b:%7s %8s u:%7s %8s br:%7s %8s || %s\n",
	$tag_type,
	$tag->{total}      ||'-', $pct_s,
	$tag->{simple}     ||'-', $tag->{"pct_s_simple"},
	($non_simple ? (sprintf "%6d",$non_simple) : '-'),
	$tag->{balanced}   ||'-', $tag->{"pct_s_balanced"}, 
	$tag->{unbalanced} ||'-', $tag->{"pct_s_unbalanced"}, 
	$tag->{broken}     ||'-', $tag->{"pct_s_broken"}, 
	$tag->{name},
	);
}
