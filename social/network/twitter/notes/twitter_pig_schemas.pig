--
-- Use these to load twitter models, stop all that retyping!
--

-- DEFAULT PATHS:

%default FOLLOWS       '/data/sn/tw/fixd/objects/a_follows_b'
%default FAVORITES     '/data/sn/tw/fixd/objects/a_favorites_b'
%default REPLIES       '/data/sn/tw/fixd/objects/a_replies_b'
%default ATSIGNS       '/data/sn/tw/fixd/objects/a_atsigns_b'
%default RETWEETS      '/data/sn/tw/fixd/objects/a_retweets_b'        
%default RETWEETS_NAME '/data/sn/tw/fixd/objects/a_retweets_b_name'
%default ATSIGNS_NAME  '/data/sn/tw/fixd/objects/a_atsigns_b_name'
%default TWEET         '/data/sn/tw/fixd/objects/tweet'        
%default DTWEET        '/data/sn/tw/fixd/objects/delete_tweet'
%default SID           '/data/sn/tw/fixd/objects/twitter_user_search_id'
%default USER          '/data/sn/tw/fixd/objects/twitter_user'
%default PARTIAL       '/data/sn/tw/fixd/objects/twitter_user_partial'
%default PROFILE       '/data/sn/tw/fixd/objects/twitter_user_profile'
%default STYLE         '/data/sn/tw/fixd/objects/twitter_user_style'        
%default USERID        '/data/sn/tw/fixd/objects/twitter_user_id'
%default LOC           '/data/sn/tw/fixd/objects/twitter_user_location'
%default HASHTAG       '/data/sn/tw/fixd/objects/hashtag'
%default SMILEY        '/data/sn/tw/fixd/objects/smiley'
%default URL           '/data/sn/tw/fixd/objects/tweet_url'
%default STOCK         '/data/sn/tw/fixd/objects/stock_token'
%default WORD          '/data/sn/tw/fixd/objects/word_token'                        
%default GEO           '/data/sn/tw/fixd/objects/geo'

-- USERS TABLE        
%default TABLE         '/data/sn/tw/fixd/users_table'
        
-- SCHEMAS
follows       = LOAD '$FOLLOWS'       AS (rsrc:chararray, user_a_id:long, user_b_id:long);
favorites     = LOAD '$FAVORITES'     AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
replies       = LOAD '$REPLIES'       AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    in_reply_to_twid:long);
atsigns       = LOAD '$ATSIGNS'       AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
retweets      = LOAD '$RETWEETS'      AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    plz_flag:int);
retweets_name = LOAD '$RETWEETS_NAME' AS (rsrc:chararray, user_a_id:long, user_b_name:chararray, twid:long,    plz_flag:int);
atsigns_name  = LOAD '$ATSIGNS_NAME'  AS (rsrc:chararray, user_a_id:long, user_b_name:chararray, twid:long);
tweet         = LOAD '$TWEET'         AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
dtweet        = LOAD '$DTWEET'        AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray);                                                                                                                                                                                                          
search_id     = LOAD '$SID'           AS (rsrc:chararray, sid:long,       sn:chararray);                                                                                                                                                                                                                                           
user          = LOAD '$USER'          AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);                                                                             
partial       = LOAD '$PARTIAL'       AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     name:chararray,       url:chararray,                location:chararray,         description:chararray, profile_img_url:chararray);                                       
profile       = LOAD '$PROFILE'       AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);                                                                           
style         = LOAD '$STYLE'         AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);                         
userid        = LOAD '$USERID'        AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
location      = LOAD '$LOC'           AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, location:chararray);                                                                                                                                                                                                          
hashtag       = LOAD '$HASHTAG'       AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
smiley        = LOAD '$SMILEY'        AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
tweet_url     = LOAD '$URL'           AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
stock_token   = LOAD '$STOCK'         AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                         
word_token    = LOAD '$WORD'          AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                          
geo           = LOAD '$GEO'           AS (rsrc:chararray, twid:long,      uid:long,              sn:chararray, crat:long,               lat:float,         lon:float,            place_id:chararray);
mapping       = LOAD '$TABLE'         AS (sn:chararray,   uid:long,       sid:long);
