--
-- Get raw estimate of tweets in and out for every user (these are estimated from the statuses reported by twitter, NOT observed by us)
--

--
-- PIG_OPTS='-Dmapred.reduce.tasks=X' pig -p TWUID=/path/to/twitter_user_id -p AFB=/path/to/a_follows_b -p TWFLUX=/path/to/output tweet_flux.pig
--

user_id  = LOAD '$TWUID' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
follows  = LOAD '$AFB'   AS (rsrc:chararray, user_a_id:long, user_b_id:long);

senders         = FOREACH user_id GENERATE uid, statuses;
senders_friends = COGROUP senders BY uid INNER, follows BY user_b_id INNER; -- need to get a list of people to send statuses to
receivers       = FOREACH senders_friends GENERATE
                    FLATTEN(follows.user_a_id)  AS receiver_uid,            -- user receiving tweets
                    FLATTEN(senders.statuses)   AS some_tweets_in           -- the tweets received by following user b (needs normalized by time)
                  ;

receivers_tweets_out = COGROUP receivers BY receiver_uid, senders BY uid;
tweet_flux           = FOREACH receivers_tweets_out GENERATE group AS uid, FLATTEN(senders.statuses) AS tweets_out, SUM(receivers.some_tweets_in) AS tweets_in;

STORE tweet_flux INTO '$TWFLUX';

-- LOAD tweet_flux AS (user_id:long, tweets_out:long, tweets_in:long);
