#!/usr/bin/env perl -w

use strict;

# Template tags won't be broken across lines, this is safe.

while (my $line = <>) {
    # look for word following a '{{'
    for my $templ ($line =~ m/\{\{(\w+)/g) {
	$tags{$1}++
    }
}

for my $key (sort { $tags{$a} <=> $tags{$b} } keys %tags) {
    printf "%-18s%s\n", "$key:", $tags{$key};
} 
