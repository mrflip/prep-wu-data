-- #!/usr/bin/env mysql
-- time cat 02-copy-big-tables.sql | mysql

-- ---------------------------------------------------------------------------
--
-- Copy students from taks to taks_rawk
--

INSERT IGNORE INTO `taks_rawk`.`students` (
       `year`,	id,	campus_id,
       grade,	missing,
       m_irsp,	m_raw,	m_ssc,	m_met,	m_com,	m_scode,
       r_irsp,	r_raw,	r_ssc,	r_met,	r_com,	r_scode,
       ethnic,	disadv,	sex,	migsta,	titlei,	`month`,
       m_bin,	r_bin)
  SELECT 
       s.year,	sid.id,	cid.id,
       s.grade,	s.missing,
       m_irsp,	m_raw,	m_ssc,	m_met,	m_com,	m_scode,
       r_irsp,	r_raw,	r_ssc,	r_met,	r_com,	r_scode,
       ethnic,	disadv,	sex,	migsta,	titlei,	`month`,
       FLOOR(m_raw/6.1), FLOOR(r_raw/6.1)
    FROM          taks.students s
    LEFT     JOIN taks_rawk.student_id_codes sid ON s.stuidnum = sid.student_code
    LEFT     JOIN taks_rawk.campus_id_codes  cid ON s.campus   = cid.campus_code
    WHERE 	  s.missing  = 0
-- LIMIT 200000
;

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
	c.year,		cid.id,
	c.district,	c.county,	c.region,
	c.campus_type,	c.closed,	c.enrollment,
	c.native,	c.asian,	c.black,
	c.hispanic,	c.white,
	c.min_grade,	c.max_grade
    FROM  	  taks.campuses c
    LEFT JOIN 	  taks_rawk.campus_id_codes cid ON c.campus   = cid.campus_code
    WHERE 	  c.closed  = 0
-- LIMIT 200000
;

