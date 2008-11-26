-- time cat 10-transitiontable.sql | mysql

-- ---------------------------------------------------------------------------
--
-- Fabricate transition table
--
DROP   TABLE  IF EXISTS `taks_rawk`.`student_trans`
; 
CREATE TABLE  `taks_rawk`.`student_trans` (
  `y1`   	SMALLINT(4) 	SIGNED   	  NOT NULL	COMMENT '',
  `id` 		MEDIUMINT 	UNSIGNED ZEROFILL NOT NULL	COMMENT '',
  `campus_id1` 	INT   		UNSIGNED ZEROFILL DEFAULT NULL	COMMENT '',
  `grade1` 	TINYINT(2) 	SIGNED   	  DEFAULT NULL	COMMENT '',
  `m_diff` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'raw math, binned; NULL, 0, 1, .. 9',
  `m_bin1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'raw math, binned; NULL, 0, 1, .. 9',
  `m_raw1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'raw math;         NULL, 0, 1, .. 9',
  `m_met1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'met standards  NULL, 0, 1', 
  `m_com1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'commended      NULL, 0, 1', 
  `m_scode1` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'status code',
  `ethnic1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'Ethnicity;     NULL, 0, 1, .. 5',
  `disadv1` 	TINYINT(1)	SIGNED   	  DEFAULT NULL	COMMENT 'Disadvantaged',
  `sex1` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'Sex',
  `migsta1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'Migrant status',
  `titlei1` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'Title I status',
  `campus_id2` 	INT     	SIGNED   ZEROFILL DEFAULT NULL	COMMENT '',
  `grade2` 	TINYINT(2) 	SIGNED   	  DEFAULT NULL	COMMENT '',
  `m_bin2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'raw math, binned; NULL, 0, 1, .. 9',
  `m_raw2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'raw math;         NULL, 0, 1, .. 9',
  `m_met2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'met standards  NULL, 0, 1', 
  `m_com2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'commended      NULL, 0, 1', 
  `m_scode2` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'status code',
  `ethnic2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'Ethnicity;     NULL, 0, 1, .. 5',
  `disadv2` 	TINYINT(1)	SIGNED   	  DEFAULT NULL	COMMENT 'Disadvantaged',
  `sex2` 	CHAR(1) 		 	  DEFAULT NULL	COMMENT 'Sex',
  `migsta2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'Migrant status',
  `titlei2` 	TINYINT(1) 	SIGNED   	  DEFAULT NULL	COMMENT 'Title I status',
  PRIMARY KEY 		(`y1`,`id`),
  KEY `id`      	(`id`),
  KEY `campus_id1` 	(`campus_id1`),
  KEY `grade1` 		(`grade1`),
  KEY `m_bin1` 		(`m_bin1`),
  KEY `campus_id2` 	(`campus_id2`),
  KEY `grade2` 		(`grade2`),
  KEY `m_bin2` 		(`m_bin2`),
  KEY `ethnic1` 	(`ethnic1`, `disadv1`, `sex1`)
)
ENGINE=MyISAM PACK_KEYS=1 CHARSET=ASCII  PARTITION BY LIST(y1) (
    PARTITION y2003 VALUES IN (2003),
    PARTITION y2004 VALUES IN (2004),
    PARTITION y2005 VALUES IN (2005),
    PARTITION y2006 VALUES IN (2006),
    PARTITION y2007 VALUES IN (2007)
)
;

