
-- ***************************************************************************
--
-- Primary user information
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_users`;
CREATE TABLE         `imw_twitter_graph`.`twitter_users` (
  `id`					INT(10) UNSIGNED			NOT NULL, -- at 17_751_380 on 11/30/08
  `screen_name`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  `created_at`				DATETIME				NOT NULL, --
  `statuses_count`			MEDIUMINT(10) UNSIGNED,  	  --
  `followers_count`			MEDIUMINT(10) UNSIGNED,  
  `friends_count`			MEDIUMINT(10) UNSIGNED,  
  `favourites_count`			MEDIUMINT(10) UNSIGNED,  
  `protected`				TINYINT(4),	--
  PRIMARY KEY  	(`id`),
  UNIQUE INDEX 	(`screen_name`),
  INDEX 	(`followers_count`), INDEX (`friends_count`), INDEX (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
-- id      followers_count protected       screen_name name    url     description     location        profile_image_url
--
--
-- Descriptive
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_users_profile`;
CREATE TABLE         `imw_twitter_graph`.`twitter_users_profile` (
  `twitter_user_id`			INT(10) UNSIGNED			NOT NULL,
  `name`				VARCHAR(80)  CHARACTER SET UTF8,
  `url`					VARCHAR(255) CHARACTER SET ASCII,
  `location`				VARCHAR(80)  CHARACTER SET UTF8,
  `description`				TINYTEXT     CHARACTER SET UTF8, 	-- can be 255*4 
  `time_zone`				VARCHAR(255) CHARACTER SET ASCII,	-- can maybe be smaller
  `utc_offset`				MEDIUMINT(7),				-- -43200 to 43200 I think => 9 bits
  PRIMARY KEY  (`twitter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
--
--
-- Style
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_users_style`;
CREATE TABLE         `imw_twitter_graph`.`twitter_users_style` (
  `twitter_user_id`			SMALLINT(5) UNSIGNED			NOT NULL,
  `profile_background_color`		SMALLINT(5) UNSIGNED,
  `profile_text_color`			SMALLINT(5) UNSIGNED,
  `profile_link_color`			SMALLINT(5) UNSIGNED,
  `profile_sidebar_border_color`	SMALLINT(5) UNSIGNED,
  `profile_sidebar_fill_color`		SMALLINT(5) UNSIGNED,
  `profile_background_image_url` 	VARCHAR(300) CHARACTER SET ASCII,
  `profile_image_url`			VARCHAR(300) CHARACTER SET ASCII,
  `profile_background_tile`		SMALLINT(5) UNSIGNED,
  PRIMARY KEY  (`twitter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
--
--
-- Derived user information
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_users_metrics`;
CREATE TABLE          `imw_twitter_graph`.`twitter_users_metrics` (
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

-- ***************************************************************************
--
-- Relationships
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`friendships`;
CREATE TABLE          `imw_twitter_graph`.`friendships` (
  `friend_id`				INT(10) UNSIGNED			NOT NULL,
  `follower_id`				INT(10) UNSIGNED			NOT NULL,
  PRIMARY KEY  (`friend_id`, `follower_id`),
  INDEX 	(`follower_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

--
-- afollowsb	 time  1 0 0 0 0	user_a_id	user_b_id
-- afavoredb	 time  0 1 0 0 0	user_a_id	user_b_id
-- arepliedb	 time  0 0 1 0 0	user_a_id	user_b_id	status_id
-- aatsigndb	 time  0 0 0 1 0	user_a_id	user_b_id	status_id
-- bothfollw	 time  0 0 0 0 1	user_a_id	user_b_id	status_id
--
-- The wacky-assed denormalized boolean columns let you make a weighted graph by
-- combining the sum of each column times that column's weight.
--
-- Also note you can  find symmetric relationships without a JOIN : use a UNION and GROUP BY
-- 
DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_follows_b`;
CREATE TABLE          `imw_twitter_graph`.`a_follows_b` (
  `rel`					ENUM('afollowsb', 'afavoredb', 'arepliedb', 'aatsigndb', 'bothfollw'),
  `user_a_id`				INT(10)	     UNSIGNED			NOT NULL,
  `user_b_id`				INT(10)	     UNSIGNED			NOT NULL,
  `user_a_name`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  `user_b_name`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  INDEX 	(`user_a_id`, `user_b_id`),
  INDEX 	(`user_b_id`),
  INDEX 	(`user_a_name`)
  INDEX 	(`user_b_name`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_atsigns_b`;
CREATE TABLE          `imw_twitter_graph`.`a_atsigns_b` (
  `rel`					ENUM('afollowsb', 'afavoredb', 'arepliedb', 'aatsigndb', 'bothfollw'),
  `user_a_id`				INT(10)	     UNSIGNED			NOT NULL,
  `user_b_id`				INT(10)	     UNSIGNED			NOT NULL,
  `user_a_name`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  `user_b_name`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  `status_id`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  INDEX 	(`user_a_id`, `user_b_id`),
  INDEX 	(`user_b_id`),
  INDEX 	(`status_id`),
  INDEX 	(`user_a_name`)
  INDEX 	(`user_b_name`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_atsigns_b`;
CREATE TABLE          `imw_twitter_graph`.`a_atsigns_b` (
  `rel`					ENUM('afollowsb', 'afavoredb', 'arepliedb', 'aatsigndb', 'bothfollw'),
  `user_a_id`				INT(10)	     UNSIGNED			NOT NULL,
  `user_b_id`				INT(10)	     UNSIGNED			NOT NULL,
  `status_id`				VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  `in_reply_to_status_id`			VARCHAR(50) CHARACTER SET ASCII		NOT NULL, --
  INDEX 	(`user_a_id`, `user_b_id`),
  INDEX 	(`user_b_id`),
  INDEX 	(`status_id`),
  INDEX 	(`user_a_name`)
  INDEX 	(`user_b_name`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;


--   `status_id`				INT(10)	     UNSIGNED			NOT NULL DEFAULT 0,   -- note that twitter is 25% of the way to overflow.
--   `reltime`				DATETIME				NOT NULL,
--   `afollowsb`				TINYINT					DEFAULT NULL, -- boolean
--   `afavoredb`				TINYINT					DEFAULT NULL, -- boolean
--   `arepliedb`				TINYINT					DEFAULT NULL, -- boolean
--   `aatsignb`				TINYINT					DEFAULT NULL, -- boolean
--   `bothfollw`				TINYINT					DEFAULT NULL, -- boolean ?? do we want reverse links too ??
--   PRIMARY KEY  (`rel`, `user_a_id`, `user_b_id`, `status_id`),
--   INDEX 	(`user_a_id`, `user_b_id`),
--   INDEX 	(`user_b_id`),
--   INDEX 	(`status_id`),
--   INDEX 	(`reltime`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=ascii
-- ;
-- 
-- hashtag	 time  1 0 0	user_a_id			status_id	sha1(hashtag)
-- url		 time  0 1 0	user_a_id			status_id	sha1(url)
-- word		 time  0 0 1	user_a_id					sha1(word)
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`text_relationships`;
CREATE TABLE          `imw_twitter_graph`.`text_relationships` (
  `rel`					ENUM('hashtag', 'url', 'word'),
  `user_a_id`				INT(10)	     UNSIGNED			NOT NULL,
  `status_id`				INT(10)	     UNSIGNED,
  `reltime`				DATETIME				NOT NULL,
  `fragment_hash`			BINARY(20)   				NOT NULL,
  `fragment`				VARCHAR(160) CHARACTER SET ASCII	NOT NULL, 	-- have to make sure open text is encoded
  `hashtag`				TINYINT					DEFAULT NULL, 	-- boolean 
  `url`					TINYINT					DEFAULT NULL, 	-- boolean
  `word`				TINYINT					DEFAULT NULL, 	-- not boolean: tinyint.
  PRIMARY KEY  (`rel`, `user_a_id`, `fragment`(25), `status_id`),
  INDEX (`user_a_id`),
  INDEX (`fragment_hash`),
  INDEX (`fragment`(25)),
  INDEX (`reltime`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;


-- ***************************************************************************
--
-- Tweets (statuses)
--
-- Note spelling of favo**U**rite
-- Enforcing that we never see a tweet w/o seeing the whole thing.
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`tweets`;
CREATE TABLE          `imw_twitter_graph`.`tweets` (
  `id`					INT(10) UNSIGNED			NOT NULL,  -- note that twitter is 25% of the way to overflow.
  `created_at`				DATETIME				NOT NULL,
  `twitter_user_id`			INT(10) UNSIGNED			NOT NULL,
  `text`				VARCHAR(160) CHARACTER SET UTF8		NOT NULL,
  `favorited`				TINYINT(4)				NOT NULL,
  `truncated`				TINYINT(4)				NOT NULL,
  `tweet_len`				TINYINT(4)				NOT NULL,
  `in_reply_to_user_id`			INT(10) UNSIGNED			NOT NULL,
  `in_reply_to_status_id`		INT(10) UNSIGNED			NOT NULL,  -- note that twitter is 25% of the way to overflow.
  `fromsource_url`			VARCHAR(255) CHARACTER SET ASCII	NOT NULL,
  `fromsource`				VARCHAR(255) CHARACTER SET ASCII	NOT NULL,
  `all_atsigns`				VARCHAR(255) CHARACTER SET ASCII	NOT NULL,
  `all_hash_tags`			VARCHAR(255) CHARACTER SET ASCII	NOT NULL,
  `all_tweeted`				VARCHAR(255) CHARACTER SET ASCII	NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
--
-- Resolve all the tinyurls, bitlys, snurls, etc.
-- 
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`expanded_urls`;
CREATE TABLE  	      `imw_twitter_graph`.`expanded_urls` (
  `short_url` 				VARCHAR(40) NOT NULL,
  `dest_url` 				VARCHAR(1024) default NULL,
  PRIMARY KEY  (`short_url`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
