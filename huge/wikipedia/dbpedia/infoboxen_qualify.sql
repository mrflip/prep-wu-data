-- ***************************************************************************
--
-- A Bunch of tests to quantify the infoboxen tables
--
-- ***************************************************************************

SELECT COUNT(*) AS prop_freq, i.prop
  FROM infoboxen_props i
  GROUP BY i.prop
  ORDER BY prop_freq DESC

SELECT COUNT(*) AS obj_freq, i.obj
  FROM          infoboxen_props i
  GROUP BY      i.obj
  ORDER BY      obj_freq DESC
  INTO OUTFILE '/Users/flip/ics/data/rawd/huge/wikipedia/dbpedia/meta/freq_objs.csv'
    FIELDS TERMINATED   BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES  TERMINATED   BY '\n'
;

-- The tests below were done with an older import that didn't, obviously,
-- depend on the results of those tests

DROP TABLE IF EXISTS 	`unique_templates_full`;
CREATE TEMPORARY TABLE	`unique_templates_full` (
  `id`  	INT(20)		UNSIGNED	NOT NULL AUTO_INCREMENT,
  `name`	TEXT,
  PRIMARY KEY   (`id`)
) SELECT DISTINCT tpls.val AS name
    FROM    	infoboxen tpls
    WHERE   	tpls.property = 'wikiPageUsesTemplate'
    ORDER BY	name
;
   
-- template names are ASCII
SELECT SUBSTR(tpls.name, 10, 67)	AS tpl_name_chopped,
       SUBSTR(tpls.name, 10) 		AS tpl_name,
       CHAR_LENGTH(tpls.name) 		AS tpl_name_char_len,
       LENGTH(tpls.name) 		AS tpl_name_len,
       (CHAR_LENGTH(tpls.name)-LENGTH(tpls.name)) AS bitness
  FROM 		unique_templates_full tpls
  ORDER BY 	bitness DESC
;

-- all the ones longer than 70 are crap
SELECT SUBSTR(tpls.name, 10, 67) 	AS tpl_name_chopped,
       SUBSTR(tpls.name, 10) 		AS tpl_name,
       LENGTH(SUBSTR(tpls.name,10))	AS tpl_name_len
  FROM 		unique_templates_full i
  WHERE 	LENGTH(SUBSTR(tpls.name, 10)) > 66
  ORDER BY 	tpl_name_len DESC
;
-- properties ond object names are ASCII too (returns null result)
SELECT i.property 			AS prop_name,
       i.thing				AS obj_name,
       CHAR_LENGTH(i.property) 		AS prop_name_char_len,
       LENGTH(i.property) 		AS prop_name_len,
       CHAR_LENGTH(i.thing) 		AS obj_name_char_len,
       LENGTH(i.thing)  		AS obj_name_len,
       (CHAR_LENGTH(i.property)-LENGTH(i.property)) AS prop_bitness,
       (CHAR_LENGTH(i.thing)   -LENGTH(i.thing))    AS obj_bitness
  FROM 		infoboxen i
  WHERE 	((CHAR_LENGTH(i.property)-LENGTH(i.property)) != 0)
    OR		((CHAR_LENGTH(i.thing)   -LENGTH(i.thing))    != 0)
  ORDER BY 	obj_bitness DESC
;

-- thing length histogram: they range up to 237, but only a feq are lnger than 150
SELECT LENGTH(i.thing)  	AS obj_name_len,
       COUNT(*)			AS obj_name_freq
  FROM 		infoboxen i
  GROUP BY 	obj_name_len 	
  ORDER BY 	obj_name_len 	DESC
;
SELECT COUNT(*)	AS obj_name_freq  FROM infoboxen i WHERE LENGTH(i.thing)  > 160; --   150
SELECT COUNT(*)	AS obj_name_freq  FROM infoboxen i WHERE LENGTH(i.thing)  > 150; --   348
SELECT COUNT(*)	AS obj_name_freq  FROM infoboxen i WHERE LENGTH(i.thing)  > 140; --  5788
SELECT COUNT(*)	AS obj_name_freq  FROM infoboxen i WHERE LENGTH(i.thing)  > 127; -- 14689

-- property length histogram: only a feq are lnger than 127, and they're mostly crap.
SELECT LENGTH(i.property)  		AS prop_name_len,
       COUNT(*)				AS prop_name_freq
  FROM 		infoboxen i
  GROUP BY 	prop_name_len 	
  ORDER BY 	prop_name_len 	DESC
;
SELECT COUNT(*)	AS prop_name_freq  FROM infoboxen i WHERE LENGTH(i.property) >= 127; --   193
SELECT COUNT(*)	AS prop_name_freq  FROM infoboxen i WHERE LENGTH(i.property) >=  65; -- 19683
SELECT i.property	  		AS prop_name,
       LENGTH(i.property)  		AS prop_name_len
  FROM 		infoboxen i
  WHERE		LENGTH(i.property) >= 120
  ORDER BY 	prop_name_len 	DESC
;

-- ***************************************************************************
--
-- Gather the infoboxen together
--
-- ***************************************************************************

-- Gather and ID all the unique templates
DROP TABLE IF EXISTS 	`unique_templates`;
CREATE TABLE 		`unique_templates` (
  `id`  	INT(20)		UNSIGNED	NOT NULL AUTO_INCREMENT,
  `name`	CHAR(67), 
  PRIMARY KEY   (`id`),
) ENGINE	= MyISAM 
  CHARSET	= ascii
  ROW_FORMAT	= FIXED
  COMMENT	= 'Unique template types'
  SELECT DISTINCT SUBSTR(tpls.val, 10, 67) AS name
    FROM	infoboxen tpls
    WHERE	tpls.property = 'wikiPageUsesTemplate';

  
  
-- Template:template:election_box_candidate_with_party_link

CREATE TABLE `templates_infoboxen` (
  `obj_id`	BIGINT(20)	UNSIGNED	NOT NULL,
  `tpl_id`	BIGINT(20)	UNSIGNED	NOT NULL,
  `tpl_name`	TEXT(70),
  PRIMARY KEY	(`id`),
  KEY		`val`		(`val`(70))
) ENGINE=MyISAM
  CHARSET=ascii
  COMMENT='Templates for each object'
  SELECT
    objs.id 	AS `obj_id`,
    tpls.id	AS `tpl_id`,
    objs.val	AS `tpl_name`,
  FROM infoboxen objs WHERE objs.property = 'wikiPageUsesTemplate'
  

-- SELECT templates.property, cols.property
--   FROM	infoboxen templates
--   LEFT JOIN	infoboxen cols
--  ON	    (cols.thing = templates.thing)
--   WHERE Templates.property = 'wikiPageUsesTemplate'	
--   LIMIT 2000
-- 
-- SELECT templates.property, cols.property
--   FROM	infoboxen templates,
--		infoboxen cols
--   WHERE	Templates.property = 'wikiPageUsesTemplate'  
--	AND	(cols.thing = templates.thing)
--   LIMIT 2000
  
