DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_teams`;
CREATE TABLE         `vizsagedb_foo`.`Parks_teams` (
    `parkID`                  CHAR(5)             ,
    `teamID`                  CHAR(3)             ,
    `beg`                     DATE                ,
    `end`                     DATE                ,
    `games`                   INTEGER UNSIGNED    ,
    `neutralsite`             BOOLEAN             ,
    `parknameBDB`             CHAR(55)            ,
    PRIMARY KEY (`parkID`,`teamID`)
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ROW_FORMAT = FIXED;

TRUNCATE TABLE `vizsagedb_foo`.`Parks_teams`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/parkinfo-csv-teams.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_teams`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';
