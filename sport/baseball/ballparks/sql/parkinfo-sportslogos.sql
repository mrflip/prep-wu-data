DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_logos`;
CREATE TABLE	     `vizsagedb_foo`.`Parks_logos` (
    `logoID`		CHAR(16)		PRIMARY KEY,
    `franchID`		CHAR(3)			NOT NULL,
    `beg`		CHAR(4)			,
    `end`		CHAR(4)			,
    `logoType`		CHAR(4)  		,
    `what`		CHAR(12)		,
    `role`		CHAR(14)		,
    `loc`		CHAR(17)		,
    `idx`		CHAR(17)		,
    `desc`		VARCHAR(200)		
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ;
--     PRIMARY KEY (logoID)

TRUNCATE TABLE `vizsagedb_foo`.`Parks_logos`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/parkinfo-sportslogos.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_logos`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';

ALTER TABLE `vizsagedb_foo`.`Parks_logos` 
	ADD INDEX `franchID`	  (`franchID`),
	ADD INDEX `beg` 	  (`beg`    	),
	ADD INDEX `end` 	  (`end`    	),
	ADD INDEX `logoType`	  (`logoType`	),
	ADD INDEX `what`	  (`what`	),
	ADD INDEX `role`	  (`role`	),
	ADD INDEX `loc` 	  (`loc` 	),
	ADD INDEX `desc`	  (`desc`	),
	ADD INDEX typerolelocidx  (`what`, `role`, `loc`, `idx`);
