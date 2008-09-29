
SELECT h.id, h.text, h.pos, 
    h_ws.freq,  SUM(l_ws.freq)  AS lemma_freq_total,  CAST(GROUP_CONCAT(l_ws.freq)  AS CHAR(50)) AS lemma_freqs,  
    h_ws.range, SUM(l_ws.range) AS lemma_range_total, CAST(GROUP_CONCAT(l_ws.range) AS CHAR(50)) AS lemma_ranges, 
    h_ws.disp,  SUM(l_ws.disp)  AS lemma_disp_total,  CAST(GROUP_CONCAT(l_ws.disp)  AS CHAR(50)) AS lemma_disps,  
    GROUP_CONCAT(l.text) AS lemma_texts, 
  	CAST(GROUP_CONCAT(l.id ORDER BY h.id) AS CHAR(50)) AS lemma_ids, 
  	CAST(GROUP_CONCAT(h.id) AS CHAR(50))  AS head_ids
  FROM 			head_words h
  LEFT JOIN 	lemmas l 
    ON 			l.head_word_id = h.id
  LEFT JOIN     word_stats l_ws
    ON          l_ws.word_id = l.id AND l_ws.word_type = 'Lemma'
  LEFT JOIN     word_stats h_ws
    ON          h_ws.word_id = h.id AND h_ws.word_type = 'HeadWord'
  GROUP BY 		h.id 
	HAVING 		COUNT(DISTINCT l.id) > 1	
