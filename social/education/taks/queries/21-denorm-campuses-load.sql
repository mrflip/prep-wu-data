
-- ---------------------------------------------------------------------------
--
-- Denormalize campuses by student
--

INSERT IGNORE INTO `taks_rawk`.`student_campus_year` (
	`year`,		`student_id`,	`campus_id`,
	`district`,	`county`,	`region`,
	`campus_type`,	`closed`,	`enrollment`,
	`native`,	`asian`,	`black`,
	`hispanic`,	`white`,
	`min_grade`,	`max_grade` 	)
  SELECT 
	s.year,		s.id, 		c.id,
	c.district,	c.county,	c.region,
	c.campus_type,	c.closed,	c.enrollment,
	c.native,	c.asian,	c.black,
	c.hispanic,	c.white,
	c.min_grade,	c.max_grade
    FROM  	  taks_rawk.students s,
    		  taks_rawk.campuses c
    WHERE 	  s.campus_id  = c.id
      AND 	  s.year       = c.year
  --  LIMIT 200000
;

