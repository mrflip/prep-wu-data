SELECT s.name, cf.event_id, cf.corpus_freq, (1e6 * corpus_freq/tot.total_words) AS event_freq, SUM(ws.freq) AS bnc_tot_freq, ws.context,
  word, hw.*
  FROM (
    SELECT count(*) AS corpus_freq, w.speaker_id, w.event_id, w.norm_word AS word
    FROM 		word_usages w
	GROUP BY    w.speaker_id, w.event_id, w.norm_word
	) cf
  LEFT JOIN 	speakers s ON s.id = cf.speaker_id
  LEFT JOIN 	(
    SELECT speaker_id, event_id, COUNT(*) AS total_words FROM word_usages
	  GROUP BY speaker_id, event_id) tot
	ON cf.speaker_id = tot.speaker_id AND cf.event_id = tot.event_id
  LEFT JOIN `imw_language_corpora_word_freq`.lemmas l ON cf.word = l.text
  LEFT JOIN `imw_language_corpora_word_freq`.word_stats ws ON ws.word_id = l.id AND ws.word_type = 'Lemma'
  LEFT JOIN `imw_language_corpora_word_freq`.head_words hw ON l.head_word_id = hw.id
  WHERE context = 'all' OR (l.id IS NULL)
  GROUP BY cf.speaker_id, cf.event_id, cf.word, l.id, hw.id
  ORDER BY cf.speaker_id ASC, corpus_freq DESC

