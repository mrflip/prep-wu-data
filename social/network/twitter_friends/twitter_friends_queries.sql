

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
