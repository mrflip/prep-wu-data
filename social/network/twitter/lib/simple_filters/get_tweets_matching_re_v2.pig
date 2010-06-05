REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

%default TWROOT '/data/sn/tw/fixd/objects'
%default OUTPUT  '/tmp/volapuk';

Tweet               = LOAD '$TWROOT/tweet'                 AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray);
SearchTweet         = LOAD '$TWROOT/search_tweet'          AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_searchid: long, screen_name: chararray, user_searchid: long, iso_language_code: chararray);

-- filter tweets by regexp
matched = FILTER Tweet
  BY      org.apache.pig.piggybank.evaluation.string.UPPER(text)
  MATCHES '.*(JIIO6JIIO|POCCUU|GEHB|HO4B|PYCCKNN|POCCN[9R][1LI]?|BPEM[9R][1LI]?|NODPYRA|DPY3BR|3DECB|PA6OTA).*' ;

rmf                 $OUTPUT
STORE matched INTO '$OUTPUT' ;
