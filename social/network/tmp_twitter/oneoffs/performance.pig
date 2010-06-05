

Hashtags = LOAD '/data/sn/tw/fixd/objects/tokens/hashtag' AS (rsrc:chararray, text:chararray, tweet_id:long, screen_name_or_id:chararray, created_at:long);

Hashtags1 = FOREACH Hashtags GENERATE text, (long)((double)created_at / 1000000.0) AS day:long;

HashtagTokensGrouped = GROUP Hashtags1 BY (text, day);
HashtagTokenCounts   = FOREACH HashtagTokensGrouped GENERATE group.text AS text, group.day AS day, COUNT(Hashtags1) AS num ;

rmf    /tmp/oneoffs/performance
STORE HashtagTokenCounts INTO '/tmp/oneoffs/performance';
