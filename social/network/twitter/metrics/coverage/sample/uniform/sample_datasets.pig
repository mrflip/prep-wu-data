-- Join our newly created "sampled_ids" list with all other objects
sampled_ids            = LOAD '$SAMPLE_DIR/sampled_ids'         AS (uid:long);
tweet                  = LOAD '$TW_DIR/tweet'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
twitter_user_profile   = LOAD '$TW_DIR/twitter_user_profile'  	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);                                                                           
twitter_user_style     = LOAD '$TW_DIR/twitter_user_style'    	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);                         
twitter_user_location  = LOAD '$TW_DIR/twitter_user_location' 	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, location:chararray);                                                                                                                                                                                                          
hashtag                = LOAD '$TW_DIR/hashtag'               	AS (rsrc:chararray, text:chararray, twid:long,             uid:long,     crat:long);                                                           
smiley                 = LOAD '$TW_DIR/smiley'                	AS (rsrc:chararray, text:chararray, twid:long,             uid:long,     crat:long);                                                           
tweet_url              = LOAD '$TW_DIR/tweet_url'             	AS (rsrc:chararray, text:chararray, twid:long,             uid:long,     crat:long);                                                           
stock_token            = LOAD '$TW_DIR/stock_token'           	AS (rsrc:chararray, text:chararray, twid:long,             uid:long,     crat:long);                                                         
word_token             = LOAD '$TW_DIR/word_token'            	AS (rsrc:chararray, text:chararray, twid:long,             uid:long,     crat:long);                                                          
geo                    = LOAD '$TW_DIR/geo'                   	AS (rsrc:chararray, twid:long,      uid:long,              sn:chararray, crat:long,               lat:float,         lon:float,            place_id:chararray);
-- trstrank               = LOAD '$TW_GRAPH/trstrank'              AS (sn:chararray,   uid:long,       rank:float,            tq:int);
-- influencer             = LOAD '$TW_GRAPH/influencer_metrics'    AS (rsrc:chararray, uid:long,       crat:long,             followers:int, fo_o:int, fo_i:int, at_o:int, at_i:int, re_o:int, re_i:int, rt_o:int, rt_i:int, tw_o:int, tw_i:int, ms_tw_o:int, hsh_o:int, sm_o:int, url_o:int, at_tr:int, fo_tr:int);
-- strong_links           = LOAD '$TW_GRAPH/strong_links'          AS (uid:long, sn:chararray, list:chararray);

tweet_s = JOIN tweet BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/tweet
STORE tweet_s INTO '$SAMPLE_DIR/tweet';

twitter_user_profile_s = JOIN twitter_user_profile BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/twitter_user_profile
STORE twitter_user_profile_s INTO '$SAMPLE_DIR/twitter_user_profile';

twitter_user_style_s = JOIN twitter_user_style BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/twitter_user_style
STORE twitter_user_style_s INTO '$SAMPLE_DIR/twitter_user_style';

twitter_user_location_s = JOIN twitter_user_location BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/twitter_user_location
STORE twitter_user_location_s INTO '$SAMPLE_DIR/twitter_user_location';

hashtag_s = JOIN hashtag BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/hashtag
STORE hashtag_s INTO '$SAMPLE_DIR/hashtag';

smiley_s = JOIN smiley BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/smiley
STORE smiley_s INTO '$SAMPLE_DIR/smiley';

tweet_url_s = JOIN tweet_url BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/tweet_url
STORE tweet_url_s INTO '$SAMPLE_DIR/tweet_url';

stock_token_s = JOIN stock_token BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/stock_token
STORE stock_token_s INTO '$SAMPLE_DIR/stock_token';

-- word_token_s = JOIN word_token BY uid, sampled_ids BY uid USING 'replicated';
-- rmf                 $SAMPLE_DIR/word_token
-- STORE word_token_s INTO '$SAMPLE_DIR/word_token';

geo_s = JOIN geo BY uid, sampled_ids BY uid USING 'replicated';
rmf                 $SAMPLE_DIR/geo
STORE geo_s INTO '$SAMPLE_DIR/geo';

-- trstrank_s = JOIN trstrank BY uid, sampled_ids BY uid USING 'replicated';
-- rmf                 $SAMPLE_DIR/trstrank
-- STORE trstrank_s INTO '$SAMPLE_DIR/trstrank';
-- 
-- influencer_s = JOIN influencer BY uid, sampled_ids BY uid USING 'replicated';
-- rmf                 $SAMPLE_DIR/influencer
-- STORE influencer_s INTO '$SAMPLE_DIR/influencer';
-- 
-- strong_links_s = JOIN strong_links BY uid, sampled_ids BY uid USING 'replicated';
-- rmf                 $SAMPLE_DIR/strong_links
-- STORE strong_links_s INTO '$SAMPLE_DIR/strong_links';
