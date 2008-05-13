-- Makes zoneinfo tables have non-colliding (and saner) names.  
-- Make sure any data column definition changes match with the creation file

ALTER TABLE  	`time_zone` 
  CHANGE COLUMN `Time_zone_id`  	`tzID`		INTEGER	UNSIGNED	NOT NULL AUTO_INCREMENT,
  CHANGE COLUMN `Use_leap_seconds`	`leapsec_flag`	ENUM	('Y','N')	NOT NULL default 'N'
;
ALTER TABLE	`time_zone_leap_second` 
  CHANGE COLUMN `Transition_time`	`transTS`	BIGINT	(20)		NOT NULL,
  CHANGE COLUMN `Correction`		`correction`	INTEGER			NOT NULL
;
ALTER TABLE  	`time_zone_name` 
  CHANGE COLUMN `Name`			`tzName`	CHAR	(64)		NOT NULL,
  CHANGE COLUMN `Time_zone_id`  	`tzID`		INTEGER	UNSIGNED	NOT NULL
;
ALTER TABLE  	`time_zone_transition` 
  CHANGE COLUMN `Time_zone_id`  	`tzID`		INTEGER	UNSIGNED	NOT NULL,
  CHANGE COLUMN `Transition_time`	`transTS`	BIGINT			NOT NULL,
  CHANGE COLUMN `Transition_type_id`	`transTypeID`	INTEGER	UNSIGNED	NOT NULL
;
ALTER TABLE  	`time_zone_transition_type` 
  CHANGE COLUMN `Time_zone_id`  	`tzID`		INTEGER	UNSIGNED	NOT NULL,
  CHANGE COLUMN `Transition_type_id`	`transTypeID`	INTEGER	UNSIGNED	NOT NULL,
  CHANGE COLUMN `Offset`		`offset`	INTEGER			NOT NULL default '0',
  CHANGE COLUMN `Is_DST`		`DST_flag`	TINYINT	UNSIGNED	NOT NULL default '0',
  CHANGE COLUMN `Abbreviation`  	`tzAbbrev`	CHAR	(8)		NOT NULL default ''
;
