



Smiley = LOAD '/data/rawd/social/network/twitter/objects/tokens/smiley' AS (
  rsrc:             chararray,
  emote:            chararray,
  tweet_id:         long,
  screen_name:      chararray,
  created_at:       long
  ) ;

Tweet = LOAD '/data/rawd/social/network/twitter/objects/tweet' AS (
  rsrc:                 chararray,
  id:                   long,
  created_at:           long,
  user_id:              long,
  favorited:            int,
  truncated:            int,
  reply_to_user_id:     long,
  reply_to_status_id:   long,
  text:                 chararray,
  source:               chararray,
  reply_to_screen_name: chararray
  ) ;
  
Joined = JOIN Smiley BY tweet_id, Tweet BY id;

Filtered = FOREACH Joined GENERATE

  Smiley::emote                         AS emote,
  Tweet::text                           AS text
  ;

rmf                      /data/rawd/social/network/twitter/objects/tokens/smileys_with_tweets;
STORE Filtered INTO      '/data/rawd/social/network/twitter/objects/tokens/smileys_with_tweets';
