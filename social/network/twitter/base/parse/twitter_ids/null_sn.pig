--
-- Pull out all user_ids for which we have no screen name
--
%default TWUID  '/tmp/twitter_user_id'
%default NULLSN '/tmp/id_null_sn'

twitter_user_id = LOAD '$TWUID' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers:int, friends:int, statuses:int, favourites:int, created_at:long, search_id:long, is_full:int, health:chararray);
tw_uid_cut      = FOREACH twitter_user_id GENERATE user_id, screen_name;
tw_uid_no_sn    = FILTER tw_uid_cut BY (user_id IS NOT NULL AND screen_name IS NULL);

rmf $NULLSN;
STORE tw_uid_no_sn INTO '$NULLSN';
