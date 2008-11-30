
-- Unprocess users with more than one page of followers
SELECT COUNT(*), 10000*CEILING(a.priority/10000) AS bin, COUNT(IF(followers_count > 100, 1, NULL)) AS popular
  from twitter_users u, asset_requests a
  WHERE 	u.id = a.twitter_user_id
  AND 		a.user_resource = 'parse' AND a.scraped_time IS NULL
  GROUP BY bin

  

LOAD DATA INFILE "~/ics/pool/social/network/twitter_friends/fixd/dump/imw_twitter_friends-friendships-20081116-dump-ranks.tsv"
      REPLACE INTO TABLE twitter_page_ranks
      FIELDS TERMINATED BY "\t"
      (`prestige`, `twitter_user_id`, `page_rank`)
;

SELECT u.twitter_name, u.following_count, u.followers_count, u.updates_count, pr.page_rank, pr.prestige
  FROM
    (SELECT * FROM twitter_page_ranks  ORDER BY prestige ASC LIMIT 100) pr
  LEFT JOIN users u ON u.id = pr.twitter_user_id
  ORDER BY prestige ASC
;


-- Stages of parsing
SELECT COUNT(*),
       COUNT(last_scraped_date), COUNT(last_scraped_date)/COUNT(*),
       COUNT(native_id), 	 COUNT(native_id)/COUNT(*),
       COUNT(following_count),	 COUNT(following_count)/COUNT(*),
       COUNT(followers_count), 	 COUNT(followers_count)/COUNT(*) 
FROM twitter_users 
