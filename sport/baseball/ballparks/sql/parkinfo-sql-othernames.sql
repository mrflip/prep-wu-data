DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_othernames`;
CREATE TABLE         `vizsagedb_foo`.`Parks_othernames` (
    `parkID`                  CHAR(5)             ,
    `name`                    CHAR(55) BINARY     ,
    `beg`                     SMALLINT UNSIGNED   ,
    `end`                     SMALLINT UNSIGNED   ,
    `auth`                    BOOLEAN             ,
    `curr`                    BOOLEAN             ,
    PRIMARY KEY (`parkID`,`name`)
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ROW_FORMAT = FIXED;

TRUNCATE TABLE `vizsagedb_foo`.`Parks_othernames`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/parkinfo-csv-othernames.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_othernames`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';
