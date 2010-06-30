--
-- Extract user conversations from a_replies_b, a_retweets_b, a_atsigns_b
--
%default REPLY    '/data/sn/tw/fixd/objects/a_replies_b'
%default ATSIGN   '/data/sn/tw/fixd/objects/a_atsigns_b'
%default RETWEET  '/data/sn/tw/fixd/objects/a_retweets_b'
%default CONV     '/data/sn/tw/fixd/conversations'
        
replies   = LOAD '$REPLY'    AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long, in_reply_to_tweet_id:long);
atsigns   = LOAD '$ATSIGN'   AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long);
retweets  = LOAD '$RETWEET'  AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long, please_flag:int);

grouped_replies        = GROUP replies BY (user_a_id, user_b_id);
reply_conversations    = FOREACH grouped_replies GENERATE
                             FLATTEN(group)                           AS (user_a_id, user_b_id),
                             replies.(tweet_id, in_reply_to_tweet_id) AS twid_list
                         ;

grouped_atsigns        = GROUP atsigns BY (user_a_id, user_b_id);
atsigns_conversations  = FOREACH grouped_atsigns GENERATE
                             FLATTEN(group) AS (user_a_id, user_b_id),
                             atsigns        AS twid_list
                         ;

grouped_retweets       = GROUP retweets (user_a_id, user_b_id);
retweets_conversations = FOREACH grouped_retweets GENERATE
                             FLATTEN(group)    AS (user_a_id, user_b_id),
                             retweets.tweet_id AS twid_list
                         ;

join_one  = JOIN reply_conversations BY (user_a_id, user_b_id) FULL OUTER, atsigns_conversations BY (user_a_id, user_b_id);
flattened = FOREACH join_one
            {
                user_a_id = (reply_conversations::user_a_id IS NOT NULL ? reply_conversations::user_a_id : atsigns_conversations::user_a_id);
                user_b_id = (reply_conversations::user_b_id IS NOT NULL ? reply_conversations::user_b_id : atsigns_conversations::user_b_id);
                GENERATE
                    user_a_id                        AS user_a_id,
                    user_b_id                        AS user_b_id,
                    reply_conversations::twid_list   AS replies_twids,
                    atsigns_conversations::twid_list AS atsigns_twids
                ;
            };

join_two = JOIN flattened BY (user_a_id, user_b_id) FULL OUTER, retweets_conversations BY (user_a_id, user_b_id);
flattened_two = FOREACH join_two
                {
                    user_a_id = (flattened::user_a_id IS NOT NULL ? flattened::user_a_id : retweets::user_a_id);
                    user_b_id = (flattened::user_b_id IS NOT NULL ? flattened::user_b_id : retweets::user_b_id);
                    GENERATE
                        user_a_id                         AS user_a_id,
                        user_b_id                         AS user_b_id,
                        flattened::replies_twids          AS replies_twids,
                        flattened::atsigns_twids          AS atsigns_twids,
                        retweets_conversations::twid_list AS retweets_twids
                    ;
                };
rmf $CONV;
STORE flattened_two INTO '$CONV';
