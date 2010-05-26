DROP TABLE IF EXISTS turk_results ;
CREATE TABLE `turk_results` (
  `hit_id`        VARCHAR(30) DEFAULT NULL,
  `hit_type`      VARCHAR(30) DEFAULT NULL,
  `ass_id`        VARCHAR(30) DEFAULT NULL,
  `worker_id`     VARCHAR(30) DEFAULT NULL,
  `display_name`  VARCHAR(255) DEFAULT NULL,
  `in_website`    VARCHAR(255) DEFAULT NULL,
  `in_network`    VARCHAR(255) DEFAULT NULL,
  `in_net_site`   VARCHAR(255) DEFAULT NULL,
  `comment`       TEXT,
  `a_url`         VARCHAR(750) CHARACTER SET ASCII DEFAULT NULL,
  `approve`       VARCHAR(255) DEFAULT NULL,
  `reject`        VARCHAR(255) DEFAULT NULL,
  `id`            INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ass_status`    VARCHAR(255) DEFAULT NULL,
  `work_time`     VARCHAR(255) DEFAULT NULL,
  `old_hit`       VARCHAR(255) DEFAULT NULL,
  `old_hit_type`  VARCHAR(255) DEFAULT NULL,
  `old_ass`       VARCHAR(255) DEFAULT NULL,
  `old_worker_id` VARCHAR(255) DEFAULT NULL,
  `old_time`      VARCHAR(255) DEFAULT NULL,
  `in_answer`     VARCHAR(255) DEFAULT NULL,
  `sort`          VARCHAR(255) DEFAULT NULL,
  `filename`      VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_turk_results_hit_id` (`hit_id`),
  KEY `index_turk_results_biz_site` (`in_website`,`in_net_site`),
  KEY `index_turk_results_name`     (`display_name`)
) ENGINE=INNODB AUTO_INCREMENT=1024 DEFAULT CHARSET=utf8 ;

-- SELECT num, COUNT(*) AS freq FROM (
--   SELECT COUNT(*) AS num, GROUP_CONCAT(approve), tr.* FROM turk_results tr GROUP BY in_website
--   ) sq GROUP BY num
