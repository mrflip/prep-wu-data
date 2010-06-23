
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

-- default paths
%default TW     '/data/sn/tw/fixd/objects/tweet' 
%default ST     '/data/sn/tw/fixd/objects/search_tweet'
%default USERID  93171197
%default USERSN 'iamjonsi'
%default OUT    '/data/anal/4stry/beggars/iamjonsi/replies'

-- load data
-- !!!NOTE!!! we are loading created_at as a CHARARRAY so that we can use substring to take the month.
tweet        = LOAD '$TW' AS (rsrc:chararray, twid:long, crat:chararray, user_id:long, favorited:long, truncated:long, repl_user_id:long, repl_tw_id:long, text:chararray, src:chararray);
search_tweet = LOAD '$ST' AS (rsrc:chararray, twid:long, crat:chararray, user_id:long, favorited:long, truncated:long, repl_user_id:long, repl_tw_id:long, text:chararray, src:chararray, repl_screen_name:chararray, repl_searchid:long, screen_name:chararray, user_searchid:long, iso_language_code: chararray);

-- find matching users' tweets
cut_tweet             = FOREACH tweet        GENERATE org.apache.pig.piggybank.evaluation.string.SUBSTRING(crat,0,8) AS crat, repl_user_id;
cut_search_tweet      = FOREACH search_tweet GENERATE org.apache.pig.piggybank.evaluation.string.SUBSTRING(crat,0,8) AS crat, repl_screen_name;
matching_tweet        = FILTER cut_tweet        BY repl_user_id == $USERID;
matching_search_tweet = FILTER cut_search_tweet BY repl_screen_name MATCHES '$USERSN';
cut_matching_tweet    = FOREACH matching_tweet GENERATE crat;
cut_matching_stweet   = FOREACH matching_search_tweet GENERATE crat;
matching_user_tweet   = UNION cut_matching_tweet, cut_matching_stweet;
group_user_tweet      = GROUP matching_user_tweet BY crat;
final_tweet           = FOREACH group_user_tweet GENERATE group AS timestamp, COUNT(matching_user_tweet) AS num_twts;

rmf $OUT;
STORE final_tweet INTO '$OUT';
