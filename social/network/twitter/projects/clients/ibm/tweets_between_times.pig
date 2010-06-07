REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

%default TW     '/data/sn/tw/fixd/objects/tweet'
%default ST     '/data/sn/tw/fixd/objects/search_tweet'
%default OUTPUT '/data/sn/tw/client/ibm/all_twids';

tweet        = LOAD '$TW' AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray);
search_tweet = LOAD '$ST' AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_searchid: long, screen_name: chararray, user_searchid: long, iso_language_code: chararray);

-- filter tweets by regexp
cut_tweet        = FOREACH tweet GENERATE tw_id, (created_at / 1000000) AS yearmonthday, text;
cut_search_tweet = FOREACH search_tweet GENERATE tw_id, (created_at / 1000000) AS yearmonthday, text;
unioned          = UNION cut_tweet, cut_search_tweet;
between          = FILTER unioned BY ( yearmonthday >= 20100226 ) AND ( yearmonthday <= 20100330 );

rmf                 $OUTPUT;
STORE between INTO '$OUTPUT';
