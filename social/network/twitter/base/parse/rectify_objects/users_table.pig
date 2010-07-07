--
-- Gives us a table that maps between user id, screen name, and search id.
-- Use this for rectification of ids in the 'tweet-noid' models, screen names
-- in the tweet models, and ids in the geo models
--
%default SID   '/data/sn/tw/fixd/objects/twitter_user_search_id'
%default USER  '/data/sn/tw/fixd/objects/twitter_user'
%default TABLE '/data/sn/tw/fixd/users_table'

search_id = LOAD '$SID'  AS (rsrc:chararray, sid:long, sn:chararray);
user      = LOAD '$USER' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long);
cut_user  = FOREACH user GENERATE uid, sn;
joined    = JOIN cut_user BY sn FULL OUTER, search_id BY sn;
mapping   = FOREACH joined GENERATE
                search_id::sn  AS sn,
                cut_user::uid  AS uid,
                search_id::sid AS sid
                ;
rmf $TABLE;
STORE mapping INTO '$TABLE';
