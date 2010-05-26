%default SEARCHTWEET  '/data/sn/tw/fixd/objects/search_tweet';
%default FIXEDIDS     '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL      '/data/sn/tw/cool/cool_ppl';
%default COOLOUT      '/data/sn/tw/cool/search_tweet';

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

-- load search tweets  
SearchTweets = LOAD '$SEARCHTWEET' AS (
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
                    in_reply_to_screen_name: chararray,
                    in_reply_to_sid:         long,
                    screen_name:             chararray,
                    search_id:               long,
                    iso_lang_code:           chararray
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
               
JoinedSearch = JOIN SearchTweets BY screen_name, CoolPPLIds BY screen_name using "replicated";
JustSearch   = FOREACH JoinedSearch GENERATE
                       SearchTweets::rsrc                    AS rsrc,
                       SearchTweets::tweet_id                AS tweet_id,
                       SearchTweets::created_at              AS created_at,
                       SearchTweets::user_id                 AS user_id,
                       SearchTweets::favorited               AS favorited,
                       SearchTweets::truncated               AS truncated,
                       SearchTweets::in_reply_to_user_id     AS in_reply_to_user_id,
                       SearchTweets::in_reply_to_status_id   AS in_reply_to_status_id,
                       SearchTweets::text                    AS text,
                       SearchTweets::source                  AS source,
                       SearchTweets::in_reply_to_screen_name AS in_reply_to_screen_name,
                       SearchTweets::in_reply_to_sid         AS in_reply_to_sid,
                       SearchTweets::screen_name             AS screen_name,
                       SearchTweets::search_id               AS search_id,
                       SearchTweets::iso_lang_code           AS iso_lang_code                       
                       ;

rmf $COOLOUT;
STORE JustSearch INTO '$COOLOUT';
                       
