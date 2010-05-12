%default AATSIGNSB    '/data/sn/tw/fixd/objects/a_atsigns_b';
%default FIXEDIDS     '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL      '/data/sn/tw/cool/cool_ppl';
%default COOLOUT      '/data/sn/tw/cool/a_atsigns_b';

-- load ats
AAtsignsBs = LOAD '$AATSIGNSB' AS (
                  rsrc:        chararray,
                  user_a_id:   long,
                  user_b_name: chararray,
                  tweet_id:    long
             );

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
             
CoolPPLZ = LOAD '$COOLPPL' AS (
                screen_name: chararray
           );

CoolPPLOnly = JOIN CoolPPLZ BY screen_name, MatchedIds BY screen_name;
CoolPPLIds  = FOREACH CoolPPLOnly GENERATE
                         MatchedIds::user_id     AS user_id
                         ;             

JoinedAAtsignsBs = JOIN CoolPPLIds BY user_id, AAtsignsBs BY user_a_id;
JustAAtsignsB    = FOREACH JoinedAAtsignsBs GENERATE
                           AAtsignsBs::rsrc        AS rsrc,
                           AAtsignsBs::user_a_id   AS user_a_id,
                           AAtsignsBs::user_b_name AS user_b_name,
                           AAtsignsBs::tweet_id    AS tweet_id
                           ;
rmf $COOLOUT;
STORE JustAAtsignsB INTO '$COOLOUT';
