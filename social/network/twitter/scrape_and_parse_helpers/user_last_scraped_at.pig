TwitterUser         = LOAD 'fixd/tw/out/twitter_user/part-00002'
  AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long,
      followers_count: long, friends_count: long, statuses_count: long, favorites_count: long, created_at: long);

UserLastScraped_0 = FOREACH TwitterUser GENERATE
  user_id,
  (long)((double)scraped_at / 1000000.0) AS scat
  ;
-- ILLUSTRATE UserLastScraped_0; 

UserLastScraped_1 = GROUP UserLastScraped_0
  BY scat PARALLEL 4
  ;
UserLastScraped_2 = FOREACH UserLastScraped_1 GENERATE
  group  AS scat,
  COUNT(UserLastScraped_0) AS num
  ;

-- ILLUSTRATE UserLastScraped_2 ;

rmf fixd/tw/meta/user_last_scraped_at ;
STORE UserLastScraped_2 INTO 'fixd/tw/meta/user_last_scraped_at';
