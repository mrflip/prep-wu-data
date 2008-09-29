
-- ---------------------------------------------------------------------------
--
-- Student-Campus-Year Denormalized table
--

DROP   TABLE  IF EXISTS `taks_rawk`.`student_campus_year`
; 
CREATE TABLE  `taks_rawk`.`student_campus_year` (
  `year` 	SMALLINT(4) 	UNSIGNED 	  NOT NULL,
  `student_id`	MEDIUMINT 	UNSIGNED ZEROFILL NOT NULL,
  `campus_id`	INT      	UNSIGNED ZEROFILL NOT NULL,
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
  PRIMARY KEY 		(`year`,`student_id`),
  KEY     		(`year`,`campus_id`),
  KEY `student_id`	(`student_id`),
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
