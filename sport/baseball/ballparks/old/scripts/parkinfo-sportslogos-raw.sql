DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_logos_raw`;
CREATE TABLE         `vizsagedb_foo`.`Parks_logos_raw` (
    `franchName`       CHAR(40)                 NOT NULL,
    `franchID`         CHAR(3)                  NOT NULL,
    `sl_lgID`          CHAR(4)        		,
    `sl_teamID`        CHAR(4)        		,
    `role`             CHAR(14)                 ,
    `type`             CHAR(12)                 ,
    `curr`             CHAR(5)                  ,
    `beg`              CHAR(4)        		,
    `end`              CHAR(4)        		,
    `loc`              CHAR(17)                 ,
    `description`      CHAR(120)                ,
    `logoID`           CHAR(26)                 UNIQUE NOT NULL,
    `filename`         VARCHAR(200)             ,
    `referrer`         VARCHAR(200)             ,
    `url`              VARCHAR(200)             NOT NULL, 
    PRIMARY KEY (logoID)
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ;

TRUNCATE TABLE `vizsagedb_foo`.`Parks_logos_raw`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/scripts/parkinfo-sportslogos-all.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_logos_raw`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';

ALTER TABLE         `vizsagedb_foo`.`Parks_logos_raw` 
	ORDER BY `franchName`,`beg`,`end`,`role`,`type`,`description`;

ALTER TABLE `vizsagedb_foo`.`Parks_logos_raw` 
	ADD INDEX logodesc 	(`franchName`,`role`,`type`,`beg`,`end`, `description`),
	ADD INDEX franchID      (`franchID`),
	ADD INDEX role          (`role`    ),
	ADD INDEX roletypeloc   (`role`, `type`, `loc`),
	ADD INDEX beg           (`beg`),
	ADD INDEX end           (`end`),
	ADD INDEX url           (`url`);
