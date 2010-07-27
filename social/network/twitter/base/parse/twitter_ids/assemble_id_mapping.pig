%default RAW_ID_SNS_FILE  '/tmp/all_seen_users/raw_id_sns'
%default RAW_REL_IDS_FILE '/tmp/all_seen_users/raw_rel_ids'
%default MAPPING          '/tmp/all_seen_users/all_user_info'
        
twitter_user_id      = LOAD '$TW_UID'        AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:long, friends:long, statuses:long, favourites:long, crat:long, sid:long, is_full:long, health:chararray);
twitter_user_sid     = LOAD '$TW_SID' AS (rsrc:chararray, sid:long, sn:chararray);
 
uniq_id_sns          = LOAD '$RAW_ID_SNS_FILE'  AS (uid:long, sn:chararray);
uniq_ids             = LOAD '$RAW_REL_IDS_FILE' AS (uid:long);

all_user_info_j0     = JOIN twitter_user_sid BY sn FULL OUTER, uniq_id_sns BY sn;
all_user_info_f0     = FOREACH all_user_info_j0 GENERATE uid AS uid, twitter_user_sid::sn AS sn, sid AS sid;

all_user_info_j1     = JOIN uniq_ids BY uid FULL OUTER, all_user_info_f0 BY uid;
all_user_info_f1     = FOREACH all_user_info_j1
                       {
                           user_id = (all_user_info_f0::uid IS NOT NULL ? all_user_info_f0::uid : uniq_ids::uid);
                           GENERATE user_id AS uid, sn AS sn, sid AS sid;
                       };
all_user_info_f1     = FILTER all_user_info_f1 BY NOT(uid IS NULL AND sn IS NULL AND sid IS NULL);

SPLIT twitter_user_id INTO
  twitter_user_id_with_id IF (uid IS NOT NULL AND uid != 0L),
  twitter_user_id_with_sn IF (uid IS NULL OR uid == 0L) AND sn IS NOT NULL;

all_user_info_j2     = JOIN all_user_info_f1 BY uid FULL OUTER, twitter_user_id_with_id BY uid;
all_user_info_f2     = FOREACH all_user_info_j2
                       {
                           user_id = (all_user_info_f1::uid IS NOT NULL ? all_user_info_f1::uid : twitter_user_id_with_id::uid);
                           sn      = (all_user_info_f1::sn  IS NOT NULL ? all_user_info_f1::sn  : twitter_user_id_with_id::sn);
                           sid     = (all_user_info_f1::sid IS NOT NULL ? all_user_info_f1::sid : twitter_user_id_with_id::sid);
                           GENERATE user_id AS uid, scrat AS scrat, sn AS sn, prot AS prot, followers AS followers, friends AS friends, statuses AS statuses, favourites AS favourites, crat AS crat, sid AS sid, is_full AS is_full, health AS health;
                       };

all_user_info_j3     = JOIN all_user_info_f2 BY sn FULL OUTER, twitter_user_id_with_sn BY sn;
all_user_info_f3     = FOREACH all_user_info_j3
                       {
                           user_id     = (all_user_info_f2::uid        IS NOT NULL ? all_user_info_f2::uid        : twitter_user_id_with_sn::uid);
                           scraped_at  = (all_user_info_f2::scrat      IS NOT NULL ? all_user_info_f2::scrat      : twitter_user_id_with_sn::scrat);
                           screen_name = (all_user_info_f2::sn         IS NOT NULL ? all_user_info_f2::sn         : twitter_user_id_with_sn::sn);
                           protected   = (all_user_info_f2::prot       IS NOT NULL ? all_user_info_f2::prot       : twitter_user_id_with_sn::prot);
                           followers   = (all_user_info_f2::followers  IS NOT NULL ? all_user_info_f2::followers  : twitter_user_id_with_sn::followers);
                           friends     = (all_user_info_f2::friends    IS NOT NULL ? all_user_info_f2::friends    : twitter_user_id_with_sn::friends);
                           statuses    = (all_user_info_f2::statuses   IS NOT NULL ? all_user_info_f2::statuses   : twitter_user_id_with_sn::statuses);
                           favourites  = (all_user_info_f2::favourites IS NOT NULL ? all_user_info_f2::favourites : twitter_user_id_with_sn::favourites);
                           crat        = (all_user_info_f2::crat       IS NOT NULL ? all_user_info_f2::crat       : twitter_user_id_with_sn::crat);
                           sid         = (all_user_info_f2::sid        IS NOT NULL ? all_user_info_f2::sid        : twitter_user_id_with_sn::sid);
                           is_full     = (all_user_info_f2::is_full    IS NOT NULL ? all_user_info_f2::is_full    : twitter_user_id_with_sn::is_full);
                           health      = (all_user_info_f2::health     IS NOT NULL ? all_user_info_f2::health     : twitter_user_id_with_sn::health);   
                           GENERATE 'twitter_user_id' AS rsrc:chararray, user_id AS uid, scraped_at AS scrat, screen_name AS sn, protected AS prot, followers AS followers, friends AS friends, statuses AS statuses, favourites AS favourites, crat AS crat, sid AS sid, is_full AS is_full, health AS health;
                       };

all_user_info        = ORDER all_user_info_f3 BY scrat ASC, sn ASC, uid ASC;
     
rmf $MAPPING;
STORE all_user_info  INTO '$MAPPING';
