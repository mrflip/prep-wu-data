%default AREPLIESBNM  '/data/sn/tw/fixd/objects/a_replies_b_name'
%default FIXEDIDS     '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL      '/data/sn/tw/cool/cool_ppl';
%default COOLOUT      '/data/sn/tw/cool/a_replies_b_name';


ARepliesBNames = LOAD '$AREPLIESBNM' AS (
                      rsrc:                 chararray,
                      user_a_name:          chararray,
                      user_b_name:          chararray,
                      tweet_id:             long,
                      in_reply_to_tweet_id: long,
                      user_a_sid:           long,
                      user_b_sid:           long
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
                         MatchedIds::screen_name AS screen_name,
                         ;             

Joined          = JOIN CoolPPLIds BY screen_name, ARepliesBNames BY user_a_name;
JustARepliesBNames = FOREACH Joined GENERATE
                           ARepliesBNames::rsrc                 AS rsrc,
                           ARepliesBNames::user_a_name          AS user_a_name,
                           ARepliesBNames::user_b_name          AS user_b_name,
                           ARepliesBNames::tweet_id             AS tweet_id,
                           ARepliesBNames::in_reply_to_tweet_id AS in_reply_to_tweet_id,
                           ARepliesBNames::user_a_sid           AS user_a_sid,
                           ARepliesBNames::user_b_sid           AS user_b_sid
                           ;
rmf $COOLOUT;
STORE JustARepliesBNames INTO '$COOLOUT';
