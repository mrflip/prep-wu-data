

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

SELECT GROUP_CONCAT(DISTINCT CONCAT(tag_name, " (", tag_multiplicity, ")") ORDER BY tag_multiplicity DESC SEPARATOR ', ') AS tags,
  sum(tag_multiplicity) AS link_tags_count, tcl.*
  FROM (SELECT COUNT(*) AS tag_multiplicity, t.name AS tag_name, d.*, tg.* FROM taggings tg
    LEFT JOIN delicious_links d ON d.id = tg.delicious_link_id
    LEFT JOIN tags            t ON t.id = tg.tag_id
    GROUP BY d.id, t.id
    ORDER BY d.num_delicious_savers DESC, d.id ASC
    LIMIT 1000) tcl
  GROUP BY delicious_id

SELECT tcl.delicious_id, tcl.num_delicious_savers,
  COUNT(*)  		AS distinct_tags_count, 
  SUM(tag_multiplicity) AS link_tags_count, 
  tcl.link_url, tcl.title,
  GROUP_CONCAT(DISTINCT CONCAT(tag_name, " (", tag_multiplicity, ")") ORDER BY tag_multiplicity DESC SEPARATOR ', ') AS tags
  FROM (
    SELECT COUNT(*) AS tag_multiplicity, t.name AS tag_name, d.delicious_id, d.link_url, d.num_delicious_savers, d.title, tg.delicious_link_id
      FROM 	tags            t 
      LEFT JOIN taggings 	tg ON t.id = tg.tag_id
      LEFT JOIN delicious_links d  ON d.id = tg.delicious_link_id
      GROUP BY t.id, d.id      ) tcl
  WHERE tag_multiplicity > 3
  GROUP BY tcl.delicious_link_id
  ORDER BY tcl.num_delicious_savers DESC, tcl.delicious_link_id ASC

  
--  ORDER BY d.num_delicious_savers DESC, tag_multiplicity DESC, d.id ASC


    SELECT COUNT(*) AS tag_count, t.name AS tag_name, tg.tag_id
      FROM      tags            t 
      LEFT JOIN taggings        tg ON t.id = tg.tag_id
      GROUP BY t.id
      ORDER BY tag_count DESC

    SELECT COUNT(*) AS tag_count, t.name AS tag_name, tg.tag_id
      FROM      tags            t 
      LEFT JOIN taggings        tg ON t.id = tg.tag_id
      GROUP BY t.id      HAVING tag_count >= 4
      ORDER BY tag_count DESC

-- cross join to find all tags that share a link with given tag      
SELECT *
  FROM (SELECT tag_id, delicious_link_id
    FROM  	taggings          tg
    LEFT JOIN delicious_links d  ON d.id = tg.delicious_link_id
    WHERE tg.tag_id = 4696
    GROUP BY tag_id, delicious_link_id
  ) tgd
  LEFT JOIN taggings tg2 ON tgd.delicious_link_id = tg2.delicious_link_id


SELECT tg1.tag_id AS tag_id_1, tg2.tag_id AS tag_id_2, tg1.delicious_link_id, COUNT(*) AS tag_multiplicity
  FROM      taggings tg1 
  LEFT JOIN taggings tg2 ON tg1.delicious_link_id = tg2.delicious_link_id
  WHERE tg1.tag_id = 4696
  GROUP BY tag_id_1, tag_id_2
  ORDER BY tag_id_1, tag_multiplicity, tag_id_2  
