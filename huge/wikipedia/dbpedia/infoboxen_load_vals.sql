use `infochimps_data`;

-- ===========================================================================
--
-- Create tables
--
-- ===========================================================================

-- we have this many:
--   21 932 144 joins
--    1 065 150 names
--       32 804 props
--       32 680 templates
--        6 823 sub_tpls
--           27 types
--
-- Expect this to take, on a fast machine, about 
--   

-- [ val_id, name_id, prop_id, type_id, sub_tpl_id ]
DROP TABLE IF EXISTS `joins`;
CREATE TABLE  `joins` (
  `val_id`      INT        UNSIGNED 		NOT NULL,
  `name_id`     MEDIUMINT  UNSIGNED 		NOT NULL,
  `prop_id`     MEDIUMINT  UNSIGNED 		NOT NULL,
  `type_id`     SMALLINT   UNSIGNED 		NOT NULL,
  `sub_tpl_id`  SMALLINT   UNSIGNED 		NOT NULL,
  PRIMARY KEY   (`val_id` ), -- , `name_id`, `prop_id`, `type_id`, `sub_tpl_id`
  KEY           `name_id`	(`name_id`, `prop_id`),
  KEY           `prop_id`	(`prop_id`),
  KEY           `sub_tpl_id`	(`sub_tpl_id`, `prop_id`)
) ENGINE	= MyISAM 
  ROW_FORMAT	= FIXED
  CHARSET	= ascii 
  COMMENT	= 'Wikipedia Infoboxen from DBPedia: Records';

-- this is ascii because we left non-7-bit chars %-encoded
-- if you unencode those too, change the charset appropriately
DROP TABLE IF EXISTS `vals`;
CREATE TABLE  `vals` (
  `id`          INT        	UNSIGNED 		NOT NULL,
  `val`         TEXT       	CHARACTER SET ascii	default NULL,
  PRIMARY KEY   (`id`)
--,  KEY           `val`	  	(`val`(63))  
) ENGINE	= MyISAM 
  CHARSET	= ascii 
  COMMENT	= 'Wikipedia Infoboxen from DBPedia: Values';

-- Night_of_the_Day_of_the_Dawn_of_the_Son_of_the_Bride_of_the_Return_of_the_Revenge_of_the_Terror_of_the_Attack_of_the_Evil,_Mutant,_Alien,_Flesh_Eating,_Hellbound,_Zombified_Living_Dead_Part_2:_In_Shocking_2-D
-- Night_of_the_Day_of_the_Dawn_of_the_Son_of_the_Bride_of_the_Return_of_the_Revenge_of_the_Terror_of_the_Attack_of_the_Evil%2C_Mutant%2C_Alien%2C_Flesh_Eating%2C_Hellbound%2C_Zombified_Living_Dead_Part_2:_In_Shocking_2-D
DROP TABLE IF EXISTS `names`;
CREATE TABLE  `names` (
  `id`          MEDIUMINT       UNSIGNED  		NOT NULL,
  `name`        VARCHAR(250)    CHARACTER SET ascii	default NULL,
  `orig_name`   VARCHAR(250)    CHARACTER SET ascii	default NULL,
  PRIMARY KEY   (`id`),
  KEY           `name`	  	(`name`(63))  
) ENGINE	= MyISAM 
  CHARSET	= ascii 
  COMMENT	= 'Wikipedia Infoboxen from DBPedia: Names';

DROP TABLE IF EXISTS `props`;
CREATE TABLE  `props` (
  `id`          MEDIUMINT     	UNSIGNED 		NOT NULL,
  `prop`        VARCHAR(250)    CHARACTER SET ascii	default NULL,
  PRIMARY KEY   (`id`),
  KEY           `prop`	  	(`prop`(63))  
) ENGINE	= MyISAM 
  CHARSET	= ascii 
  COMMENT	= 'Wikipedia Infoboxen from DBPedia: Properties';

-- there is actually one line that exceeds 255chars; it's bogus.
DROP TABLE IF EXISTS `sub_tpls`;
CREATE TABLE  `sub_tpls` (
  `id`          SMALLINT     	UNSIGNED 		NOT NULL,
  `sub_tpl`     VARCHAR(250)    CHARACTER SET ascii	default NULL,
  PRIMARY KEY   (`id`),
  KEY           `sub_tpl`  	(`sub_tpl`(63))  
) ENGINE 	= MyISAM 
  CHARSET	= ascii 
  COMMENT	= 'Wikipedia Infoboxen from DBPedia: Sub-properties';

  
DROP TABLE IF EXISTS `types`;
CREATE TABLE  `types` (
  `id`          SMALLINT     	UNSIGNED 		NOT NULL,
  `type`     	CHAR(50)    	CHARACTER SET ascii	default NULL,
  PRIMARY KEY   (`id`),
  KEY           `type`  	(`type`)
) ENGINE 	= MyISAM 
  ROW_FORMAT	= FIXED
  CHARSET	= ascii 
  COMMENT	= 'Wikipedia Infoboxen from DBPedia: Types';

ALTER    TABLE `joins` DISABLE KEYS; 
LOAD DATA INFILE '/home/flip/ics/data/rawd/huge/wikipedia/dbpedia/dump/infobox_chunk_042/infobox_chunk_042_join.tsv'
    REPLACE INTO TABLE `joins`
    FIELDS TERMINATED BY '\t'
    LINES  TERMINATED BY '\n'
    (`val_id`, `name_id`, `prop_id`, `type_id`, `sub_tpl_id`,`type_id`);

ALTER    TABLE `vals` DISABLE KEYS; 
LOAD DATA INFILE '/home/flip/ics/data/rawd/huge/wikipedia/dbpedia/dump/infobox_chunk_042/infobox_chunk_042_val.tsv'
    REPLACE INTO TABLE `vals`
    FIELDS TERMINATED BY '\t'
    LINES  TERMINATED BY '\n'
    (`id`,`val`);

ALTER    TABLE `names` DISABLE KEYS; 
LOAD DATA INFILE '/home/flip/ics/data/rawd/huge/wikipedia/dbpedia/dump/infobox_chunk_042/infobox_chunk_042_name.tsv'
    REPLACE INTO TABLE `names`
    FIELDS TERMINATED BY '\t'
    LINES  TERMINATED BY '\n'
    (`id`,`name`,`orig_name`);

ALTER    TABLE `props` DISABLE KEYS; 
LOAD DATA INFILE '/home/flip/ics/data/rawd/huge/wikipedia/dbpedia/dump/infobox_chunk_042/infobox_chunk_042_prop.tsv'
    REPLACE INTO TABLE `props`
    FIELDS TERMINATED BY '\t'
    LINES  TERMINATED BY '\n'
    (`id`,`prop`);

ALTER    TABLE `sub_tpls` DISABLE KEYS; 
LOAD DATA INFILE '/home/flip/ics/data/rawd/huge/wikipedia/dbpedia/dump/infobox_chunk_042/infobox_chunk_042_sub_tpl.tsv'
    REPLACE INTO TABLE `sub_tpls`
    FIELDS TERMINATED BY '\t'
    LINES  TERMINATED BY '\n'
    (`id`,`sub_tpl`);

ALTER    TABLE `types` DISABLE KEYS; 
LOAD DATA INFILE '/home/flip/ics/data/rawd/huge/wikipedia/dbpedia/dump/infobox_chunk_042/infobox_chunk_042_type.tsv'
    REPLACE INTO TABLE `types`
    FIELDS TERMINATED BY '\t'
    LINES  TERMINATED BY '\n'
    (`id`,`type`);

    
