-- ---------------------------------------------------------------------------
--
-- Create student id - stuidnum code mapping
--
DROP   TABLE  IF EXISTS `taks_rawk`.`student_id_codes`
; 
CREATE TABLE `taks_rawk`.`student_id_codes` (
  id		MEDIUMINT ZEROFILL UNSIGNED AUTO_INCREMENT 	NOT NULL,
  student_code 	CHAR(9) 					NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE  KEY student_code  (`student_code`)
) ENGINE=MyISAM PACK_KEYS=1 CHARSET=ASCII
;
INSERT INTO `taks_rawk`.`student_id_codes` (student_code)
  SELECT DISTINCT s.stuidnum FROM taks.students s
;
-- ---------------------------------------------------------------------------
--
-- Create campus id - campus code mapping
--
DROP   TABLE  IF EXISTS `taks_rawk`.`campus_id_codes`
; 
CREATE TABLE `taks_rawk`.`campus_id_codes` (
  id		MEDIUMINT ZEROFILL UNSIGNED AUTO_INCREMENT 	NOT NULL,
  campus_code 	INT(9)  					NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE  KEY campus_code (`campus_code`)
) ENGINE=MyISAM PACK_KEYS=1 CHARSET=ASCII
;
INSERT INTO `taks_rawk`.`campus_id_codes` (campus_code)
  SELECT DISTINCT c.campus FROM taks.campuses c
;

-- ---------------------------------------------------------------------------
--
-- Create Auxilliary table for years
--
DROP   TABLE IF EXISTS `taks_rawk`.`years`
; 
CREATE TABLE `taks_rawk`.`years` (
  year 		SMALLINT(4) 	UNSIGNED 			 NOT NULL,
  y1		SMALLINT(4) 	UNSIGNED 			 NOT NULL,
  y2		SMALLINT(4) 	UNSIGNED 			 ,
  PRIMARY KEY (`year`)
) ENGINE=MyISAM PACK_KEYS=1 CHARSET=ASCII
;
INSERT INTO `taks_rawk`.`years` (year, y1, y2) VALUES
  (2003, 2003, 2004), 
  (2004, 2004, 2005), 
  (2005, 2005, 2006), 
  (2006, 2006, NULL)
;

-- ---------------------------------------------------------------------------
--
-- Fiddlefucking with frequencies
--

-- -- binned score freqs
-- SELECT COUNT(*), ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM taks.students2006), 1) AS fraction, FLOOR(m_raw/6.1) AS m_bin 
--   FROM 		taks.students2006 s
--   GROUP BY	m_bin
--   ORDER BY 	m_bin;
-- -- freq of ethnicity
-- SELECT COUNT(*), ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM taks.students2006), 1) AS fraction, ethnic AS m_bin 
--   FROM 		taks.students2006 s
--   GROUP BY	m_bin
--   ORDER BY 	m_bin;

-- ---------------------------------------------------------------------------
--
-- Create new Students table
--
DROP   TABLE  IF EXISTS `taks_rawk`.`students_years`
; 
CREATE TABLE  `taks_rawk`.`students_years` (
  `year` 	SMALLINT(4) 	UNSIGNED 	  NOT NULL	COMMENT '',
  `id` 		MEDIUMINT 	UNSIGNED ZEROFILL NOT NULL	COMMENT '',
  `campus_id` 	INT(9) 		UNSIGNED ZEROFILL DEFAULT NULL	COMMENT '',
  `grade` 	TINYINT(2) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `missing` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'existed in prev. year, not anymore',
  `m_bin` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'binned raw;    NULL, 0, 1, .. 9',
  `m_irsp` 	TINYINT(2) 		 	  DEFAULT NULL	COMMENT 'corrected raw; NULL, 0..60, -1', 
  `m_raw` 	SMALLINT(5) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'raw score;     NULL, 0..60    ', 
  `m_ssc` 	SMALLINT(5) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'scaled score', 
  `m_met` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'met standards  NULL, 0, 1', 
  `m_com` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'commended      NULL, 0, 1', 
  `m_scode` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'status code',
  `r_bin` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'binned raw;    NULL, 0, 1, .. 9',
  `r_irsp` 	TINYINT(2) 	 	 	  DEFAULT NULL	COMMENT 'corrected raw; NULL, 0..60, -1', 
  `r_raw` 	SMALLINT(5) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'raw score;     NULL, 0..60    ', 
  `r_ssc` 	SMALLINT(5) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'scaled score', 		  
  `r_met` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'met standards  NULL, 0, 1', 	  
  `r_com` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'commended      NULL, 0, 1', 	  
  `r_scode` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'status code',			  
  `ethnic` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'Ethnicity;     NULL, 0, 1, .. 5',
  `disadv` 	TINYINT(1)	UNSIGNED 	  DEFAULT NULL	COMMENT 'Disadvantaged',
  `sex` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'Sex',
  `migsta` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'Migrant status',
  `titlei` 	TINYINT(1) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'Title I status',
  `month` 	TINYINT(2) 	UNSIGNED 	  DEFAULT NULL	COMMENT 'Month of test',
  PRIMARY KEY 		(`year`,`id`),
  KEY `campus_id` 	(`campus_id`),
  KEY `grade` 		(`grade`),
  KEY `m_irsp` 		(`m_irsp`),
  KEY `m_raw` 		(`m_raw`),
  KEY `m_bin` 		(`m_bin`),
  KEY `ethnic` 		(`ethnic`, `disadv`, `sex`)
)
ENGINE=MyISAM PACK_KEYS=1 CHARSET=ASCII  PARTITION BY LIST(year) (
    PARTITION y2003 VALUES IN (2003),
    PARTITION y2004 VALUES IN (2004),
    PARTITION y2005 VALUES IN (2005),
    PARTITION y2006 VALUES IN (2006),
    PARTITION y2007 VALUES IN (2007)
)
;

-- ---------------------------------------------------------------------------
--
-- Copy values across
--

INSERT INTO `taks_rawk`.`students_years` (
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
 -- LIMIT 1000000
;

-- ---------------------------------------------------------------------------
--
-- Campus table
--

DROP   TABLE  IF EXISTS `taks_rawk`.`campuses_years`
; 
CREATE TABLE  `taks_rawk`.`campuses_years` (
  `year` 	SMALLINT(4) 	UNSIGNED 	  NOT NULL,
  `id`		MEDIUMINT 	UNSIGNED ZEROFILL NOT NULL,
  `district` 	MEDIUMINT(6) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `county` 	SMALLINT(3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `region` 	TINYINT(2) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `campus_type` CHAR(1) 		 	  DEFAULT NULL	COMMENT '',
  `closed` 	TINYINT(1)	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `enrollment` 	SMALLINT(5) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `native` 	FLOAT(3,3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `asian` 	FLOAT(3,3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `black` 	FLOAT(3,3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `hispanic` 	FLOAT(3,3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `white` 	FLOAT(3,3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `min_grade` 	TINYINT(3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  `max_grade` 	TINYINT(3) 	UNSIGNED 	  DEFAULT NULL	COMMENT '',
  PRIMARY KEY 		(`year`,`id`),
  KEY `id` 		(`id`),
  KEY `district` 	(`district`),
  KEY `county` 		(`county`),
  KEY `region` 		(`region`),
  KEY `campus_type` 	(`campus_type`),
  
  KEY `enrollment`   	(`enrollment`),
  KEY `native`   	(`native`    ),
  KEY `asian`   	(`asian`     ),
  KEY `black`   	(`black`     ),
  KEY `hispanic` 	(`hispanic`  ),
  KEY `white`   	(`white`     )
) 
ENGINE=MyISAM PACK_KEYS=1 CHARSET=ASCII  PARTITION BY LIST(year) (
    PARTITION y2003 VALUES IN (2003),
    PARTITION y2004 VALUES IN (2004),
    PARTITION y2005 VALUES IN (2005),
    PARTITION y2006 VALUES IN (2006),
    PARTITION y2007 VALUES IN (2007)
)
;

-- ---------------------------------------------------------------------------
--
-- Copy values across
--

INSERT INTO `taks_rawk`.`campuses_years` (
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

