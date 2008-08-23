

-- Tag counts
SELECT t.name AS tag_name, COUNT(*) AS tag_count, tg.* FROM tags t
  LEFT JOIN taggings tg ON t.id = tg.tag_id
  GROUP BY tag_name
  ORDER BY tag_count DESC;


  
SELECT tag_name, SUM(tag_count) AS tag_count, COUNT(*) AS taggers, socialite_name AS head_tagger, tag_count AS head_taggers_count 
  FROM (
    SELECT t.name AS tag_name, COUNT(*) AS tag_count, s.name as socialite_name, tg.* FROM tags t
      LEFT JOIN taggings tg ON t.id = tg.tag_id
      LEFT JOIN socialites s ON tg.socialite_id = s.id
      GROUP BY tag_name, socialite_name
      ORDER BY tag_count DESC
      ) utc
  GROUP BY tag_name
  ORDER BY tag_count DESC
