
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
