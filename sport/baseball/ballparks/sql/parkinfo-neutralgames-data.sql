DROP TABLE IF EXISTS `vizsagedb_foo`.`Parks_neutralgames`;
CREATE TABLE         `vizsagedb_foo`.`Parks_neutralgames` (
    `parkID`                  CHAR(5),
    `gamedate`                DATE               ,
    `gnum_in_day`             CHAR(1)            ,
    `v_lg`                    CHAR(2)            ,
    `v_teamname`              CHAR(35)           ,
    `h_lg`                    CHAR(2)            ,
    `h_teamname`              CHAR(35)           ,
    `parkname`		      VARCHAR(54)        ,
    `city`                    CHAR(25)           ,
    `state`                   CHAR(2)            ,
    `commnum`                 CHAR(2)            ,
    `comment`                 VARCHAR(75)           ,
    PRIMARY KEY gameID (parkID, `gamedate`, gnum_in_day, h_teamname, v_teamname)
  ) ENGINE = MYISAM DEFAULT CHARSET = utf8 ROW_FORMAT = FIXED;

TRUNCATE TABLE `vizsagedb_foo`.`Parks_neutralgames`;
LOAD DATA INFILE
        '/Users/Flip/now/vizsage/apps/BaseballBrainiac/pysrc/retrosheet/info/parks/parkinfo-neutralgames-data.csv'
        REPLACE INTO TABLE `vizsagedb_foo`.`Parks_neutralgames`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n';

ALTER TABLE `vizsagedb_foo`.`Parks_neutralgames`
        ADD     INDEX     (v_lg)            ,
        ADD     INDEX     (v_teamname)        ,
        ADD     INDEX     (h_lg)            ,
        ADD     INDEX     (h_teamname)        ,
        ADD     INDEX     (parkname)	    , 
        ADD     INDEX     (city)            ,
        ADD     INDEX     (state)           ,
        ADD     INDEX     (commnum)         
