AllTriples      = load 'ripd/downloads.dbpedia.org/3.2/en/infobox_en.tsv' AS (subj:chararray, pred:chararray, obj:chararray) ;
AllImages       = load 'ripd/downloads.dbpedia.org/3.2/en/image_en.tsv'   AS (subj:chararray, pred:chararray, obj:chararray) ;

Birds           = FILTER  AllTriples    BY ( pred == 'classis' ) AND ( (obj matches 'bird|Bird|Aves|aves') );
BirdNames       = FOREACH Birds         GENERATE subj ;

BirdPropsF1  = COGROUP BirdNames     BY subj INNER,  AllImages BY subj,      AllTriples by subj;
BirdPropsF   = FOREACH BirdPropsF1   GENERATE group, AllImages.(pred, obj),  AllTriples.(pred, obj) ;
STORE BirdPropsF INTO 'tmp/birds/bird_props_flat' ;

BirdImages1  = JOIN    BirdNames     BY subj, AllImages BY subj;
BirdImages2  = FILTER  BirdImages1   BY (BirdNames::subj IS NOT NULL) ;
BirdImages   = FOREACH BirdImages2   GENERATE AllImages::subj, AllImages::pred, AllImages::obj ;
store BirdImages INTO 'tmp/birds/bird_images' ;

BirdProps1      = JOIN    BirdNames     BY subj, AllTriples BY subj ;
BirdProps2      = FILTER  BirdProps1    BY (BirdNames::subj IS NOT NULL) ;
BirdProps       = FOREACH BirdProps2    GENERATE AllTriples::subj, AllTriples::pred, AllTriples::obj ;
store BirdProps INTO 'tmp/birds/bird_props' ;
