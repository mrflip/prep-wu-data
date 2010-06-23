/*

Find all replies to a given user (user_id):

$ pig -p USERID=93171197 -p OUTPUT=/data/anal/4stry/beggars/iamjonsi/replies

Output tweet schema is

  created_at, favorited, truncated, reply_to_user_id, reply_to_status_id, text, source, reply_to_screen_name

*/

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

-- default paths
%default TW   '/data/sn/tw/fixd/objects/tweet' 
%default ST   '/data/sn/tw/fixd/objects/search_tweet';

-- load data
tweet        = LOAD '$TW' AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray);
search_tweet = LOAD '$ST' AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_searchid: long, screen_name: chararray, user_searchid: long, iso_language_code: chararray);

-- find matching users' tweets
matching_tweet = FILTER tweet BY repl_user_id MATCHES '$USERID';
matching_search_tweet = FILTER search_tweet BY repl_user_id MATCHES '$USERID';
matching_user_tweet = UNION matching_tweet, matching_search_tweet;
final_tweet = FOREACH matching_user_tweet GENERATE created_at, tw_id, favorited, truncated, repl_user_id, repl_tw_id, text, src, in_reply_to_screen_name;
rmf $OUTPUT
STORE final_tweet INTO '$OUTPUT';