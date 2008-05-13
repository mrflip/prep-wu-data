#!/usr/bin/env perl
use strict; use warnings;
use YAML		qw{DumpFile Dump};
use Text::CSV		;
use IO::File            ;
use File::Basename;

# keep more files open than the system permits
# might as well do "ulimit -n 
use FileCache;

# http://search.cpan.org/~rgarcia/perl-5.10.0/lib/FileCache.pm
# $fh = cacheout $path;
# print $fh @data;

# strip off prefix on obj
# strip from props:
#   http://dbpedia.org/property
# vals:
#   <http://dbpedia.org/resource/Out_Hud> => [[Out_Hud]]
# types:
#   "2003-09-02"^^<http://www.w3.org/2001/XMLSchema#date>
#
# <http://(?:dbpedia\.org/property/[\w\.]+|purl\.org/dc/terms/rights)>
# <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property>
# <http://www.w3.org/2000/01/rdf-schema#label>      ".+"
# \.
#

#
# Prototypes
sub unescape_url( $ );
sub open_dump_file( $$$$ );

#
# The things we'll track
my @fields    = qw(obj tpl_gr val join prop type template sub_tpl);
my @id_fields = qw(                    prop type template sub_tpl);

#
# set up files
my $rawfilename = $ARGV[0];
my $dumproot    = $ARGV[1] || "./dump";
die ("usage: $0 /path/to/infoboxen_en.nt") unless $rawfilename;
open RAWFILE, "<$rawfilename" or die ("Couldn't open '$rawfilename': $!");
my $basefilename  = basename($rawfilename, (".nt"));
my %out_files = ();
for my $out_type (@fields) {
    $out_files{$out_type} = open_dump_file($dumproot, $basefilename, $out_type, 'tsv');
}
my $template_files = {};

#
# lay in variables  
my  $ids = {};
for my $field (@id_fields) { $ids->{$field} = {}; };
my ($prop, $prop_rel, $val, $type, $sub_tpl, $obj, $obj_rel, );
my $val_id = 1;
my $obj_id = 1;
my @tpl_gr    = ();    # all the templates shared by a given obj.
my  $last_obj = "";    # watch for transition from one object to the next
RAWLINE: while (my $line = <RAWFILE>) {
    my @matches = ($obj_rel, $obj,    $prop_rel, $prop,    $val,    $type) = 
	($line =~ m{
	    <http://(
	  	     dbpedia.org/resource            |
	  	     upload.wikimedia.org/wikipedia  )  # obj_rel
	    /([^>]+)>\s                   		# obj
	    <http://(
	  	     dbpedia.org/property            |
	   	     purl.org/dc/terms               )  # prop_rel
	    /([^>]+)>\s					# prop
	    (        ".*"                            |
	  	     <http://[^>]+                   )	# val
	    (>|@\w\w|\^\^<.+>)				# type
	    \s\.
         }soix);
    if (! @matches) { warn "Funky line $line"; next; };

    #
    # Classify stuff
    #

    # objects
    $sub_tpl = "";
    if ($obj_rel eq "dbpedia.org/resource") {
	# normal literals
	# FIXME -- should stuff these into their own templates too
	if ($obj =~ m!^([^/]+)/(.+)$!o) { $obj = $1; $sub_tpl = $2; }
    } else {
	# image rights lines
	warn "image resources are usually rights lines: '$obj_rel', '$prop_rel'" if ($prop_rel ne "purl.org/dc/terms");
	next;
    }
    if ($prop_rel ne "dbpedia.org/property") {
	warn "image resources are usually rights lines: '$obj_rel', '$prop_rel'";
	next;
    }

    # values
    my  $template = "";    # have we found out what template we were working on?    
    if    (($val =~ m!<http://dbpedia.org/resource/Template:(.*)!) && ($prop eq "wikiPageUsesTemplate")) {
	# Template
	$template = "$1";
	$val      = "{{Template:$1}}";
	$type = "template_wp"; 
    }
    elsif ($val =~ m!<http://dbpedia.org/resource/(.*)!) {
	$val = "[[$1]]";
	$type = "link_wp";
	warn (sprintf "Template links are usually wikiPageUsesTemplate: \n%6d|%-56s|%6d|%-31s|%6d|%-20s|%s\n",
	      $obj_id, $obj, $ids->{prop}->{$prop}, $prop, $ids->{type}->{$type}, $type, $val) if ($val =~ m!<http://dbpedia.org/resource/Template:(.*)!);
    }
    elsif (($val =~ m!<((?:ftp|https?)://.*)!) && ($type eq ">")) {
	$val = $1;
	$type = "link_ext";
    }
    elsif ($type eq ">") {
	warn("dbpedia links are usually urls or sp links: $line");
    }
    elsif ($val !~ m!^".*"$!o) {
	warn("non-link values are ususally strings: $line");
    }
    
    #
    # Assign IDs
    #
    
    # depends on all the objs being in the same line
    my $emit_obj = 0;
    if (!defined($ids->{prop}->{$prop})) {		# props
	$ids->{prop}->{$prop} 		= 1 + scalar keys %{$ids->{prop}};
    }
    if (!defined($ids->{type}->{$type})) {		# types
	$ids->{type}->{$type} 		= 1 + scalar keys %{$ids->{type}};
    }
    if (!defined($ids->{sub_tpl}->{$sub_tpl})) {       # sub_tpls
	$ids->{sub_tpl}->{$sub_tpl} 	= 1 + scalar keys %{$ids->{sub_tpl}};
    }
    if (($template) && (!defined($ids->{template}->{$template}))) { # templates
	$ids->{template}->{$template} 	= 1 + scalar keys %{$ids->{template}};
    }
    if ($template) {
	push @tpl_gr, $ids->{template}->{$template};	
    }

    #
    # Emit objects immediately at meeting a new one
    #
    if (!$last_obj) { $last_obj = $obj; } # we must be on first object
    if ($obj ne $last_obj) {				
	# emit the obj
	$out_files{obj}->printf(   "%7d\t%s\t%s\n",  $obj_id, $last_obj, &unescape_url($last_obj) );
	$out_files{tpl_gr}->printf("%7d\t%s\n",  $obj_id, (join ',', @tpl_gr) );
	@tpl_gr = (); # start a group with each new obj.
	$last_obj = $obj;
	$obj_id++;
    }

    #
    # Emit tables
    #
    $out_files{val}->printf(  "%7d\t%s\n",            $val_id, $val);
    $out_files{join}->printf( "%7d\t%7d\t%7d\t%7d\t%7d\t%7d\n",
			      $val_id, $obj_id, $ids->{prop}->{$prop}, $ids->{type}->{$type}, $ids->{sub_tpl}->{$sub_tpl});
    printf "%6d|%-56s|%6d|%-31s|%-25s|%6d|%-20s|%s\n",
	$obj_id, $obj, $ids->{prop}->{$prop}, $prop, $sub_tpl, $ids->{type}->{$type}, $type, $val;
    # another day, another dollar.
    $val_id++;
}
# KLUDGE -- should be a sub. 
$out_files{obj}->printf(   "%7d\t%s\t%s\n",  $obj_id, $obj, &unescape_url($obj) );
$out_files{tpl_gr}->printf("%7d\t%s\t%s\n",  $obj_id, (join ',', @tpl_gr), $obj );


for my $field (@id_fields) {
    my %id_to_thing = reverse (%{$ids->{$field}},);
    for my $id (sort {$a <=> $b} keys %id_to_thing) {
	my $thing = $id_to_thing{$id};
	$out_files{$field}->printf("%7d\t%s\t%s\n", $id, $thing, &unescape_url($thing));
    }
}


my $stats = {
    'objs' => {
	'num' => ($obj_id - 1),
	},
    'vals' => {
	'num' => ($val_id - 1),
	},
   };
for my $field qw(prop type template sub_tpl) { $stats->{$field}->{num} = scalar keys %{$ids->{$field}}; };

$out_files{stats} = open_dump_file($dumproot, $basefilename, 'stat', 'yaml');   
$out_files{stats}->printf(Dump($stats));

# close files
for my $out_type (keys %out_files) {
    $out_files{$out_type}->close();
}
	 
sub open_dump_file( $$$$ ) {
    (my ($dumproot, $basefilename, $out_type, $ext)) = @_;
    my $filename = "${dumproot}/${basefilename}_${out_type}s.${ext}";
    $out_files{$out_type} = new IO::File "> $filename"
	or die ("Couldn't open '$filename': $!");
}

    
sub unescape_url( $ ) {
    (my ($raw,)) = @_;
    my $unesc = "$raw";
    
    # undo the crappy _percent_\x\x encoding
    $unesc =~ s/_percent_25/%/gsoi;
    $unesc =~ s/%25/%/gsoi;
    $unesc =~ s/_percent_([0-7][a-f\d])/%$1/gsoi;
    # turn 8-bit characters into entities
    # $unesc =~ s/%([89a-f][a-f\d])(?:%([89a-f][a-f\d]))+/'&#'.hex($2).';'/egsoi;
    # turn 7-bit characters into ascii
    $unesc =~ s/%([0-7][a-f\d])/chr(hex($1))/egsoi;
    return $unesc
}    
