#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;
use File::Copy;

my $parkinfodir  = '/Users/flip/now/GusGorman/apps/BaseballBrainiac/pysrc/retrosheet/info/parks';
my $datadir      = '/work/DataSources/Data_MLB/sportslogos.net/sportslogos.net';

my $csvfilename  = "$parkinfodir/scripts/parkinfo-sportslogos-all.csv";
my $csv          = Text::CSV_XS->new ({ binary => 1, eol => $/ });
my $csvfile      = new IO::File; $csvfile->open("<$csvfilename")   or die "Can't read from $csvfilename: $!";


my %typemap = (qw{ Jersey J Logo L Pennant F Program P Promo O }, "Ticket Stub",'T');
my %rolelocmap =  qw{ 
	Alternate_Road_shoulder	ARS	Alternate_White_shoulder AWS	Alternate_		Alt	
	Anniversary_		Anv	Cap_Alt			CAt	Cap_BP_Alt		CBA	
	Cap_BP			CBP	Cap_Game		CGm	Cap_Home_Alt		CHA	
	Cap_Home_Road		CHR	Cap_Home		CHm	Cap_Interleague		CIL	
	Cap_Road		CRd	Cap_Red			CRe	Cap_Visor		CVi	
	Cap_			Cap	Championship_		Ch_	Event_			Ev_	
	Helmet_			He_	Home_			Hm_	Memorial_		Me_	
	Miscellaneous_		Mi_	Pennant_		Pe_	Practice_		Pr_	
	Primary_		Pri	Program_		Prg	Promo_item_		Prm	
	Road_			Rd_	Script_Home_Alt		SHA	Script_Home_Alt_BP	SHB	
	Script_Home_Road	SHR	Script_Pinstripes	SPi	Script_Road_Alt		SRA	
	Script_Road		SRd	Script_Alt		ScA	Script_BP		ScB	
	Script_Canada_Day	ScD	Script_Home		ScH	Script_			Sc_	
	Stadium_		St_	Ticket_stub_		Tkt	Unused_			Un_	
	};

sub getTRL(@) {
    (my ($type, $role, $loc)) = @_;
    my $roleloc      = "${role}_$loc"; $roleloc =~ s/\W/_/;
    return ($typemap{$type}).($rolelocmap{$roleloc});    
}


my %logos = ();
my %ids   = ();
while (my $row = $csv->getline ($csvfile)) {
    my %rec = ();
    @rec{qw{name franchID sl_lgID sl_teamID role type curr beg end loc desc logoIDsl filename referrer url}} = @$row;
    next unless $rec{franchID};

    # OK, we need to make a uniq ID for each franch-dur-typerole-description,
    # formed as franch-dur-typerole-uniqindex
    my $logoType     = &getTRL(@rec{qw{type role loc}});
    my $logoID_root  = "$rec{franchID}$rec{beg}$rec{end}$logoType";
    $ids{$logoID_root}{$rec{desc}} = (scalar keys %{$ids{$logoID_root}}) unless exists($ids{$logoID_root}{$rec{desc}});
    my $idx          =  $ids{$logoID_root}{$rec{desc}};
    my $logoID       = "$logoID_root".$idx;

    # save this record
    $rec{logoType}   = $logoType;
    $rec{logoID}     = $logoID;    
    $rec{idx}        = $idx;    
    $logos{$logoID}  = \%rec;
}
$csvfile->close();

# "franchName","franchID","sl_lgID","sl_teamID","role","type","curr","beg","end","loc","description","logoID","filename","referrer","url"
my %placeholders = (
		'AA'=>    ["American Association",	"_AA","xtra","AA", "Primary","Logo","for", 1882,1891,"","A placeholder logo for the American Association baseball league, active from 1882-1891","_xtra_AA","AA.png","synthesized","../extralogos/AA.png"															],
		'AL'=>    ["American League",		"_AL","53",  "488","Primary","Logo","from",1969,1976,"","An Eagle with banner perched on ringed baseball with 12 stars","1975","American League 1969-1976 - Primary Logo - An Eagle with banner perched on ringed baseball with 12 stars.gif","logo.php?lo=1975","http://sportslogos.net/images/logos/53/488/full/1975.gif"	],
		'FL'=>    ["Federal League",		"_FL","xtra","FL", "Primary","Logo","for", 1914,1915,"","A placeholder logo for the Federal League baseball league, active from 1914-1915","_xtra_FL","FL.png","synthesized","../extralogos/FL.png"	 																	],
		'NA'=>    ["National Association",	"_NA","xtra","NA", "Primary","Logo","for", 1871,1875,"","A placeholder logo for the National Association baseball league, active from 1871-1875","_xtra_NA","NA.png","synthesized","../extralogos/NA.png"															],
		'NL'=>    ["National League",		"_NL","54",  "489","Primary","Logo","from",1969,1992,"","An Eagle with a shield with 12 stars holding a bat and a glove","1984","National League 1969-1992 - Primary Logo - An Eagle with a shield with 12 stars holding a bat and a glove.gif","logo.php?lo=1984","http://sportslogos.net/images/logos/54/489/full/1984.gif"	],
		'PL'=>    ["Players League",		"_PL","xtra","PL", "Primary","Logo","for", 1890,1890,"","A placeholder logo for the Players League baseball league, active from 1890-1890","_xtra_PL","PL.png","synthesized","../extralogos/PL.png"																],
		'UA'=>    ["Union Association", 	"_UA","xtra","UA", "Primary","Logo","for", 1884,1884,"","A placeholder logo for the Union Association baseball league, active from 1884-1884","_xtra_UA","UA.png","synthesized","../extralogos/UA.png"																],
		     );
my $pl_csvfilename  = "$parkinfodir/scripts/parkinfo-sportslogos-placeholder.csv";
my $pl_csv          = Text::CSV_XS->new ({ binary => 1, eol => $/ });
my $pl_csvfile      = new IO::File; $pl_csvfile->open("<$pl_csvfilename")   or die "Can't read from $pl_csvfilename: $!";
while (my $row = $pl_csv->getline ($pl_csvfile)) {
    my %rec = ();
    (my ($franchID,$begMiss,$endMiss,$lgID, $name)) = @$row;
    @rec{qw{name franchID sl_lgID sl_teamID role type curr beg end loc desc logoIDsl filename referrer url}} =
	@{$placeholders{$lgID}};
    @rec{qw{franchID beg end name}} = ($franchID,$begMiss,$endMiss,$name,);

    # synthesize ID
    my $logoType     = &getTRL(@rec{qw{type role loc}});
    my $logoID       = "$rec{franchID}$rec{beg}$rec{end}${logoType}0";
    # save this record
    $rec{logoType}   = $logoType;
    $rec{logoID}     = $logoID;     
    $rec{idx}        = 0;    
    $logos{$logoID}  = \%rec;	
}
$pl_csvfile->close();

my $out_csvfilename  = "$parkinfodir/parkinfo-sportslogos.csv";
my $out_csv          = Text::CSV_XS->new ({ binary => 1, eol => $/ });
my $out_csvfile      = new IO::File; $out_csvfile->open(">$out_csvfilename") or die "Can't read from $out_csvfilename: $!";
my @fields = qw{logoID franchID beg end logoType type role loc idx desc};
my %maxlen = ();
for my $logoID (sort keys %logos) {
    my $logo = $logos{$logoID};

    # track field lengths
    for my $field (@fields) { $maxlen{$field} = length($logo->{$field}) if (($maxlen{$field}||0) < length($logo->{$field})); }

    # copy to sanely-named file
    my $imgfilename = sprintf "%s/images/logos/%s/%s/full/%s", $datadir, $logo->{sl_lgID}, $logo->{sl_teamID}, $logo->{filename};
    # printf "%-45s %s\n", "${logoID}.gif", $imgfilename;
    # print Dumper( $logos{$logoID} );
    copy("$imgfilename","$parkinfodir/data/sportslogos/${logoID}.gif") or die "Copy failed: $!";
    $out_csv->print ($out_csvfile, 
		     [@{$logo}{@fields}]);
}
$out_csvfile->close();

print Dumper(\%maxlen);

print STDERR "Not copying files, uncomment copy line to do this\n";


#    # push @{$ids{$idroot}}, (sprintf "%-22s \"images/logos/%s/%s/full/%s\"", $rec{logoID}, $rec{sl_lgID}, $rec{sl_teamID}, $rec{filename});
