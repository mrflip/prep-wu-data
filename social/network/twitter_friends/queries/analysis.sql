
SELECT u.id, 
	mx.prestige, mx.pagerank, 
	u.created_at, 
	u.followers_count, u.friends_count, u.statuses_count
   FROM 	twitter_users u, twitter_user_metrics mx
   WHERE 	mx.twitter_user_id = u.id 
    AND 		u.followers_count > 1000 
    AND		u.protected = 0
  ORDER BY	u.id


SELECT * 
  FROM (SELECT u.id,
    pagerank, u.screen_name, u.followers_count, u.friends_count, u.statuses_count, 
    ((1.07888 * LOG(followers_count))-18.14) AS pred_logrank, LOG(pagerank) AS logrank
   FROM 	twitter_users u, twitter_user_metrics mx
   WHERE 	mx.twitter_user_id = u.id 
    AND 		u.followers_count > 500
    AND		u.protected = 0
  ORDER BY	mx.pagerank DESC) us
  WHERE ABS(pred_logrank-logrank) > 0.5   


SELECT pred_logrank-logrank AS diff, us.*
  FROM (SELECT u.id, pagerank, u.screen_name, u.followers_count, u.friends_count, u.statuses_count, 
  ((1.07888 * LOG(followers_count))-18.14) AS pred_logrank, LOG(pagerank) AS logrank
   FROM 	twitter_users u, twitter_user_metrics mx
   WHERE 	mx.twitter_user_id = u.id 
    AND 		u.followers_count > 500
    AND		u.protected = 0) us
  WHERE ABS(pred_logrank-logrank) > 0.5 
  ORDER BY	diff DESC


SELECT pred_logrank-logrank AS diff, us.*
  FROM (SELECT u.id, prestige, u.screen_name, u.followers_count, 
  ((1.07888 * LOG(followers_count))-18.14) AS pred_logrank, LOG(pagerank) AS logrank
   FROM 	twitter_user_partials u, twitter_user_metrics mx
   WHERE 	mx.twitter_user_id = u.id 
    AND 		u.followers_count > 500
    AND		u.protected = 0) us
  WHERE ABS(logrank - pred_logrank) > 0.5 
  ORDER BY	diff DESC


  
