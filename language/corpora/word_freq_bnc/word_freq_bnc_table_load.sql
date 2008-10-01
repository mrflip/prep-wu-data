
INSERT IGNORE INTO `imw_language_corpora_word_freq`.lemmas
  (`head_word_id`, `encoded`, `text`)
  SELECT h.id, r.`encoded`, r.`text`
  FROM  	`imw_language_corpora_word_freq`.raw_lemmas r
  LEFT JOIN	`imw_language_corpora_word_freq`.head_words h
    ON r.`head_word`=h.encoded AND r.`pos` = h.`pos`
;    

INSERT IGNORE INTO `imw_language_corpora_word_freq`.word_stats
  (`word_id`, `corpus`, `freq`, `range`, `disp`, `context`, `word_type`)
  SELECT h.id, r.`corpus`, r.`freq`, r.`range`, r.`disp`, r.`context`, r.`word_type`
  FROM  	`imw_language_corpora_word_freq`.raw_word_stats_heads r
  LEFT JOIN	`imw_language_corpora_word_freq`.head_words     h
    ON r.`head_word`=h.encoded AND r.`pos` = h.`pos`
;    

INSERT IGNORE INTO `imw_language_corpora_word_freq`.log_likelihoods
  (`word_id`, `corpus`, `value`, `sign`, `context`, `word_type`)
  SELECT h.id, r.`corpus`, r.`value`, r.`sign`, r.`context`, r.`word_type`
  FROM  	`imw_language_corpora_word_freq`.raw_log_likelihoods_heads r
  LEFT JOIN	`imw_language_corpora_word_freq`.head_words 	     h
    ON r.`head_word`=h.encoded AND r.`pos` = h.`pos`
;    

INSERT IGNORE INTO `imw_language_corpora_word_freq`.word_stats
  (`word_id`, `corpus`, `freq`, `range`, `disp`, `context`, `word_type`)
  SELECT l.id, r.`corpus`, r.`freq`, r.`range`, r.`disp`, r.`context`, r.`word_type`
  FROM  	`imw_language_corpora_word_freq`.raw_word_stats_lemmas r
  LEFT JOIN	`imw_language_corpora_word_freq`.head_words h
    ON r.`head_word`=h.encoded AND r.`pos` = h.`pos`
  LEFT JOIN	`imw_language_corpora_word_freq`.lemmas     l
    ON r.`lemma`=l.encoded     AND l.head_word_id = h.id
;    

INSERT IGNORE INTO `imw_language_corpora_word_freq`.log_likelihoods
  (`word_id`, `corpus`, `value`, `sign`, `context`, `word_type`)
  SELECT l.id, r.`corpus`, r.`value`, r.`sign`, r.`context`, r.`word_type`
  FROM  	`imw_language_corpora_word_freq`.raw_log_likelihoods_lemmas r
  LEFT JOIN	`imw_language_corpora_word_freq`.head_words h
    ON r.`head_word`=h.encoded AND r.`pos` = h.`pos`
  LEFT JOIN	`imw_language_corpora_word_freq`.lemmas     l
    ON r.`lemma`=l.encoded     AND l.head_word_id = h.id
;    

