%default AFOLLOWSB    '/data/sn/tw/fixd/objects/tokens/a_follows_b'
%default AREPLIESB    '/data/sn/tw/fixd/objects/tokens/a_replies_b'
%default AREPLIESBNM  '/data/sn/tw/fixd/objects/tokens/a_replies_b_name'
%default ARETWEETB    '/data/sn/tw/fixd/objects/tokens/a_retweets_b'
%default AATSIGNSBNM  '/data/sn/tw/fixd/objects/tokens/a_atsigns_b_name'
%default ARETWEETSBNM '/data/sn/tw/fixd/objects/tokens/a_retweets_b_name'
%default SEARCHTWEET  '/data/sn/tw/fixd/objects/search_tweet';
%default TWEET        '/data/sn/tw/fixd/objects/tweet';
%default FIXEDIDS     '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL      '/data/sn/tw/sample/cool_ppl';

AFollowBs = LOAD '$AFOLLOWSB' AS (
                  rsrc:             chararray,
                  user_a_id:        long,
                  user_b_id:        long
             );
             

             
ARepliesBs = LOAD '$AREPLIESB' AS (
                  rsrc:                 chararray,
                  user_a_id:            long,
                  user_b_id:            long,
                  tweet_id:             long,
                  in_reply_to_tweet_id: long
             );
             
ARepliesBNames = LOAD '$AREPLIESBNM' AS (
                      rsrc:                 chararray,
                      user_a_name:          chararray,
                      user_b_name:          chararray,
                      tweet_id:             long,
                      in_reply_to_tweet_id: long,
                      user_a_sid:           long,
                      user_b_sid:           long
                 );
                 
-- ARetweetsBs = LOAD '$ARETWEETB' AS (
--                   rsrc:        chararray,
--                   user_a_id:   long,
--                   user_b_name: chararray,
--                   tweet_id:    long,
--                   please_flag: int
--              );
--              
-- ILLUSTRATE ARetweetsBs;

AAtsignsBNames = LOAD '$AATSIGNSBNM' AS (
                      rsrc:        chararray,
                      user_a_name: chararray,
                      user_b_name: chararray,
                      tweet_id:    long,
                      user_a_sid:  long
                 );

ARetweetsBNames = LOAD '$ARETWEETSBNM' AS (
                      rsrc:        chararray,
                      user_a_name: chararray,
                      user_b_name: chararray,
                      tweet_id:    long,
                      please_flag: int,
                      user_a_sid:  long
                 );

-- now, all tokens, etc are loaded, load ids

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


JoinedSearch = JOIN CoolPPLIds BY search_id, SearchTweets BY search_id;
JustSearch   = FOREACH JoinedSearch GENERATE
                       CoolPPLIds::screen_name AS screen_name,
                       SearchTweets::text      AS text
                       ;


JoinedTweets = JOIN CoolPPLIds BY user_id, Tweets BY user_id;
JustTweets   = FOREACH JoinedTweets GENERATE
                       CoolPPLIds::screen_name AS screen_name,
                       Tweets::text            AS text
                       ;


JoinedAFollowsBs = JOIN CoolPPLIds BY user_id, AFollowBs BY user_a_id;
JustAFollowsB    = FOREACH JoinedAFollowsBs GENERATE
                           CoolPPLIds::screen_name AS screen_name,
                           AFollowBs::user_b_id   AS user_b_id
                           ;

DUMP JoinedAFollowsBs;                           
JoinedAAtsignsBs = JOIN CoolPPLIds BY user_id, AAtsignsBs BY user_a_id;
JustAAtsignsB    = FOREACH JoinedAAtsignsBs GENERATE
                           CoolPPLIds::screen_name AS screen_name,
                           AAtsignsBs::user_b_name AS user_b_name
                           ;


JoinedARepliesBs = JOIN CoolPPLIds BY user_id, ARepliesBs BY user_a_id;
JustARepliesB    = FOREACH JoinedARepliesBs GENERATE
                           CoolPPLIds::screen_name AS screen_name,
                           ARepliesBs::user_b_id   AS user_b_id
                           ;

JoinedARepliesBNMs = JOIN CoolPPLIds BY screen_name, ARepliesBNames BY user_a_name;
JustARepliesBNMs   = FOREACH JoinedARepliesBNMs GENERATE
                             CoolPPLIds::screen_name     AS screen_name,
                             ARepliesBNames::user_b_name AS user_b_name
                             ;
                           
JoinedAAtsignsBNMs = JOIN CoolPPLIds BY screen_name, AAtsignsBNames BY user_a_name;
JustAAtsignsBNMs   = FOREACH JoinedAAtsignsBNMs GENERATE
                             CoolPPLIds::screen_name     AS screen_name,
                             AAtsignsBNames::user_b_name AS user_b_name
                             ;

JoinedARetweetsBNMs = JOIN CoolPPLIds BY screen_name, ARetweetsBNames BY user_a_name;
JustARetweetsBNMs   = FOREACH JoinedARetweetsBNMs GENERATE
                             CoolPPLIds::screen_name     AS screen_name,
                             ARetweetsBNames::user_b_name AS user_b_name
                             ;
                             

















Together     = UNION JustSearch, JustTweets;
