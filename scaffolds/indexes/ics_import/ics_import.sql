

-- ---------------------------------------------------------------------------
--
-- Use this to get the field names
--

SELECT table_name, CONCAT('(', GROUP_CONCAT(column_name SEPARATOR ', '), ') SELECT ', GROUP_CONCAT(CONCAT('t.',column_name) SEPARATOR ', '))
  FROM `information_schema`.`columns` 
  WHERE `table_schema` = 'ics_dev'  
  GROUP BY table_name

-- ---------------------------------------------------------------------------
--
-- Find all datasets with an interesting tag
--
use ics_social_network_delicious;
REPLACE INTO `ics_dev`.datasets
      (delicious_taggings,                  base_trust,                    approved_at,      approved_by,
         uuid,   id,   handle,   created_at,   updated_at,   category,   collection_id,   is_collection,   valuation,   metastats,   facts,   created_by,   updated_by)
SELECT COUNT(*) AS delicious_taggings, 0 AS base_trust, UTC_TIMESTAMP() AS approved_at, 1 AS approved_by, 
       d.uuid, d.id, d.handle, d.created_at, d.updated_at, d.category, d.collection_id, d.is_collection, d.valuation, d.metastats, d.facts, d.created_by, d.updated_by
  FROM          tags t
  LEFT JOIN taggings tg ON t.id = tg.tag_id
  LEFT JOIN datasets d  ON d.id = tg.taggable_id
  WHERE         t.name LIKE '%semantic%'
  GROUP BY      d.id
  ORDER BY 		delicious_taggings DESC
;
use `ics_dev`;
