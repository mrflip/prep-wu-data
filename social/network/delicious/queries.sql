---------------------------------------------------------------------------
--
-- tag counts
-- 

SELECT COUNT(*) AS tagged_count, t.*
  FROM 		tags t 
  LEFT JOIN 	taggings tg ON tg.tag_id = t.id
  WHERE 	t.name LIKE '%data%'
    OR 		t.name LIKE '%stats%'
    OR 		t.name LIKE '%statistic%'
    OR 		t.name LIKE '%semantic%'
  GROUP BY 	t.id
  ORDER BY 	tagged_count DESC, t.name
;


---------------------------------------------------------------------------
--
-- datasets by tags
-- 
SELECT d.*, COUNT(*) AS tagging_count, t.name
  FROM 		tags t 
  LEFT JOIN taggings tg ON tg.tag_id = t.id
  LEFT JOIN datasets d  ON tg.taggable_id = d.id
  WHERE 	t.name LIKE '%source%'
  GROUP BY 	d.id
  ORDER BY 	tagging_count DESC, t.name
;
---------------------------------------------------------------------------
--
-- processed
-- 

SELECT p.context, COUNT(*) FROM processings p GROUP BY context;
;
---------------------------------------------------------------------------
--
-- Assets without 'name' set
-- 

SELECT  d.id AS dataset_id, d.handle AS full_url, MD5(d.handle) AS delicious_link_id,
        d.name AS asset_name, la.*
  FROM          datasets d
  LEFT JOIN     link_assets la ON la.full_url LIKE CONCAT('%',MD5(d.handle),'%')
  WHERE la.id    IS NOT NULL
    AND la.name  = ''   
;
---------------------------------------------------------------------------
--
-- Tags that go with the obvious '%data%', '%stats%', '%statistic%'
-- 

-- tag, tagger and datasets for a given tag
SELECT t.name AS tag_name, tg.tagger_id, c.name AS contributor, d.*
  FROM 		datasets d
  LEFT JOIN	taggings tg ON d.id = tg.taggable_id
  LEFT JOIN	tags     t  ON t.id = tg.tag_id
  LEFT JOIN	contributors c ON c.id = tg.tagger_id
  WHERE 	t.name = 'datasource'
  ORDER BY 	d.name;
;
-- Tags that go with a a given tag set

SELECT COUNT(*) AS multiplicity, t.name, GROUP_CONCAT(dd.id)
  FROM (SELECT d.id
    FROM 		datasets d
    LEFT JOIN	taggings tg ON d.id = tg.taggable_id
    LEFT JOIN	tags     t  ON t.id = tg.tag_id
    WHERE 		t.name LIKE '%data%'
      OR 		t.name LIKE '%stats%'
      OR 		t.name LIKE '%statistic%'
    GROUP BY 	d.id) dd
  LEFT JOIN 	taggings tg ON dd.id = tg.taggable_id
  LEFT JOIN 	tags     t  ON t.id = tg.tag_id
  GROUP BY      t.name
  ORDER BY 		multiplicity DESC
;
-- tags & their datasets into a separate table

DROP TABLE foo_assoc_tags;
;
-- among datasets found by ((t.name LIKE '%data%') OR (t.name LIKE '%stats%') OR (t.name LIKE '%statistic%'))
-- find all tags attached to each dataset
CREATE TABLE foo_assoc_tags 
  SELECT t.id AS tag_id, dd.id AS dataset_id, t.name AS tag_name, COUNT(*) AS affinity
  FROM (SELECT d.id
    FROM 		datasets d
    LEFT JOIN	taggings tg ON d.id = tg.taggable_id
    LEFT JOIN	tags     t  ON t.id = tg.tag_id
    WHERE 	((t.name LIKE '%data%') OR (t.name LIKE '%stats%') OR (t.name LIKE '%statistic%'))
    GROUP BY 	d.id) dd
  LEFT JOIN 	taggings tg ON dd.id = tg.taggable_id
  LEFT JOIN 	tags     t  ON t.id = tg.tag_id
  GROUP BY      t.id, dd.id
  ORDER BY 	t.name
;

-- for datasets in the big 3 clique, here are tags not in the big 3, and their popularity
    SELECT f.tag_id AS id, f.tag_name AS tag_name, COUNT(*) AS tagged_count, SUM(affinity) AS multiplicity
      FROM 	foo_assoc_tags f
      WHERE 	NOT ((tag_name LIKE '%data%') OR (tag_name LIKE '%stats%') OR (tag_name LIKE '%statistic%'))
      GROUP BY 	tag_id HAVING multiplicity > 15
      ORDER BY  multiplicity DESC
;;


-- here are datasets having any of those tags

CREATE TEMPORARY TABLE foo_assoc_datasets
  SELECT d.id
    FROM (
    SELECT f.tag_id AS id, f.tag_name AS tag_name, COUNT(*) AS tagged_count, SUM(affinity) AS multiplicity
      FROM 	foo_assoc_tags f
      WHERE 	NOT ((tag_name LIKE '%data%') OR (tag_name LIKE '%stats%') OR (tag_name LIKE '%statistic%'))
      GROUP BY 	tag_id HAVING multiplicity > 15
      ORDER BY  multiplicity DESC
      ) ta
    LEFT JOIN 	taggings tg ON ta.id = tg.tag_id
    LEFT JOIN	datasets d  ON d.id  = tg.taggable_id
    GROUP BY d.id

-- here are datasets having any of those tags, but a tagging only when the tagging is in the big 3

CREATE TEMPORARY TABLE foo_missing
  SELECT COUNT(DISTINCT IFNULL(t.id,-1)) AS nullity, GROUP_CONCAT(DISTINCT t.name) AS tags_list, da.id AS ds_id
    FROM 	foo_assoc_datasets da
    LEFT JOIN 	taggings tg ON da.id = tg.taggable_id
    LEFT JOIN   tags 	 t  ON t.id  = tg.tag_id AND ((t.name LIKE '%data%') OR (t.name LIKE '%stats%') OR (t.name LIKE '%statistic%'))
    GROUP BY da.id


-- -- tag counts among this clique
-- 
-- SELECT COUNT(*) AS full_mult, f.* 
-- FROM foo_assoc_tags f
--   GROUP BY 	tag_id
--   ORDER BY	full_mult DESC
-- ;
-- -- tag-associated datasets with their tags_list
-- 
-- SELECT COUNT(*) AS full_mult, f.*, 
-- 	GROUP_CONCAT(CONCAT(f.tag_name, '(', f.affinity, ')') ORDER BY affinity DESC) AS tags_list, 
-- 	d.* 
--   FROM 		foo_assoc_tags f
--   LEFT JOIN	datasets d ON d.id = f.dataset_id
--   GROUP BY 	dataset_id
--   ORDER BY	full_mult DESC
--;
-- tag-associated datasets that aren't found by the big 3 (they're the ones with nullity == 1


-- Neighbor tags for a given tag

SELECT IF(t2.name LIKE '%data%', t2.name, NULL) AS big3t, t2.name AS tag_name, t2.id AS tag_id, COUNT(*) AS affinity, sd.* 
  FROM
  ( SELECT count(*) AS multiplicity, d.id AS dataset_id, d.handle, d.name AS dataset_name
      FROM taggings tg
  	  LEFT JOIN tags t ON t.id = tg.tag_id
  	  LEFT JOIN datasets d ON d.id = tg.taggable_id
	  WHERE t.name LIKE  '%semantic%'
	  GROUP BY d.id
	  ORDER BY multiplicity DESC, d.id ) sd
  LEFT JOIN taggings tg2 	ON sd. dataset_id = tg2.taggable_id
  LEFT JOIN tags t2 		ON t2.id = tg2.tag_id
  GROUP BY	t2.id, sd.dataset_id
  ORDER BY  sd.dataset_id, affinity DESC
