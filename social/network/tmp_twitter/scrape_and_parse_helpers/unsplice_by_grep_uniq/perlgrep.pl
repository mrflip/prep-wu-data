#!/usr/bin/env perl

my $pattern = "^" . shift(@ARGV) . "\\b";
while (<>) {
  print if $_ =~ /$pattern/o;
}
