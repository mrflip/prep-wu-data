use `imw_twitter_graph`

-- ***************************************************************************
--
-- Primary user information
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_users`;
CREATE TABLE          `imw_twitter_graph`.`twitter_users` (
  `id`                                  INT(10) UNSIGNED                        NOT NULL, -- at 17_751_380 on 11/30/08
  `screen_name`                         VARCHAR(20) CHARACTER SET ASCII         NOT NULL, --
  `created_at`                          DATETIME                                NOT NULL, --
  `statuses_count`                      MEDIUMINT(10) UNSIGNED,           --
  `followers_count`                     MEDIUMINT(10) UNSIGNED,
  `friends_count`                       MEDIUMINT(10) UNSIGNED,
  `favourites_count`                    MEDIUMINT(10) UNSIGNED,
  `protected`                           TINYINT(4)    UNSIGNED, --
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY   (`id`),
  UNIQUE INDEX  (`screen_name`),
  INDEX         (`followers_count`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_user_partials`;
CREATE TABLE          `imw_twitter_graph`.`twitter_user_partials` (
  `id`                                  INT(10) UNSIGNED                        NOT NULL, -- at 17_751_380 on 11/30/08
  `screen_name`                         VARCHAR(20)  CHARACTER SET ASCII        NOT NULL, --
  `followers_count`                     MEDIUMINT(10) UNSIGNED,
  `protected`                           TINYINT(4)    UNSIGNED, --
  `name`                                VARCHAR(80)  CHARACTER SET UTF8,
  `url`                                 VARCHAR(255) CHARACTER SET ASCII,
  `location`                            VARCHAR(80)  CHARACTER SET UTF8,
  `description`                         TINYTEXT     CHARACTER SET UTF8,        -- can be 255*4
  `profile_image_url`                   VARCHAR(300) CHARACTER SET ASCII,
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY   (`id`,          `scraped_at`),
  UNIQUE INDEX  (`screen_name`, `scraped_at`),
  INDEX         (`followers_count`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

-- See histograms.sql : 99.9% of screen_names are <15 chars


-- id      followers_count protected       screen_name name    url     description     location        profile_image_url
--
--
-- Descriptive
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_user_profiles`;
CREATE TABLE          `imw_twitter_graph`.`twitter_user_profiles` (
  `twitter_user_id`                     INT(10) UNSIGNED                        NOT NULL,
  `name`                                VARCHAR(80)  CHARACTER SET UTF8,
  `url`                                 VARCHAR(255) CHARACTER SET ASCII,
  `location`                            VARCHAR(80)  CHARACTER SET UTF8,
  `description`                         TINYTEXT     CHARACTER SET UTF8,        -- can be 255*4
  `time_zone`                           VARCHAR(255) CHARACTER SET ASCII,       -- can maybe be smaller
  `utc_offset`                          MEDIUMINT(7),                           -- -43200 to 43200 I think => 9 bits
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY  (`twitter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

--
--
-- Style
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_user_styles`;
CREATE TABLE          `imw_twitter_graph`.`twitter_user_styles` (
  `twitter_user_id`                     INT(10)  UNSIGNED                       NOT NULL,
  `profile_background_color`            CHAR(6)      CHARACTER SET ASCII,
  `profile_text_color`                  CHAR(6)      CHARACTER SET ASCII,
  `profile_link_color`                  CHAR(6)      CHARACTER SET ASCII,
  `profile_sidebar_border_color`        CHAR(6)      CHARACTER SET ASCII,
  `profile_sidebar_fill_color`          CHAR(6)      CHARACTER SET ASCII,
  `profile_background_image_url`        VARCHAR(300) CHARACTER SET ASCII,
  `profile_image_url`                   VARCHAR(300) CHARACTER SET ASCII,
  `profile_background_tile`             TINYINT(4) UNSIGNED,
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY  (`twitter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;


-- Derived user information
-- -- also followers, friends, favorites, etc from

DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_user_metrics`;
CREATE TABLE          `imw_twitter_graph`.`twitter_user_metrics` (
  `twitter_user_id`                  INT(10) UNSIGNED NOT NULL,
  `twitter_user_created_at`          DATETIME,                   -- Denormalized
  `scraped_at`                       DATETIME,
  `tweets_count_at_last_scrape`      MEDIUMINT(10) UNSIGNED,  -- at updated_at
  `tweet_rate`                       FLOAT,
  `atsigns_count`                    MEDIUMINT(10) UNSIGNED,
  `atsigned_count`                   MEDIUMINT(10) UNSIGNED,
  `tweet_urls_count`                 MEDIUMINT(10) UNSIGNED,
  `hashtags_count`                   MEDIUMINT(10) UNSIGNED,
  `twoosh_count`                     MEDIUMINT(10) UNSIGNED,
  `prestige`                         INT(10)       UNSIGNED,
  `pagerank`                         FLOAT,
  `has_image`                        TINYINT(4)    UNSIGNED,
  `lat`                              FLOAT,
  `lng`                              FLOAT,
  -- # Tweet info on page
  -- property :last_seen_update_time,      DateTime
  -- property :first_seen_update_time,     DateTime
  PRIMARY KEY  (`twitter_user_id`),
  UNIQUE INDEX (`prestige`, `twitter_user_id`)
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
  `id`                                  INT(10) UNSIGNED                        NOT NULL,  -- note that twitter is 25% of the way to overflow.
  `created_at`                          DATETIME                                NOT NULL,
  `twitter_user_id`                     INT(10) UNSIGNED                        NOT NULL,
  `text`                                VARCHAR(160) CHARACTER SET UTF8         NOT NULL,
  `favorited`                           TINYINT(4)   UNSIGNED                   NOT NULL,
  `truncated`                           TINYINT(4)   UNSIGNED                   NOT NULL,
  `tweet_len`                           TINYINT(4)   UNSIGNED                   NOT NULL,
  `in_reply_to_user_id`                 INT(10)      UNSIGNED                   NOT NULL,
  `in_reply_to_status_id`               INT(10)      UNSIGNED                   NOT NULL,  -- note that twitter is 25% of the way to overflow.
  `fromsource`                          VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `fromsource_url`                      VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `all_atsigns`                         VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `all_hash_tags`                       VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `all_tweeted_urls`                    VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY  (`id`),
  INDEX (`created_at`),
  INDEX (`twitter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

-- ***************************************************************************
--
-- Relationships
--
--

--
-- afollowsb     time  1 0 0 0 0        user_a_id       user_b_id
-- afavoredb     time  0 1 0 0 0        user_a_id       user_b_id
-- arepliedb     time  0 0 1 0 0        user_a_id       user_b_id       status_id
-- aatsigndb     time  0 0 0 1 0        user_a_id       user_b_id       status_id
-- bothfollw     time  0 0 0 0 1        user_a_id       user_b_id       status_id
--
-- The wacky-assed denormalized boolean columns let you make a weighted graph by
-- combining the sum of each column times that column's weight.
--
-- Also note you can  find symmetric relationships without a JOIN : use a UNION and GROUP BY
--

DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_follows_bs`;
CREATE TABLE          `imw_twitter_graph`.`a_follows_bs` (
  `user_a_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `user_b_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY   (`user_a_id`,   `user_b_id`),
  INDEX         (`user_b_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_symmetric_bs`;
CREATE TABLE          `imw_twitter_graph`.`a_symmetric_bs` (
  `user_a_id`           INT(10)      UNSIGNED                   NOT NULL,
  `user_b_id`           INT(10)      UNSIGNED                   NOT NULL,
  PRIMARY KEY   (`user_a_id`, `user_b_id`),
  INDEX         (`user_b_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

-- misses "@signs in the same tweet to people with the same first 15 chars of screen_name"
-- extend the primary key if this offends you
DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_atsigns_bs`;
CREATE TABLE          `imw_twitter_graph`.`a_atsigns_bs` (
  `user_a_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `user_b_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `user_b_name`                         VARCHAR(20)  CHARACTER SET ASCII        NOT NULL, --
  `status_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL, --
  PRIMARY KEY   (`user_a_id`, `user_b_name`(20), `status_id`),
  INDEX         (`user_b_name`(15)),
  INDEX         (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`a_replied_bs`;
CREATE TABLE          `imw_twitter_graph`.`a_replied_bs` (
  `user_a_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `user_b_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `user_a_name`                         VARCHAR(20)  CHARACTER SET ASCII        NOT NULL, 
  `status_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `in_reply_to_status_id`               INT(10)      UNSIGNED                   NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL, 
  PRIMARY KEY   (`user_a_id`, `user_b_id`, `status_id`),
  INDEX         (`user_b_id`),
  INDEX         (`status_id`),
  INDEX         (`in_reply_to_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`tweet_urls`;
CREATE TABLE          `imw_twitter_graph`.`tweet_urls` (
  `user_a_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `tweet_url`                           VARCHAR(140) CHARACTER SET ASCII        NOT NULL,       -- have to make sure open text is encoded
  `status_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL, --
  INDEX         (`user_a_id`),
  INDEX         (`status_id`),
  INDEX         (`tweet_url`(40))
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

DROP TABLE IF EXISTS  `imw_twitter_graph`.`hashtags`;
CREATE TABLE          `imw_twitter_graph`.`hashtags` (
  `user_a_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `hashtag`                             VARCHAR(140) CHARACTER SET ASCII        NOT NULL,       -- have to make sure open text is encoded
  `status_id`                           INT(10)      UNSIGNED                   NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL, --
  INDEX         (`user_a_id`),
  INDEX         (`status_id`),
  INDEX         (`hashtag`(30))
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;

-- --
-- -- Resolve all the tinyurls, bitlys, snurls, etc.
-- --
-- --
-- DROP TABLE IF EXISTS  `imw_twitter_graph`.`expanded_urls`;
-- CREATE TABLE          `imw_twitter_graph`.`expanded_urls` (
--   `short_url`                           VARCHAR(60)      CHARACTER SET ASCII    NOT NULL,
--   `dest_url`                            VARCHAR(1024)    CHARACTER SET ASCII    NULL,
--   `scraped_at`                          DATETIME                                NULL,
--   PRIMARY KEY   (`short_url`(40)),
--   INDEX         (`dest_url`(40))
-- ) ENGINE=InnoDB DEFAULT CHARSET=ascii
-- ;

--
-- Data gathering tables
--
--
DROP TABLE IF EXISTS  `imw_twitter_graph`.`scrape_requests`;
CREATE TABLE          `imw_twitter_graph`.`scrape_requests` (
  `id`                                  INTEGER         UNSIGNED AUTO_INCREMENT,
  `priority`                            INTEGER                                 NOT NULL        DEFAULT 0,
  `context`                             VARCHAR(128)                            DEFAULT NULL,
  `uri`                                 VARCHAR(1024)                           DEFAULT NULL,
  `requested_at`                        DATETIME,
  `scraped_at`                          DATETIME,
  `result_code`                         SMALLINT(6)     UNSIGNED,

  `twitter_user_id`                     INT(10)         UNSIGNED                NOT NULL,
  `screen_name`                         VARCHAR(20)                             NOT NULL,
  `page`                                SMALLINT(10)    UNSIGNED                NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX  (`twitter_user_id`, `context`, `page`),
  UNIQUE INDEX  (`screen_name`,     `context`, `page`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;
-- , UNIQUE INDEX (`twitter_user_id`, `context`)


--
-- Data gathering tables
--
-- mode hl user grp size date time filename
DROP TABLE IF EXISTS  `imw_twitter_graph`.`scraped_file_index`;
CREATE TABLE          `imw_twitter_graph`.`scraped_file_index` (
  `filename`                            VARCHAR(255)  CHARACTER SET ASCII       DEFAULT NULL,
  `context`                             VARCHAR(25)   CHARACTER SET ASCII       DEFAULT NULL,
  `size`                                INTEGER,
  `scraped_at`                          DATETIME                                DEFAULT NULL,
  `scrape_session`                      DATE,  
  `screen_name`                         VARCHAR(20)                             NOT NULL,
  `page`                                SMALLINT(10)    UNSIGNED                NOT NULL,
  PRIMARY KEY   (`filename`, `context`),
  INDEX         (`context`,  `scrape_session`),
  UNIQUE INDEX  (`screen_name`, `context`, `page`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii
;


    -- 

-- -- `rel`                                     ENUM('afollowsb', 'afavoredb', 'arepliedb', 'aatsigndb', 'bothfollw'),
-- --   `status_id`                             INT(10)      UNSIGNED                   NOT NULL DEFAULT 0,   -- note that twitter is 25% of the way to overflow.
-- --   `reltime`                               DATETIME                                NOT NULL,
-- --   `afollowsb`                             TINYINT                                 DEFAULT NULL, -- boolean
-- --   `afavoredb`                             TINYINT                                 DEFAULT NULL, -- boolean
-- --   `arepliedb`                             TINYINT                                 DEFAULT NULL, -- boolean
-- --   `aatsignb`                              TINYINT                                 DEFAULT NULL, -- boolean
-- --   `bothfollw`                             TINYINT                                 DEFAULT NULL, -- boolean ?? do we want reverse links too ??
-- --   PRIMARY KEY  (`rel`, `user_a_id`, `user_b_id`, `status_id`),
-- --   INDEX   (`user_a_id`, `user_b_id`),
-- --   INDEX   (`user_b_id`),
-- --   INDEX   (`status_id`),
-- --   INDEX   (`reltime`)
-- -- ) ENGINE=InnoDB DEFAULT CHARSET=ascii
-- -- ;
-- --
-- -- hashtag    time  1 0 0    user_a_id                       status_id       sha1(hashtag)
-- -- url                time  0 1 0    user_a_id                       status_id       sha1(url)
-- -- word               time  0 0 1    user_a_id                                       sha1(word)
-- --
-- DROP TABLE IF EXISTS  `imw_twitter_graph`.`text_relationships`;
-- CREATE TABLE          `imw_twitter_graph`.`text_relationships` (
--   `rel`                                      ENUM('hashtag', 'url', 'word'),
--   `user_a_id`                                INT(10)      UNSIGNED                   NOT NULL,
--   `status_id`                                INT(10)      UNSIGNED,
--   `reltime`                          DATETIME                                NOT NULL,
--   `fragment_hash`                    BINARY(20)                              NOT NULL,
--
--   `hashtag`                          TINYINT                                 DEFAULT NULL,   -- boolean
--   `url`                                      TINYINT                                 DEFAULT NULL,   -- boolean
--   `word`                             TINYINT                                 DEFAULT NULL,   -- not boolean: tinyint.
--   `scraped_at`                               DATETIME                                NOT NULL, --
--   PRIMARY KEY  (`rel`, `user_a_id`, `fragment`(25), `status_id`),
--   INDEX (`user_a_id`),
--   INDEX (`fragment_hash`),
--   INDEX (`fragment`(25)),
--   INDEX (`reltime`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=ascii
-- ;
