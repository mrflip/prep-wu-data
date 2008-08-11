DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_comts`;
CREATE TABLE         `vizsagedb_foo`.`Parks_comts` (
    `parkID`                  CHAR(5)             ,
    `comment`                 VARCHAR(150)        ,
    PRIMARY KEY (`parkID`,`comment`)
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ROW_FORMAT = FIXED;

TRUNCATE TABLE `vizsagedb_foo`.`Parks_comts`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/parkinfo-csv-comts.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_comts`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';
