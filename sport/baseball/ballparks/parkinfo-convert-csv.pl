#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;

use vars qw{%sqlrows %sqlkeys }; 


# for foo in parkinfo-sql-* ; do time mysql -E -h localhost -u vizsagedb -p'<password>' < $foo ; done


#
# Snarf XML from each source to merge.
#
sub import_parks() {
    my %parkstree = ();
    $parkstree{parks}       = XMLin('parkinfo-all.xml'       , SuppressEmpty=>'', KeyAttr=>{park=>'parkID'}, ForceArray => ['park', 'team', 'othername', 'comment']);
    return \%parkstree;
}


my %sqlkeys =(); my %sqlrows =();
$sqlrows{'parks'} = [  
    { field=>'parkID',		type=>'CHAR(5)' },
    { field=>'name',     	type=>'CHAR(55)' },
    { field=>'beg',		type=>'DATE' },
    { field=>'end',		type=>'DATE' }, 
    { field=>'games',		type=>'INTEGER UNSIGNED' }, 

    { field=>'streetaddr',	type=>'CHAR(55)	' },
    { field=>'extaddr', 	type=>'CHAR(55) ' },
    { field=>'city',		type=>'CHAR(35)' },
    { field=>'state',		type=>'CHAR(2)' },
    { field=>'country',		type=>'CHAR(2)' },
    { field=>'zip',		type=>'CHAR(10)' },
    { field=>'tel',		type=>'CHAR(18)' },
    { field=>'active',  	type=>'CHAR(1)' },
    { field=>'lat',		type=>'DOUBLE	' },
    { field=>'lng',		type=>'DOUBLE	' },
    { field=>'url',		type=>'CHAR(25)' },
    { field=>'spanishurl',	type=>'CHAR(25)' },
    { field=>'logofile',	type=>'CHAR(25)' },

#     { field=>'city_pc',  	type=>'CHAR(35)' },
#     { field=>'city_mlb',	type=>'CHAR(35)' },
#     { field=>'state_pc',	type=>'CHAR(2)' },
#     { field=>'state_mlb',	type=>'CHAR(2)' },
#     { field=>'country_mlb',	type=>'CHAR(2)' },
#     { field=>'teamname_mlb',	type=>'CHAR(55)' },
#     { field=>'parkname_mlb',	type=>'CHAR(55)' },
#      { field=>'beg_pc',  	type=>'DATE' },
#      { field=>'end_pc',  	type=>'DATE' },		  
#      { field=>'beg_rsh',  	type=>'DATE' },
#      { field=>'end_rsh',  	type=>'DATE' },		  
#     { field=>'active_bdb',	type=>'CHAR(1)' },
#     { field=>'range',		type=>'DOUBLE	' },
#     { field=>'href',		type=>'CHAR(25)' },

    ];
$sqlkeys{'parks'} = "PRIMARY KEY (`parkID`)";

$sqlrows{'teams'} = [
    { field=>'parkID',		type=>'CHAR(5)' },
    { field=>'teamID',		type=>'CHAR(3)' },
    { field=>'beg',		type=>'DATE' },
    { field=>'end',		type=>'DATE' },
    { field=>'games',		type=>'INTEGER UNSIGNED' },
    { field=>'neutralsite',	type=>'BOOLEAN' },
		     

    { field=>'parknameBDB',	type=>'CHAR(55)' },
#     { field=>'teamname',	type=>'CHAR(25)' },
#     { field=>'teamIDlahman45',	type=>'CHAR(3)' },
#     { field=>'teamIDBR',	type=>'CHAR(3)' },
#     { field=>'teamIDBDB',	type=>'CHAR(3)' },
#     { field=>'franchName',	type=>'CHAR(25)' },
#     { field=>'franchID_bdb',	type=>'CHAR(3)' },
#     { field=>'franchID_rsh',	type=>'CHAR(3)' },
#     { field=>'lgID_bdb',	type=>'CHAR(2)' },
#     { field=>'lgID_pc',		type=>'CHAR(2)' },
#     { field=>'lgID_rsh',	type=>'CHAR(2)' },
#      { field=>'beg_bdb',	type=>'SMALLINT UNSIGNED' },
#      { field=>'beg_rsh',	type=>'SMALLINT UNSIGNED' },
#      { field=>'end_bdb',	type=>'SMALLINT UNSIGNED' },
#      { field=>'end_rsh',	type=>'SMALLINT UNSIGNED' },
#     { field=>'src',		type=>'CHAR(5)' },
#     { field=>'src_gl',		type=>'CHAR(5)' },
#     { field=>'src_rsh',		type=>'CHAR(5)' },
    ];
$sqlkeys{'teams'} = "PRIMARY KEY (`parkID`,`teamID`)";

$sqlrows{'othernames'} = [
    { field=>'parkID',		type=>'CHAR(5)' },
    { field=>'name',		type=>'CHAR(55) BINARY' },
    { field=>'beg',	type=>'SMALLINT UNSIGNED' },
    { field=>'end',	type=>'SMALLINT UNSIGNED' },
    { field=>'auth',		type=>'BOOLEAN' },
    { field=>'curr',		type=>'BOOLEAN' },

#     { field=>'auth_rs',  	type=>'CHAR(1)' },
#     { field=>'src_rsh',		type=>'CHAR(1)' },
#     { field=>'src_bdb',		type=>'CHAR(1)' },
#     { field=>'src_mlb',		type=>'CHAR(1)' },
#     { field=>'src_pcaka',	type=>'CHAR(1)' },
#     { field=>'src_pc',		type=>'CHAR(1)' },

    ];
$sqlkeys{'othernames'} = "PRIMARY KEY (`parkID`,`name`)";

$sqlrows{'comts'} = [
    { field=>'parkID',		type=>'CHAR(5)' },
    { field=>'comment',		type=>'VARCHAR(150)' },
    ];
$sqlkeys{'comts'} = "PRIMARY KEY (`parkID`,`comment`)";



sub dumpcsvtable($\@\@) {
    my $name = shift;
    my $vals = shift;
    my $rows = $sqlrows{$name};

    my @rows = map { $_->{field} } @$rows;
    my $csv = Text::CSV_XS->new();
    my $fh  = new IO::File;
    $fh->open(">parkinfo-csv-$name.csv") or die "Can't write to parkinfo-csv-$name.csv: $!";
    printf "Wrote %s: fields %s\n", $name, join ', ',@rows;
    for my $val (@$vals) {
	my %val = %$val;

	$csv->print($fh, [map { ((defined $_) ? $_ : 'NULL') }  @val{@rows}]); # 
	print $fh "\n";
    }
    $fh->close;
}

sub dumpSQLQuery($\@) {
    my $name = shift;
    my $vals = shift;
    my $rows = $sqlrows{$name};

    my $fh  = new IO::File;
    my $filename  = "parkinfo-sql-$name.sql";
    my $csvfile   = "parkinfo-csv-$name.csv";
    my $tablename = "`vizsagedb_foo`.`Parks_$name`";
    $fh->open(">$filename") or die "Can't write to parkinfo-sql-$name.sql: $!";
    print $fh "DROP TABLE IF EXISTS $tablename;\n";
    print $fh "CREATE TABLE         $tablename (\n";
    for my $field (@$rows) {
	printf $fh "    %-25s %-20s,\n", "`$field->{field}`", $field->{type};
    }
    printf $fh "    %s\n", $sqlkeys{$name};
    print $fh "  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ROW_FORMAT = FIXED;\n\n";
    print $fh <<EOF;
TRUNCATE TABLE $tablename;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/$csvfile'
        REPLACE INTO TABLE $tablename
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\\\'
        LINES  TERMINATED BY '\\n';
EOF
    $fh->close;
}

sub dumpcsvtables(\%) {
    my $parkstree  = shift;
    
    # flatten tree
    my (@parks, @teams, @names, @comts);
    for my $parkID (keys %{$parkstree->{parks}->{park}}) {
	my $park  = $parkstree->{parks}->{park}->{$parkID}; 
	my (@parkteams, @parknames, @parkcomts);

	if ($park->{team}->[0])      { @parkteams = @{$park->{team}};     	delete $park->{team};      } else { @parkteams = () }
	if ($park->{othername}->[0]) { @parknames = @{$park->{othername}};   	delete $park->{othername}; } else { @parknames = () }
	if ($park->{comment}->[0])   { @parkcomts = @{$park->{comment}};  	delete $park->{comment};   } else { @parkcomts = () }

	$park->{parkID} = $parkID;
	for my $team  (@parkteams) { $team->{parkID} = $parkID; }; 
	for my $name  (@parknames) { $name->{parkID} = $parkID; };
	for my $comt  (@parkcomts) { $comt->{parkID} = $parkID; };
	push @parks, $park;
	push @teams, @parkteams;
	push @names, @parknames;
	push @comts, @parkcomts;
    }
    

    @parks = sort { ($a->{parkID} cmp $b->{parkID}) || ($a->{beg}  cmp $b->{beg} ) } @parks;
    @teams = sort { ($a->{teamID} cmp $b->{teamID}) || (  ($a->{beg}||print Dumper($a))  cmp ($b->{beg}||print Dumper($a)) ) } @teams;
    @names = sort { ($a->{parkID} cmp $b->{parkID}) || ($a->{name} cmp $b->{name}) } @names;

    # my (%teamfields, %namefields);
    # map { @namefields{keys %$_} = keys %$_ } @names;
    # my @namefields = map { {'field'=>$_, 'type'=>'CHAR(30)' } } keys %namefields;

    &dumpcsvtable('parks', \@parks);
    &dumpSQLQuery('parks', \@parks);
    &dumpcsvtable('teams', \@teams);
    &dumpSQLQuery('teams', \@teams);
    &dumpcsvtable('othernames', \@names);
    &dumpSQLQuery('othernames', \@names);
    &dumpcsvtable('comts', \@comts);
    &dumpSQLQuery('comts', \@comts);
}


my $parkstree = &import_parks();
&dumpcsvtables($parkstree);


