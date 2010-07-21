%default RAWID '/data/sn/tw/rawd/20100628-20100710/uniqd/raw_ids'
%default TABLE  '/data/sn/tw/fixd/objects/twitter_user_id'
%default TOSCRAPE '/data/sn/tw/rawd/to_scrape/user_ids'
        
id_table = LOAD '$TABLE'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
rawd_id  = LOAD '$RAWID'  AS (uid:long);

just_ids = FOREACH id_table GENERATE uid;
joined   = JOIN rawd_id BY uid FULL OUTER, just_ids BY uid;

rmf $TOSCRAPE;
STORE joined INTO '$TOSCRAPE';
