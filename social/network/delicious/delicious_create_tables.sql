DROP TABLE IF EXISTS  `imw_social_network_delicious`.`socialites_tags`;
DROP TABLE IF EXISTS  `imw_social_network_delicious`.`socialites_links`;
DROP TABLE IF EXISTS  `imw_social_network_delicious`.`taggings`;
DROP TABLE IF EXISTS  `imw_social_network_delicious`.`ripped_urls`;
DROP TABLE IF EXISTS  `imw_social_network_delicious`.`delicious_links`;
DROP TABLE IF EXISTS  `imw_social_network_delicious`.`tags`;
DROP TABLE IF EXISTS  `imw_social_network_delicious`.`socialites`;

CREATE TABLE  `imw_social_network_delicious`.`delicious_links` (
  `id` 			 	int(11) 		NOT NULL auto_increment,
  `link_url` 		 	varchar(1024) 		NOT NULL,
  `delicious_id` 	 	varchar(40) 		NOT NULL,
  `num_delicious_savers` 	int(11) 		default NULL,
  `title` 		 	varchar(255) 		default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `unique_index_delicious_links_delicious_id` (`delicious_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `imw_social_network_delicious`.`tags` (
  `id`				int(11) 		NOT NULL auto_increment,
  `name`			varchar(40) 		NOT NULL,
  PRIMARY KEY  (`id`), 
  UNIQUE KEY `unique_index_tags_name` 	  (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `imw_social_network_delicious`.`socialites` (
  `id`				int(11) 		NOT NULL auto_increment,
  `uniqname`			char(100) 		NOT NULL,
  `following_count`		int(11) 		default NULL,
  `followers_count`		int(11) 		default NULL,
  `updates_count`		int(11) 		default NULL,
  `name`			varchar(40) 		default NULL,
  `description`			text,
  `bio_url`			varchar(255) 		default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `unique_index_socialites_socialite_uniqname` (`uniqname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `imw_social_network_delicious`.`socialites_links` (
  `delicious_link_id`		int(11) 		NOT NULL,
  `socialite_id`		int(11) 		NOT NULL,
  `date_tagged`			datetime 		default NULL,
  `text`			varchar(150) 		default NULL,
  `description`			text,
  PRIMARY KEY  (`delicious_link_id`,`socialite_id`),
  FOREIGN KEY (delicious_link_id) REFERENCES delicious_links  (id),
  FOREIGN KEY (socialite_id) 	  REFERENCES socialites       (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `imw_social_network_delicious`.`socialites_tags` (
  `tag_id`			int(11) 		NOT NULL,
  `socialite_id`		int(11) 		NOT NULL,
  `tagged_count`		int(11) 		default NULL,
  PRIMARY KEY  	(`tag_id`,`socialite_id`),
  FOREIGN KEY 	(tag_id) 	REFERENCES tags       	(id),
  FOREIGN KEY 	(socialite_id) 	REFERENCES socialites 	(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `imw_social_network_delicious`.`taggings` (
  `tag_id`			int(11) 		NOT NULL,
  `delicious_link_id`		int(11) 		NOT NULL,
  `socialite_id`		int(11) 		NOT NULL,
  PRIMARY KEY  	(`tag_id`,`delicious_link_id`,`socialite_id`),
  KEY   	(`delicious_link_id`,`socialite_id`),
  KEY   	(`socialite_id`,`tag_id`),
  FOREIGN KEY (tag_id) 		  REFERENCES tags             (id),
  FOREIGN KEY (delicious_link_id) REFERENCES delicious_links  (id),
  FOREIGN KEY (socialite_id) 	  REFERENCES socialites       (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `imw_social_network_delicious`.`ripped_urls` (
  `id`				int(11) 		NOT NULL auto_increment,
  `ripd_url`			varchar(1024) 		default NULL,
  `scheme`			varchar(50) 		default NULL,
  `user`			varchar(50) 		default NULL,
  `password`			varchar(50) 		default NULL,
  `host`			varchar(128) 		default NULL,
  `port`			varchar(50) 		default NULL,
  `path`			text,
  `query`			text,
  `fragment`			text,
  `tried_parse`			tinyint(4) default '0',
  `did_parse`			tinyint(4) default '0',
  
  `ripd_file`			varchar(1024) 		default NULL,
  `ripd_file_date`		datetime 		default NULL,
  `ripd_file_size`		int(11) 		default NULL,
  `rippable_type`		varchar(10) 		NOT NULL,
  `rippable_param`		varchar(255) 		default NULL,
  `rippable_user`		varchar(40) 		default NULL,
  `ripped_page`			int(11) 		default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_ripped_urls_rippable_param` (`rippable_type`,`rippable_param`),
  KEY `index_ripped_urls_rippable_user` (`rippable_type`,`rippable_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
