%default TWROOT '/data/rawd/social/network/twitter/objects'
%default TWUJAN '/data/rawd/social/network/twitter/oneoffs/urls_from_january'

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

TweetUrl        = LOAD '$TWROOT/tweet_url'                   AS (rsrc: chararray, url: chararray, tw_id: long, user: chararray, created_at: chararray);
TweetUrlFromJan = FILTER TweetUrl BY (org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 6) == '201001');
rmf                         $TWUJAN
STORE TweetUrlFromJan INTO '$TWUJAN';
