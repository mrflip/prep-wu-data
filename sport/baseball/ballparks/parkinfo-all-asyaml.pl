#!/usr/bin/env perl -w
use XML::Simple qw(:strict);
use strict; 
use YAML;
use IO::File;



my $parks_all = XMLin('fixd/parkinfo-all.xml', SuppressEmpty=>'', KeyAttr=>{park=>'parkID'},
    ForceArray => ['park', 'othername', 'team', 'comment']);
print Dump($parks_all);
