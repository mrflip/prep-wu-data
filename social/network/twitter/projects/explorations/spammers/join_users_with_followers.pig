%default USERS 'lists/normal_users_with_tq.tsv'
%default TAB   'lists/twitter_user_id'
%default OUT   'lists/normal_tq_with_followers'
        
users = LOAD '$USERS' AS (sn:chararray, uid:long, raw_rank:float, tq:int);
table = LOAD '$TAB'   AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
cut_table = FOREACH table GENERATE sn, followers;

joined = JOIN users BY sn, cut_table BY sn;
flat   = FOREACH joined GENERATE users::tq, cut_table::followers;

rmf $OUT;
STORE flat INTO '$OUT';
