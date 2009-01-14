AFollowsB = load 'fixd/flattened/all/a_follows_b.tsv'		 AS (rsrc:  chararray, a_id: int, b_id: int);
-- BFlwA    = load 'fixd/flattened/all/b_follows_a.tsv'		 AS (rsrc:  chararray, a_id: int, b_id: int);
-- FlwSymm     = load 'fixd/flattened/all/follows_symm.tsv'	 AS (rsrc:  chararray, a_id: int, b_id: int);

Retweet  = load 'fixd/flattened/all/a_retweets_b.tsv'		 AS (rsrc:  chararray, a_id: int, b_id: int, tw_id: int);
Reply    = load 'fixd/flattened/all/a_replies_b'		 AS (rsrc:  chararray, a_id: int, b_id: int, tw_id: int);
Atsign   = load 'fixd/flattened/all/a_atsigns_b.tsv'		 AS (rsrc:  chararray, a_id: int, b_id: int, tw_id: int);
Faves    = load 'fixd/flattened/all/a_favorites_b.tsv'		 AS (rsrc:  chararray, a_id: int, b_id: int, tw_id: int);

TweetUrl = load 'fixd/flattened/all/tweet_url.tsv'		 AS (rsrc:  chararray, url: chararray, tw_id: int, user_id: int);
HashTag  = load 'fixd/flattened/all/hashtag.tsv'		 AS (rsrc:  chararray, url: chararray, tw_id: int, user_id: int);

User     = load 'fixd/flattened/all/twitter_user.tsv'		 AS (rsrc:  chararray, id: int, scraped_at: long, screen_name: chararray, protected: int, followers_count: int, friends_count: int, statuses_count: int, favorites_count: int, created_at: long);
UserPart = load 'fixd/flattened/all/twitter_user_partial.tsv'	 AS (rsrc:  chararray, id: int, scraped_at: long, screen_name: chararray, protected: int, followers_count: int, name: chararray, url: chararray, location: chararray, description: chararray, profile_image_url:chararray);
UserProf = load 'fixd/flattened/all/twitter_user_profile.tsv'	 AS (rsrc:  chararray, id: int, scraped_at: long, screen_name: chararray, protected: int, followers_count: int, friends_count: int, statuses_count: int, favorites_count: int, created_at: long);
UserStl  = load 'fixd/flattened/all/twitter_user_style.tsv'	 AS (rsrc:  chararray, id: int, scraped_at: long, screen_name: chararray, protected: int, followers_count: int, friends_count: int, statuses_count: int, favorites_count: int, created_at: long);

AA = FILTER AFollowsB BY a_id < 1600000 ;
AFB1 = FOREACH AA GENERATE a_id, b_id ;
