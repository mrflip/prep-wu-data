-- Get all seen ids, screen names and sids, assemble in one place

-- export PIG_OPTS='-Dio.sort.record.percent=0.38 -Dio.sort.mb=350 -Dio.sort.factor=35 -Dio.sort.spill.percent=0.8 -Dmapred.job.reuse.jvm.num.tasks=-1'

%default TW_DIR      '/data/sn/tw/fixd/objects'

%default A_FOLLOWS_B_FILE   '/data/sn/tw/fixd/objects/a_follows_b,/data/sn/tw/rawd/20100628-20100710/unspliced/a_follows_b'
%default TWEET_FILE         '/data/sn/tw/fixd/objects/tweet,/data/sn/tw/fixd/objects/tweet-no-reply-id,/data/sn/tw/rawd/20100628-20100710/unspliced/tweet'
%default RAW_ID_SNS_FILE    '/tmp/all_seen_users/raw_id_sns'
%default RAW_REL_IDS_FILE   '/tmp/all_seen_users/raw_rel_ids'

a_follows_b          = LOAD '$A_FOLLOWS_B_FILE'   AS (rsrc:chararray, user_a:long, user_b:long);
tweet                = LOAD '$TWEET_FILE' AS (rsrc:chararray, tweet_id:long, crat:long, user_id:long, sn:chararray, sid:long, inre_uid:long, inre_sn:chararray, inre_sid:long, inre_twid:long, text:chararray, src:chararray, lang:chararray, lat:float, lon:float, was_stw:int);
twitter_user_id      = LOAD '$TW_DIR/twitter_user_id' AS (rsrc:chararray, user_id:long, scraped_at:long, sn:chararray, protected:int, followers_count:long, friends_count:long, statuses_count:long, favourites_count:long, created_at:long, sid:long, is_full:long, health:chararray);
twitter_user_sid     = LOAD '$TW_DIR/twitter_user_search_id' AS (rsrc:chararray, sid:long, sn:chararray);
 
-- tw_id_sns            = FOREACH tweet       GENERATE user_id AS user_id, sn AS sn:chararray;
-- re_tws               = FILTER  tweet       BY ((inre_uid IS NOT NULL) OR (inre_sn IS NOT NULL));
-- re_id_sns            = FOREACH re_tws      GENERATE inre_uid AS user_id, inre_sn AS sn:chararray;
-- all_id_sns           = UNION tw_id_sns, re_id_sns;
-- uniq_id_sns          = DISTINCT all_id_sns;
-- rmf                     $RAW_ID_SNS_FILE
-- STORE uniq_id_sns INTO '$RAW_ID_SNS_FILE';
uniq_id_sns          = LOAD '$RAW_ID_SNS_FILE' AS (user_id:long, sn:chararray);

-- fo_i_ids             = FOREACH a_follows_b   GENERATE user_a  AS user_id:long;
-- fo_o_ids             = FOREACH a_follows_b   GENERATE user_b  AS user_id:long;
-- all_rel_ids          = UNION fo_i_ids, fo_o_ids;
-- uniq_ids             = DISTINCT all_rel_ids;
-- rmf                   $RAW_REL_IDS_FILE
-- STORE uniq_ids INTO  '$RAW_REL_IDS_FILE';
uniq_ids             = LOAD '$RAW_REL_IDS_FILE' AS (user_id:long);

all_user_info_j0     = JOIN twitter_user_sid BY sn FULL OUTER, uniq_id_sns BY sn;
all_user_info_f0     = FOREACH all_user_info_j0 GENERATE user_id AS user_id, twitter_user_sid::sn AS sn, sid AS sid ;

all_user_info_j1     = JOIN uniq_ids BY user_id FULL OUTER, all_user_info_f0 BY user_id;
all_user_info_f1     = FOREACH all_user_info_j1 {
    user_id = (all_user_info_f0::user_id IS NOT NULL ? all_user_info_f0::user_id  : uniq_ids::user_id);
    GENERATE user_id AS user_id, sn AS sn, sid AS sid ;
  };
all_user_info_f1     = FILTER all_user_info_f1 BY NOT(user_id IS NULL AND sn IS NULL AND sid IS NULL);

SPLIT twitter_user_id INTO
  twitter_user_id_with_id IF (user_id IS NOT NULL AND user_id != 0L),
  twitter_user_id_with_sn IF (user_id IS NULL     OR  user_id == 0L) AND sn IS NOT NULL;

all_user_info_j2     = JOIN all_user_info_f1 BY user_id FULL OUTER, twitter_user_id_with_id BY user_id;
all_user_info_f2     = FOREACH all_user_info_j2 {
    user_id = (all_user_info_f1::user_id IS NOT NULL ? all_user_info_f1::user_id  : twitter_user_id_with_id::user_id);
    sn      = (all_user_info_f1::sn      IS NOT NULL ? all_user_info_f1::sn       : twitter_user_id_with_id::sn);
    sid     = (all_user_info_f1::sid     IS NOT NULL ? all_user_info_f1::sid      : twitter_user_id_with_id::sid );
    GENERATE user_id AS user_id, scraped_at AS scraped_at, sn AS sn, protected AS protected,
      followers_count AS followers_count, friends_count AS friends_count, statuses_count AS statuses_count, favourites_count AS favourites_count,
      created_at AS created_at, sid AS sid, is_full AS is_full, health AS health ;
  };

all_user_info_j3     = JOIN all_user_info_f2 BY sn FULL OUTER, twitter_user_id_with_sn BY sn;
all_user_info_f3     = FOREACH all_user_info_j3 {
    user_id          = (all_user_info_f2::user_id           IS NOT NULL ? all_user_info_f2::user_id           : twitter_user_id_with_sn::user_id          );
    scraped_at       = (all_user_info_f2::scraped_at        IS NOT NULL ? all_user_info_f2::scraped_at        : twitter_user_id_with_sn::scraped_at       );
    sn               = (all_user_info_f2::sn                IS NOT NULL ? all_user_info_f2::sn                : twitter_user_id_with_sn::sn               );
    protected        = (all_user_info_f2::protected         IS NOT NULL ? all_user_info_f2::protected         : twitter_user_id_with_sn::protected        );
    followers_count  = (all_user_info_f2::followers_count   IS NOT NULL ? all_user_info_f2::followers_count   : twitter_user_id_with_sn::followers_count  );
    friends_count    = (all_user_info_f2::friends_count     IS NOT NULL ? all_user_info_f2::friends_count     : twitter_user_id_with_sn::friends_count    );
    statuses_count   = (all_user_info_f2::statuses_count    IS NOT NULL ? all_user_info_f2::statuses_count    : twitter_user_id_with_sn::statuses_count   );
    favourites_count = (all_user_info_f2::favourites_count  IS NOT NULL ? all_user_info_f2::favourites_count  : twitter_user_id_with_sn::favourites_count );
    created_at       = (all_user_info_f2::created_at        IS NOT NULL ? all_user_info_f2::created_at        : twitter_user_id_with_sn::created_at       );
    sid              = (all_user_info_f2::sid               IS NOT NULL ? all_user_info_f2::sid               : twitter_user_id_with_sn::sid              );
    is_full          = (all_user_info_f2::is_full           IS NOT NULL ? all_user_info_f2::is_full           : twitter_user_id_with_sn::is_full          );
    health           = (all_user_info_f2::health            IS NOT NULL ? all_user_info_f2::health            : twitter_user_id_with_sn::health           );   
    GENERATE 'twitter_user_id' AS rsrc:chararray, user_id AS user_id, scraped_at AS scraped_at, sn AS sn, protected AS protected, followers_count AS followers_count, friends_count AS friends_count, statuses_count AS statuses_count, favourites_count AS favourites_count, created_at AS created_at, sid AS sid, is_full AS is_full, health AS health ;
  };

all_user_info        = ORDER all_user_info_f3 BY scraped_at ASC, sn ASC, user_id ASC;
     
rmf                        /tmp/all_seen_users/all_user_info
STORE all_user_info  INTO '/tmp/all_seen_users/all_user_info';
     
-- -- /data/sn/tw/fixd/objects/a_follows_b                  user_id, user_id     142380303952        132.6 GB
-- -- /data/sn/tw/fixd/objects/tweet                                             515312914023        479.9 GB
-- -- /data/sn/tw/fixd/objects/tweet-no-reply-id                                  13745110276         12.8 GB
-- -- /data/sn/tw/fixd/objects/twitter_user                                        3770338591          3.5 GB
-- -- /data/sn/tw/fixd/objects/twitter_user_search_id                              1575543576          1.5 GB
--
-- /data/sn/tw/fixd/objects/twitter_user_id                                     4433843203          4.1 GB
