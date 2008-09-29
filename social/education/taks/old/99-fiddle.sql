
-- ---------------------------------------------------------------------------
--
-- Fiddlefucking with frequencies
--

-- -- binned score freqs
-- SELECT COUNT(*), ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM taks.students2006), 1) AS fraction, FLOOR(m_raw/6.1) AS m_bin 
--   FROM 		taks.students2006 s
--   GROUP BY	m_bin
--   ORDER BY 	m_bin;
-- -- freq of ethnicity
-- SELECT COUNT(*), ROUND(100*COUNT(*)/(SELECT COUNT(*) FROM taks.students2006), 1) AS fraction, ethnic AS m_bin 
--   FROM 		taks.students2006 s
--   GROUP BY	m_bin
--   ORDER BY 	m_bin;
