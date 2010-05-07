%default AREPLIESB    '/data/sn/tw/fixd/objects/a_replies_b'
%default FIXEDIDS     '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL      '/data/sn/tw/cool/cool_ppl';
%default COOLOUT      '/data/sn/tw/cool/a_replies_b';


ARepliesBs = LOAD '$AREPLIESB' AS (
                  rsrc:                 chararray,
                  user_a_id:            long,
                  user_b_id:            long,
                  tweet_id:             long,
                  in_reply_to_tweet_id: long
             );

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

Joined          = JOIN CoolPPLIds BY user_id, ARepliesBs BY user_a_id;
JustARepliesBs = FOREACH Joined GENERATE
                           ARepliesBs::rsrc                 AS rsrc,
                           ARepliesBs::user_a_id            AS user_a_id,
                           ARepliesBs::user_b_id            AS user_b_id,
                           ARepliesBs::tweet_id             AS tweet_id,
                           ARepliesBs::in_reply_to_tweet_id AS in_reply_to_tweet_id                           
                           ;
rmf $COOLOUT;
STORE JustARepliesBs INTO '$COOLOUT';
