-- use `imw_twitter_graph`
-- LOAD DATA INFILE '~/ics/pool/social/network/twitter_friends/fixd/dump/friendships-20081205-dump-ranks.tsv'
--   INTO TABLE `imw_twitter_graph`.`user_metrics`
--   COLUMNS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
--   LINES STARTING BY 'a_replied_b\t'
--   ;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_users_metrics`;

--
--
-- Derived user information
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`user_metrics`;
CREATE TABLE          `imw_twitter_graph`.`user_metrics` (
  `twitter_user_id`			INT(10) UNSIGNED			NOT NULL,
  `replied_to_count`			MEDIUMINT(10) UNSIGNED,
  `tweeturls_count`			MEDIUMINT(10) UNSIGNED,
  `hashtags_count`			MEDIUMINT(10) UNSIGNED,
  `prestige`				INT(10) UNSIGNED,
  `pagerank`				FLOAT,
  `twoosh_count`			FLOAT,
  PRIMARY KEY  (`twitter_user_id`),
  INDEX (`prestige`),
  INDEX (`replied_to_count`),
  INDEX (`tweeturls_count`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;


use `imw_twitter_graph`
LOAD DATA INFILE '~/ics/pool/social/network/twitter_friends/fixd/dump/friendships-20081205-dump-ranks.tsv'
  REPLACE INTO TABLE `imw_twitter_graph`.`user_metrics`
  COLUMNS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"' ESCAPED BY ''
  (`prestige`, `twitter_user_id`, `pagerank`)
  ;
  
