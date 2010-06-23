%default DATA '/data/sn/tw/rawd/unspliced/twitter_user_search_id'
%default OUT  '/data/sn/tw/fixd/current-20100622/twitter_user_search_id'

data   = LOAD '$DATA' AS (rsrc:chararray, sid:long, sn:chararray);
uniqed = DISTINCT data PARALLEL 2;
rmf $OUT;
STORE uniqed INTO '$OUT';
