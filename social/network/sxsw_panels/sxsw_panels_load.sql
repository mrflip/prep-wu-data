use `imw_sxsw_panels`

-- LOAD DATA INFILE '~/ics/pool/social/network/sxsw_panels/fixd/panel_ideas_parsed.tsv'
--   REPLACE INTO TABLE        `imw_sxsw_panels`.`ideas`
--   COLUMNS
--     TERMINATED BY           '\t'
--     OPTIONALLY ENCLOSED BY  ''
--     ESCAPED BY              ''
--   LINES STARTING BY         'panel_idea\t'
--   (id, scraped_at, name, url, org, level, type, category, title, description)
--   ;
-- SELECT 'ideas', NOW(), COUNT(*) FROM `ideas`;
-- 
-- LOAD DATA INFILE '~/ics/pool/social/network/sxsw_panels/fixd/panel_ideas_parsed.tsv'
--   REPLACE INTO TABLE        `imw_sxsw_panels`.`comments`
--   COLUMNS
--     TERMINATED BY           '\t'
--     OPTIONALLY ENCLOSED BY  ''
--     ESCAPED BY              ''
--   LINES STARTING BY         'panel_comment\t'
--   (id, idea_id, name, url, created_at, text)
--   ;
-- SELECT 'comments', NOW(), COUNT(*) FROM `comments`;


LOAD DATA INFILE '~/ics/pool/social/network/sxsw_panels/fixd/matches_name_panel.tsv'
  REPLACE INTO TABLE        `imw_sxsw_panels`.`ideas_twitters`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  ''
    ESCAPED BY              ''
  (id, scraped_at, name, url, org, level, type, category, title, description, twitter_user_id, tup_scraped_at, tup_name, tup_url, tup_location, tup_description, tup_time_zone, tup_utc_offset, screen_name)
  ;
SELECT 'ideas_twitters', NOW(), COUNT(*) FROM `ideas_twitters`;
