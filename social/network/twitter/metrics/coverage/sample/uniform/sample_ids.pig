twitter_user_id     = LOAD '$TWUID' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
twitter_user_id_s   = FILTER twitter_user_id BY ((long)user_id % (long)1000 == 031L); -- should pull out ~1%        
twitter_user_id_cut = FOREACH twitter_user_id_s GENERATE user_id;
STORE twitter_user_id_cut INTO '$SAMPLE';
