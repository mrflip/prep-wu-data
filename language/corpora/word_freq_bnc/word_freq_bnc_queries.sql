SELECT w.context, w.freq, w.range, l.encoded
  FROM       word_stats w
  INNER JOIN lemmas     l ON w.word_id=l.id AND w.word_type = 'Lemma' AND w.context='all'
ORDER BY freq DESC
LIMIT 5000
