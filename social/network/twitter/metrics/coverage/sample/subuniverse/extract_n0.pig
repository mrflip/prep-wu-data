%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'                   
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/mrflip'
%default FLP_ID    '1554031L'  -- @mrflip
%default ICS_ID    '15748351L' -- @infochimps
%default HDP_ID    '19041500L' -- @hadoop
%default CLD_ID    '16134540L' -- @cloudera
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

-- SCHEMAS
a_follows_b            = LOAD '$TW_OBJ_PATH/a_follows_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_favorites_b          = LOAD '$TW_OBJ_PATH/a_favorites_b'         	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
a_replies_b            = LOAD '$TW_OBJ_PATH/a_replies_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    in_re_twid:long);
a_atsigns_b            = LOAD '$TW_OBJ_PATH/a_atsigns_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
a_retweets_b           = LOAD '$TW_OBJ_PATH/a_retweets_b'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    plz_flag:int);
a_retweets_b_name      = LOAD '$TW_OBJ_PATH/a_retweets_b_name'     	AS (rsrc:chararray, user_a_id:long, user_b_name:chararray, twid:long,    plz_flag:int);
a_atsigns_b_name       = LOAD '$TW_OBJ_PATH/a_atsigns_b_name'      	AS (rsrc:chararray, user_a_id:long, user_b_name:chararray, twid:long);
tweet                  = LOAD '$TW_OBJ_PATH/tweet'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
delete_tweet           = LOAD '$TW_OBJ_PATH/delete_tweet'          	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray);                                                                                                                                                                                                          
twitter_user_search_id = LOAD '$TW_OBJ_PATH/twitter_user_search_id'	AS (rsrc:chararray, sid:long,       sn:chararray);                                                                                                                                                                                                                                           
twitter_user           = LOAD '$TW_OBJ_PATH/twitter_user'          	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);                                                                             
twitter_user_partial   = LOAD '$TW_OBJ_PATH/twitter_user_partial'  	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     name:chararray,       url:chararray,                location:chararray,         description:chararray, profile_img_url:chararray);                                       
twitter_user_profile   = LOAD '$TW_OBJ_PATH/twitter_user_profile'  	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);                                                                           
twitter_user_style     = LOAD '$TW_OBJ_PATH/twitter_user_style'    	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);                         
twitter_user_id        = LOAD '$TW_OBJ_PATH/twitter_user_id'       	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
twitter_user_location  = LOAD '$TW_OBJ_PATH/twitter_user_location' 	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, location:chararray);                                                                                                                                                                                                          
hashtag                = LOAD '$TW_OBJ_PATH/hashtag'               	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
smiley                 = LOAD '$TW_OBJ_PATH/smiley'                	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
tweet_url              = LOAD '$TW_OBJ_PATH/tweet_url'             	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
stock_token            = LOAD '$TW_OBJ_PATH/stock_token'           	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                         
word_token             = LOAD '$TW_OBJ_PATH/word_token'            	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                          
geo                    = LOAD '$TW_OBJ_PATH/geo'                   	AS (rsrc:chararray, twid:long,      uid:long,              sn:chararray, crat:long,               lat:float,         lon:float,            place_id:chararray);

-- Extract all atsign edges that originate or terminate on the seed (n1)
a_atsigns_b_s  = FILTER a_atsigns_b BY
     (user_a_id == $FLP_ID) OR (user_b_id == $FLP_ID) 
  -- (user_a_id == $ICS_ID) OR (user_b_id == $ICS_ID) OR
  -- (user_a_id == $HDP_ID) OR (user_b_id == $HDP_ID) OR
  -- (user_a_id == $CLD_ID) OR (user_b_id == $CLD_ID)
  ;
-- a_atsigns_b_s = ORDER a_atsigns_b_f BY user_a_id, user_b_id PARALLEL 1;
rmf                            $NBRHOOD_PATH/a_atsigns_b  
STORE a_atsigns_b_s      INTO '$NBRHOOD_PATH/a_atsigns_b';  
 
-- Extract all follow edges that originate or terminate on the seed (n1)
a_follows_b_s  = FILTER a_follows_b BY
     (user_a_id == $FLP_ID) OR (user_b_id == $FLP_ID) 
  -- (user_a_id == $ICS_ID) OR (user_b_id == $ICS_ID) OR
  -- (user_a_id == $HDP_ID) OR (user_b_id == $HDP_ID) OR
  -- (user_a_id == $CLD_ID) OR (user_b_id == $CLD_ID)
  ;
-- a_follows_b_s = ORDER a_follows_b_f BY user_a_id, user_b_id PARALLEL 1;
rmf                            $NBRHOOD_PATH/a_follows_b  
STORE a_follows_b_s      INTO '$NBRHOOD_PATH/a_follows_b';  

-- -- Extract all tweets from, to, or mentioning on the seed (n1)
-- tweet_s   = FILTER tweet BY
--   (org.apache.pig.piggybank.evaluation.string.UPPER(text) MATCHES '.*\\b(HADOOP|INFOCHIMPS?|CLOUDERA|BIG.?DATA)\\b.*') OR
--   (uid == $ICS_ID) OR (in_re_uid == $ICS_ID) OR 
--   (uid == $HDP_ID) OR (in_re_uid == $HDP_ID) OR 
--   (uid == $CLD_ID) OR (in_re_uid == $CLD_ID) 
--   ;
-- rmf                            $NBRHOOD_PATH/tweet
-- STORE tweet_s            INTO '$NBRHOOD_PATH/tweet';

a_follows_b_s          = LOAD '$NBRHOOD_PATH/a_follows_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_atsigns_b_s          = LOAD '$NBRHOOD_PATH/a_atsigns_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
tweet_s                = LOAD '$NBRHOOD_PATH/tweet'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);

--
-- Isolate all user id's in the subuniverse
--

at_u_a  = FOREACH a_atsigns_b_s GENERATE user_a_id AS user_id;
at_u_b  = FOREACH a_atsigns_b_s GENERATE user_b_id AS user_id;
fo_u_a  = FOREACH a_follows_b_s GENERATE user_a_id AS user_id;
fo_u_b  = FOREACH a_follows_b_s GENERATE user_b_id AS user_id;
-- tw_u    = FOREACH tweet_s       GENERATE uid       AS user_id;
-- tw_u_re = FOREACH tweet_s       GENERATE in_re_uid AS user_id;

user_ids_u = UNION at_u_a, at_u_b, fo_u_a --, fo_u_b
  ;
user_ids   = DISTINCT user_ids_u PARALLEL 1 ;
rmf                            $NBRHOOD_PATH/n1
STORE user_ids           INTO '$NBRHOOD_PATH/n1';
user_ids               = LOAD '$NBRHOOD_PATH/n1'                 	AS (user_id:long);

twitter_user_j  = JOIN twitter_user BY uid, user_ids BY user_id USING "REPLICATED";
twitter_user_s  = FOREACH twitter_user_j GENERATE rsrc, uid, scrat, sn, prot, followers, friends, statuses, favs, crat ;
rmf                            $NBRHOOD_PATH/twitter_user
STORE twitter_user_s     INTO '$NBRHOOD_PATH/twitter_user';
twitter_user_s         = LOAD '$NBRHOOD_PATH/twitter_user'          	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);                                                                             

-- rsrc	uid	scrat	sn	prot	followers	friends	statuses	favs	crat
