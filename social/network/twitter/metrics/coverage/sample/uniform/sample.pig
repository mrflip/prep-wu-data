-- Generates a consistent sample
%default INV_SAMPLE_FRACTION '100L'

twitter_user_id   = LOAD '$TW_DIR/twitter_user_id' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:long, friends_count:long, statuses_count:long, favourites_count:long, created_at:long, sid:long, is_full:long, health:chararray);
twitter_user_id_s = FILTER twitter_user_id BY (user_id % (long)$INV_SAMPLE_FRACTION == 20L); -- should pull out ~1%
        
STORE twitter_user_id_s INTO '$SAMPLE_DIR/twitter_user_id';

twitter_user_id_cut = FOREACH twitter_user_id_s GENERATE user_id;

STORE twitter_user_id_cut INTO '$SAMPLE_DIR/sampled_ids';
