DROP TABLE IF EXISTS `imw_language_corpora_word_freq`.`head_words`;
CREATE TABLE  `imw_language_corpora_word_freq`.`head_words` (
  `id` 		 INT(11) 	NOT NULL auto_increment,
  `encoded` 	 VARCHAR(60) 	CHARACTER SET ascii COLLATE ascii_bin NOT NULL default '',
  `text` 	 VARCHAR(60) 	CHARACTER SET utf8  COLLATE utf8_bin  NOT NULL default '',
  `pos` 	 ENUM('NoC', 'NoP', 'Adj', 'Num', 'Verb', 'Uncl', 'Adv', 'Fore', 'Int', 'Pron', 'Prep', 'Conj', 'DetP', 'Lett', 'Det', 'VMod', 'Neg', 'Ex', 'Form', 'Inf', 'Gen', 'Err', 'ClO'),
  PRIMARY KEY  				(`id`),
  KEY `index_head_words_text` 		(`text`(25),   `pos`),
  KEY `index_head_words_encoded` 	(`encoded`(25),`pos`)
) ENGINE=MyISAM PACK_KEYS=1 DEFAULT CHARSET=utf8
;

DROP TABLE IF EXISTS `imw_language_corpora_word_freq`.`lemmas`;
CREATE TABLE  `imw_language_corpora_word_freq`.`lemmas` (
  `id` 		 INT(11) 	NOT NULL auto_increment,
  `encoded` 	 VARCHAR(60) 	CHARACTER SET ascii COLLATE ascii_bin NOT NULL default '',
  `text` 	 VARCHAR(60) 	CHARACTER SET utf8  COLLATE utf8_bin  NOT NULL default '',
  `head_word_id` INT(11) 	 	  default NULL,
  PRIMARY KEY  				(`id`),
  KEY `index_lemmas_text` 		(`text`(25),    `head_word_id`),
  KEY `index_lemmas_encoded` 		(`encoded`(25), `head_word_id`),
  KEY `index_lemmas_head_word_id` 	(`head_word_id`)
) ENGINE=MyISAM PACK_KEYS=1 DEFAULT CHARSET=utf8
;

DROP TABLE IF EXISTS `imw_language_corpora_word_freq`.`log_likelihoods`;
CREATE TABLE  `imw_language_corpora_word_freq`.`log_likelihoods` (
  `corpus` 	 ENUM('bnc') 		  default NULL,
  `context` 	 ENUM('all', 'spoken', 'written', 'task', 'conv', 'imaginative', 'informative')  default NULL,
  `word_id` 	 INT(11) 	NOT NULL,
  `word_type` 	 CHAR(9) 	NOT NULL,
  `value` 	 FLOAT 			  default NULL,
  `sign` 	 FLOAT 			  default NULL,
  PRIMARY KEY  				(`corpus`,`context`,`word_id`,`word_type`),
  KEY `index_log_likelihoods_word` 	(`word_id`,`word_type`)
) ENGINE=MyISAM PACK_KEYS=1 DEFAULT CHARSET=utf8
;

DROP TABLE IF EXISTS `imw_language_corpora_word_freq`.`word_stats`;
CREATE TABLE  `imw_language_corpora_word_freq`.`word_stats` (
  `corpus` 	 ENUM('bnc') 		  default NULL,
  `context` 	 ENUM('all', 'spoken', 'written', 'task', 'conv', 'imaginative', 'informative')  default NULL,
  `word_id` 	 INT(11) 	NOT NULL,
  `word_type` 	 CHAR(9) 	NOT NULL,
  `freq` 	 FLOAT 			  default NULL,
  `range` 	 FLOAT 			  default NULL,
  `disp` 	 FLOAT 			  default NULL,
  PRIMARY KEY  				(`corpus`,`context`,`word_id`,`word_type`),
  KEY `index_word_stats_word` 		(`word_id`,`word_type`)
) ENGINE=MyISAM PACK_KEYS=1 DEFAULT CHARSET=utf8
;
