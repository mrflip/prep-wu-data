use `imw_sxsw_panels`

-- -- ***************************************************************************
-- --
-- -- Ideas
-- --
-- --
-- DROP TABLE IF EXISTS  `imw_sxsw_panels`.`ideas`;
-- CREATE TABLE          `imw_sxsw_panels`.`ideas` (
--   `id`                                  INT(10) UNSIGNED                        NOT NULL,
--   `scraped_at`                          DATETIME                                NOT NULL,
--   --
--   `name`                                VARCHAR(255) CHARACTER SET ASCII,		
--   `url`                                 VARCHAR(255) CHARACTER SET ASCII,
--   `org`                                 VARCHAR(255) CHARACTER SET ASCII,		
--   --
--   `level`                               VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
--   `type`                                VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
--   `category`                            VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
--   --
--   `title`                               VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
--   `description`                         VARCHAR(511) CHARACTER SET ASCII,
--   --
--   PRIMARY KEY   (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8
-- ;
-- 
-- -- ***************************************************************************
-- --
-- -- Comments
-- --
-- --
-- DROP TABLE IF EXISTS  `imw_sxsw_panels`.`comments`;
-- CREATE TABLE          `imw_sxsw_panels`.`comments` (
--   `id`                                  INT(10) UNSIGNED                        NOT NULL,
--   `idea_id`                             INT(10) UNSIGNED                        NOT NULL,
--   --
--   `name`                                VARCHAR(255) CHARACTER SET ASCII,		
--   `url`                                 VARCHAR(255) CHARACTER SET ASCII,
--   --
--   `created_at`                          DATETIME                                NOT NULL,
--   `text`                                VARCHAR(511) CHARACTER SET ASCII,
--   --
--   PRIMARY KEY   (`id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8
-- ;



--
DROP TABLE IF EXISTS  `imw_sxsw_panels`.`ideas_twitters`;
CREATE TABLE          `imw_sxsw_panels`.`ideas_twitters` (
  `id`                                  INT(10) UNSIGNED                        NOT NULL,
  `scraped_at`                          DATETIME                                NOT NULL,
  --
  `name`                                VARCHAR(255) CHARACTER SET ASCII,		
  `url`                                 VARCHAR(255) CHARACTER SET ASCII,
  `org`                                 VARCHAR(255) CHARACTER SET ASCII,		
  --
  `level`                               VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `type`                                VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `category`                            VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  --
  `title`                               VARCHAR(255) CHARACTER SET ASCII        NOT NULL,
  `description`                         VARCHAR(511) CHARACTER SET ASCII,
  --
  `twitter_user_id`                     INT(10) UNSIGNED                        NOT NULL,
  `tup_scraped_at`                      DATETIME                                NOT NULL, --
  `tup_name`                            VARCHAR(180) CHARACTER SET ASCII,	
  `tup_url`                             VARCHAR(100) CHARACTER SET ASCII,
  `tup_location`                        VARCHAR(240) CHARACTER SET ASCII,	
  `tup_description`                     VARCHAR(511) CHARACTER SET ASCII,	
  `tup_time_zone`                       VARCHAR(30)  CHARACTER SET ASCII, 
  `tup_utc_offset`                      MEDIUMINT(7),
  --
  `screen_name`				VARCHAR(30)  CHARACTER SET ASCII, 
  PRIMARY KEY   (`id`, `twitter_user_id`),
  INDEX		(`twitter_user_id`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;
