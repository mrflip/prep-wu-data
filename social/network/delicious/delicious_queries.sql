ALTER TABLE `imw_social_network_delicious`.`taggings`
  ADD INDEX link_id_index(`delicious_link_id`, `socialite_id`),
  ADD INDEX socialite_id_index(`socialite_id`);

--
 

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

-- links by tagger/tag
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


CREATE TABLE `link_taggings`
  SELECT tg1.tag_id AS tag_id, tg1.delicious_link_id AS link_id, COUNT(*) AS link_tag_count
    FROM      taggings tg1 
    GROUP BY tag_id, link_id
    ORDER BY tag_id, link_tag_count DESC
;

ALTER TABLE `imw_social_network_delicious`.`link_taggings`
  ADD PRIMARY KEY (`tag_id`, `link_id`),
  ADD INDEX 	  link_id(`link_id`)
  , PACK_KEYS = 1
;

CREATE TABLE `co_taggings`
  SELECT tg1.tag_id AS tag_id_1, tg2.tag_id AS tag_id_2, SUM(tg2.link_tag_count) AS pair_weight, COUNT(*) AS tag_multiplicity
    FROM      link_taggings tg1 
    LEFT JOIN link_taggings tg2     ON (tg1.link_id = tg2.link_id) AND (tg1.tag_id != tg2.tag_id)
    WHERE tg1.link_tag_count > 3 AND tg2.link_tag_count > 3
    GROUP BY  tag_id_1, tag_id_2 
    ORDER BY  pair_weight DESC, tag_multiplicity DESC, tag_id_1 ASC, tag_id_2  

ALTER TABLE `imw_social_network_delicious`.`co_taggings`
  ADD PRIMARY KEY (`tag_id_1`, `tag_id_2`),
  ADD INDEX 	  tag_id_2(`tag_id_2`)
  , PACK_KEYS = 1
;

-- cotags as a table
SELECT t1.name AS tag_name_1, t2.name AS tag_name_2, c.*
  FROM  	co_taggings c
  LEFT JOIN tags        t1 ON c.tag_id_1 = t1.id
  LEFT JOIN tags        t2 ON c.tag_id_2 = t2.id 
  ORDER BY tag_id_1 ASC, pair_weight DESC
-- or concatenated to list
SELECT t1.name AS tag_name, c.tag_id_1 AS tag_id, SUM(c.pair_weight) AS total_pair_weight, SUM(c.tag_multiplicity) AS total_tag_multiplicity,
  GROUP_CONCAT(DISTINCT CONCAT(t2.name, " (", c.pair_weight, ")") ORDER BY c.pair_weight DESC SEPARATOR ', ') AS co_tags
  FROM  	co_taggings c
  LEFT JOIN tags        t1 ON c.tag_id_1 = t1.id
  LEFT JOIN tags        t2 ON c.tag_id_2 = t2.id 
  GROUP BY tag_id
  ORDER BY tag_name ASC, pair_weight DESC

SELECT t.name, tg.*, d.link_url, d.title, d.num_delicious_savers AS savers, t2.name, tg2.*
  FROM tags t
  LEFT JOIN link_taggings   tg  ON tg.tag_id = t.id
  LEFT JOIN delicious_links  d  ON tg.link_id = d.id
  LEFT JOIN link_taggings   tg2 ON tg.link_id = tg2.link_id
  LEFT JOIN tags             t2 ON tg2.tag_id = t2.id
  WHERE t.name = "corpus"
