
-- ---------------------------------------------------------------------------
--
-- Copy campuses from taks to taks_rawk
--

INSERT IGNORE INTO `taks_rawk`.`campuses` (
	`year`,		`id`,
	`district`,	`county`,	`region`,
	`campus_type`,	`closed`,	`enrollment`,
	`native`,	`asian`,	`black`,
	`hispanic`,	`white`,
	`min_grade`,	`max_grade` 	)
  SELECT 
	c.year,		c.campus,
	c.district,	c.county,	c.region,
	c.campus_type,	c.closed,	c.enrollment,
	c.native,	c.asian,	c.black,
	c.hispanic,	c.white,
	c.min_grade,	c.max_grade
    FROM  	  taks.campuses c
    WHERE 	  c.closed  = 0
-- LIMIT 200000
;
SELECT COUNT(*) AS num_campuses FROM `taks_rawk`.`campuses`;
