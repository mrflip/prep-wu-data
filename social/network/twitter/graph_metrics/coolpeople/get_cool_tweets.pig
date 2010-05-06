%default TWEET        '/data/sn/tw/fixd/objects/tweet';
%default FIXEDIDS     '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL      '/data/sn/tw/cool/cool_ppl';
%default COOLOUT      '/data/sn/tw/cool/tweet';

-- load matched ids
MatchedIds = LOAD '$FIXEDIDS' AS (
                  rsrc:             chararray,
                  user_id:          long,
                  scraped_at:       long,
                  screen_name:      chararray,
                  protected:        int,
                  followers_count:  long,
                  friends_count:    long,
                  statuses_count:   long,
                  favourites_count: long,
                  created_at:       long,
                  search_id:        long,
                  is_full:          long,
                  health:           chararray
             );

-- load list of coolios             
CoolPPLZ = LOAD '$COOLPPL' AS (
                screen_name: chararray
           );

CoolPPLOnly = JOIN CoolPPLZ BY screen_name, MatchedIds BY screen_name;
CoolPPLIds  = FOREACH CoolPPLOnly GENERATE
                         MatchedIds::screen_name AS screen_name,
                         MatchedIds::user_id     AS user_id,
                         MatchedIds::search_id   AS search_id
                         ;
                         
-- load tweets
Tweets = LOAD '$TWEET' AS (
                  rsrc:                    chararray,
                  tweet_id:                long,
                  created_at:              long,
                  user_id:                 long,
                  favorited:               long,
                  truncated:               long,
                  in_reply_to_user_id:     long,
                  in_reply_to_status_id:   long,
                  text:                    chararray,
                  source:                  chararray,
                  in_reply_to_screen_name: chararray
         );





JoinedTweets = JOIN CoolPPLIds BY user_id, Tweets BY user_id;
JustTweets   = FOREACH JoinedTweets GENERATE
                       Tweets::rsrc                    AS rsrc,
                       Tweets::tweet_id                AS tweet_id,
                       Tweets::created_at              AS created_at,
                       Tweets::user_id                 AS user_id,
                       Tweets::favorited               AS favorited,
                       Tweets::truncated               AS truncated,
                       Tweets::in_reply_to_user_id     AS in_reply_to_user_id,
                       Tweets::in_reply_to_status_id   AS in_reply_to_status_id,
                       Tweets::text                    AS text,
                       Tweets::source                  AS source,
                       Tweets::in_reply_to_screen_name AS in_reply_to_screen_name              
                       ;


rmf $COOLOUT;
STORE JustTweets INTO '$COOLOUT';
