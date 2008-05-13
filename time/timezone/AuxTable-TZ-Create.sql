-- Creates zoneinfo tables
DROP TABLE IF EXISTS	 time_zone; 
DROP TABLE IF EXISTS	 time_zone_leap_second; 
DROP TABLE IF EXISTS	 time_zone_name;
DROP TABLE IF EXISTS	 time_zone_transition; 
DROP TABLE IF EXISTS	 time_zone_transition_type;
CREATE TABLE  `time_zone` (
  `Time_zone_id`	INT  (10)   UNSIGNED 	NOT NULL auto_increment,
  `Use_leap_seconds` 	ENUM('Y','N') 		NOT NULL default 'N',
  PRIMARY KEY  		(`Time_zone_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=555 COMMENT='Time zones'
;
CREATE TABLE  		`time_zone_leap_second` (
  `Transition_time` 	BIGINT(20)		NOT NULL,
  `Correction` 		INT   (11) 		NOT NULL,
  PRIMARY KEY  		(`Transition_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8                    COMMENT='Leap seconds information for time zones'
;
CREATE TABLE  `time_zone_name` (
  `Name` 		CHAR  (64)		NOT NULL,
  `Time_zone_id` 	INT   (10)   UNSIGNED 	NOT NULL,
  PRIMARY KEY  		(`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8                    COMMENT='Time zone names'
;
CREATE TABLE  `time_zone_transition` (
  `Time_zone_id` 	INT   (10)   UNSIGNED 	NOT NULL,
  `Transition_time` 	BIGINT(20) 		NOT NULL,
  `Transition_type_id` 	INT   (10)   UNSIGNED 	NOT NULL,
  PRIMARY KEY  		(`Time_zone_id`,`Transition_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8                    COMMENT='Time zone transitions'
;
CREATE TABLE  `time_zone_transition_type` (
  `Time_zone_id` 	INT    (10)  UNSIGNED 	NOT NULL,
  `Transition_type_id` 	INT    (10)  UNSIGNED 	NOT NULL,
  `Offset` 		INT    (11) 		NOT NULL default '0',
  `Is_DST` 		TINYINT(3)   UNSIGNED 	NOT NULL default '0',
  `Abbreviation` 	CHAR   (8) 		NOT NULL default '',
  PRIMARY KEY  		(`Time_zone_id`,`Transition_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8                    COMMENT='Time zone transition types'
;

