
--
-- Look at lengths
--
SELECT COUNT(*), ll.l_bio AS len
  FROM ( SELECT LENGTH(`twitter_name`) 	AS l_twitter_name,
      LENGTH(`real_name`)  		AS l_real_name,
      LENGTH(`location`)  		AS l_location,
      LENGTH(`web`) 			AS l_url,
      LENGTH(`bio`) 			AS l_bio,
      LENGTH(`style_profile_img_url`)  	AS l_pr_url,
      LENGTH(`style_mini_img_url`)  	AS l_mini_url,
      LENGTH(`style_bg_img_url`) 		AS l_bg_url
    FROM `users`
    WHERE 1 ) ll
  GROUP BY len
  ORDER BY len DESC

-- 
-- Fiddle with stuff
--
SELECT LENGTH(`twitter_name`) 	AS l_twitter_name,
      LENGTH(`real_name`)  		AS l_real_name,
      LENGTH(`location`)  		AS l_location,
      LENGTH(`web`) 			AS l_url,
      LENGTH(`bio`) 			AS l_bio,
      LENGTH(`style_profile_img_url`)  	AS l_pr_url,
      LENGTH(`style_mini_img_url`)  	AS l_mini_url,
      LENGTH(`style_bg_img_url`) 	AS l_bg_url, U.*
    FROM `users` U
    WHERE twitter_id IS NOT NULL AND style_mini_img_url IS NOT NULL
    ORDER BY twitter_id  



SELECT u.* 
  FROM users u  
  WHERE    	(0 OR u.parsed IS NOT NULL)
  AND      	(1 OR u.id MOD 1000 = 0) 
  AND 		(u.twitter_name NOT LIKE "\_%")
  ORDER BY 	u.twitter_name 	DESC, 
			IFNULL(u.twitter_ID, 1000000) ASC, 
			u.followers_count DESC
  LIMIT 1000  
