#!/usr/bin/env ruby


# ===========================================================================
#
# Pre-existing:
# followers, friends, favorites, tweets count
# duration
#
#

# ===========================================================================
#
# Simple:
#
# date since last tweet
#
# Outgoing Tweets / day
# Incoming Tweets / day
#
# Sampled metrics:
#
# Per tweet: urls, hashtags, @atsigns, twoosh
#
# HSV on color choices
# has image
#
# avg, stdev length of tweet
# update freq
#
# time_zone utc_offset
# * iPhone coordinates

# --
# --
# -- Derived user information
# --
# --
# -- DROP TABLE IF EXISTS  `imw_twitter_graph`.`twitter_user_metrics`;
# -- CREATE TABLE          `imw_twitter_graph`.`twitter_user_metrics` (
# --   `twitter_user_id`                  INT(10) UNSIGNED NOT NULL,
# --   `twitter_user_created_at`          DATETIME,                   -- Denormalized
# --   `updated_at`                       DATETIME,
# --   `tweets_count_at_last_scrape`      MEDIUMINT(10) UNSIGNED,  -- at updated_at
#      -- followers, friends, favorites
# --   `tweet_rate`                       MEDIUMINT(10) UNSIGNED,
# --   `atsigns_count`                    MEDIUMINT(10) UNSIGNED,
# --   `atsigned_count`                   MEDIUMINT(10) UNSIGNED,
# --   `tweet_urls_count`                 MEDIUMINT(10) UNSIGNED,
# --   `hashtags_count`                   MEDIUMINT(10) UNSIGNED,
# --   `twoosh_count`                     MEDIUMINT(10) UNSIGNED,
# --   `prestige`                         INT(10)       UNSIGNED,
# --   `pagerank`                         FLOAT,
# --   `has_image`                        TINYINT(4)    UNSIGNED,
# --   `lat`                              FLOAT,
# --   `lng`                              FLOAT,
# --   PRIMARY KEY  (`twitter_user_id`),
# --   INDEX (`prestige`),
# --   INDEX (`replied_to_count`),
# --   INDEX (`tweeturls_count`)
# -- ) ENGINE=InnoDB DEFAULT CHARSET=ascii
# -- ;


# ===========================================================================
#
# Local graph structure:
#
# * 1-hd, 2-hd
# * for each 1-hd: < follow, friend, #@signs >
# Prestige
#
# * Size of 2-hd
# * Local density (edges between 1-hd members)
# * # of bidirectional links
# * (bidi links) / (follow links)
#
# * influx / outflux of self vs. 1-hd

# ===========================================================================
#
# Corpus analysis
#
# tweets, locations, bios
# , from_clients

# ===========================================================================
#
# Harder to do:
#
# * Geolocation (lat lng)
# * average of metrics in neighborhood
# * image :
#   - dominant color
#   - looks like logo
