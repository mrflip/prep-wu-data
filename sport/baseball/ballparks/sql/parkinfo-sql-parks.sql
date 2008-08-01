DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_parks`;
CREATE TABLE         `vizsagedb_foo`.`Parks_parks` (
    `parkID`                  CHAR(5)             ,
    `name`                    CHAR(55)            ,
    `beg`                     DATE                ,
    `end`                     DATE                ,
    `games`                   INTEGER UNSIGNED    ,
    `streetaddr`              CHAR(55)	           ,
    `extaddr`                 CHAR(55)            ,
    `city`                    CHAR(35)            ,
    `state`                   CHAR(2)             ,
    `country`                 CHAR(2)             ,
    `zip`                     CHAR(10)            ,
    `tel`                     CHAR(18)            ,
    `active`                  CHAR(1)             ,
    `lat`                     DOUBLE	             ,
    `lng`                     DOUBLE	             ,
    `url`                     CHAR(25)            ,
    `spanishurl`              CHAR(25)            ,
    `logofile`                CHAR(25)            ,
    PRIMARY KEY (`parkID`)
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ROW_FORMAT = FIXED;

TRUNCATE TABLE `vizsagedb_foo`.`Parks_parks`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/parkinfo-csv-parks.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_parks`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';
