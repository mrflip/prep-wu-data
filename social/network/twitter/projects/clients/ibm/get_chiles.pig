%default HASHTAGS '/data/sn/tw/fixd/objects/tokens/hashtag'
%default TWIDS    '/data/sn/tw/client/ibm/chile_twids'
        
hashtags = LOAD '$HASHTAGS' AS (rsrc:chararray, tag:chararray, twid:long, tw_usr_id:chararray, crat:long);
cuttags  = FOREACH hashtags GENERATE tag, twid, crat;
chiles   = FILTER cuttags BY tag MATCHES 'chile';
twids    = FOREACH chiles GENERATE twid, crat;

rmf $TWIDS;
STORE twids INTO '$TWIDS';
