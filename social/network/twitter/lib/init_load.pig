--
-- UDF Stores
--
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

--
-- Twitter Model classes
--

%default TWROOT '/data/sn/tw/fixd/objects'

AFollowsB           = LOAD '$TWROOT/a_follows_b'             AS (rsrc:chararray, user_a_id:long,       user_b_id:   long       );
AAtsignsB_IN        = LOAD '$TWROOT/a_atsigns_b'             AS (rsrc:chararray, user_a_id:long,        user_b_name: chararray, tw_id:long );
-- AAtsignsB_NN     = LOAD '$TWROOT/a_atsigns_b_name'        AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, sid:long );
ARepliesB           = LOAD '$TWROOT/a_replies_b'             AS (rsrc:chararray, user_a_id:long,        user_b_id:   long,      tw_id:long, reply_tw_id:long);
ARepliesB_NN        = LOAD '$TWROOT/a_replies_b_name'        AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, in_re_tw_id:long );
ARetweetsB_IN       = LOAD '$TWROOT/a_retweets_b'            AS (rsrc:chararray, user_a_id:long,        user_b_name: chararray, tw_id:long, rt_whore:long );
-- ARetweetsB_NN    = LOAD '$TWROOT/a_retweets_b_name'       AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, rt_whore:long, sid:long );
AFavoritesB         = LOAD '$TWROOT/a_favorites_b'           AS (rsrc:chararray, user_a_id:long,        user_b_id:   long,      tw_id:long);


TwitterUser         = LOAD '$TWROOT/twitter_user'            AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:long, friends_count:long, statuses_count:long, favorites_count:long, created_at:long);
TwitterUserPartial  = LOAD '$TWROOT/twitter_user_partial'    AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:long, full_name:   chararray, url: chararray, location: chararray, description: chararray, profile_image_url:chararray);
TwitterUserProfile  = LOAD '$TWROOT/twitter_user_profile'    AS (rsrc:chararray, user_id:long, scraped_at:long, full_name:  chararray, url: chararray, location: chararray, description: chararray, time_zone: chararray, utc_offset: long);
TwitterUserStyle    = LOAD '$TWROOT/twitter_user_style'      AS (rsrc:chararray, user_id:long, scraped_at:long, profile_background_color: chararray, profile_text_color: chararray, profile_link_color: chararray, profile_sidebar_border_color: chararray, profile_sidebar_fill_color: chararray, profile_background_tile: long, profile_background_image_url: chararray, profile_image_url: chararray);
TwitterUserId       = LOAD '$TWROOT/twitter_user_id_matched' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:long, friends_count:long, statuses_count:long, favourites_count:long, created_at:long, sid:long, is_full:long, health:chararray);


Tweet               = LOAD '$TWROOT/tweet'                   AS (rsrc:chararray, tw_id:long,   created_at:long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray);
SearchTweet         = LOAD '$TWROOT/search_tweet'            AS (rsrc:chararray, tw_id:long,   created_at:long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_searchid: long, screen_name: chararray, user_searchid: long, iso_language_code: chararray);

TweetUrl            = LOAD '$TWROOT/tweet_url'               AS (rsrc: chararray, url: chararray, tw_id: long, user: chararray, created_at: long);
HashTag             = LOAD '$TWROOT/hashtag'                 AS (rsrc: chararray, url: chararray, tw_id: long, user_id: long);


-- /data/sn/tw/fixd/objects/a_atsigns_b              	    10545565694	         9.8 GB
-- /data/sn/tw/fixd/objects/a_follows_b              	    49128503960	        45.8 GB
-- /data/sn/tw/fixd/objects/a_replies_b              	     7174248598	         6.7 GB
-- /data/sn/tw/fixd/objects/a_replies_b_name         	    24165613334	        22.5 GB
-- /data/sn/tw/fixd/objects/a_retweets_b             	     1740688017	         1.6 GB
--
-- /data/sn/tw/fixd/objects/delete_tweet             	      350139766	       333.9 MB
-- /data/sn/tw/fixd/objects/search_tweet             	   307806433277	       286.7 GB
-- /data/sn/tw/fixd/objects/tweet                    	    95441302437	        88.9 GB
-- /data/sn/tw/fixd/objects/tokens                   	   853229697643	       794.6 GB
-- /data/sn/tw/fixd/objects/tokens/hashtag             	     7640239723	         7.1 GB
-- /data/sn/tw/fixd/objects/tokens/smiley              	     4722574793	         4.4 GB
-- /data/sn/tw/fixd/objects/tokens/smileys_with_tweets 	     4280587055	         4.0 GB
-- /data/sn/tw/fixd/objects/tokens/tweet_url           	    31675623498	        29.5 GB
-- /data/sn/tw/fixd/objects/tokens/word_token          	   804910672574	       749.6 GB
--
-- /data/sn/tw/fixd/objects/twitter_user             	     3291232355	         3.1 GB
-- /data/sn/tw/fixd/objects/twitter_user_id_matched  	     4377217526	         4.1 GB
-- /data/sn/tw/fixd/objects/twitter_user_partial     	      561181429	       535.2 MB
-- /data/sn/tw/fixd/objects/twitter_user_profile     	     4773761352	         4.4 GB
-- /data/sn/tw/fixd/objects/twitter_user_search_id   	     1233543394	         1.1 GB
-- /data/sn/tw/fixd/objects/twitter_user_style       	     9191478220	         8.6 GB
--                                       16 entries    	  1373010642993	         1.2 TB
