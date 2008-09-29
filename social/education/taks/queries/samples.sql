SELECT "Time ", NOW();

SELECT campus_id, COUNT(*) AS num_tests, avg(m_bin) AS avg_bin 
  FROM      students s
  GROUP BY  campus_id
;
SELECT "Time ", NOW();

SELECT campus_id, m_bin, s.year, COUNT(*) AS num_in_m_bin 
  FROM      students s
  GROUP BY  campus_id, m_bin, s.year
;
SELECT "Time ", NOW();

-- binned score transitions by campus
SELECT      s.campus_id1, s.y1, s.m_bin1, s.m_bin2, COUNT(*) AS num_in_m_bin12 
  FROM      student_trans s
  WHERE     s.campus_id1 = s.campus_id2
  GROUP BY  s.campus_id1, s.y1, s.m_bin1, s.m_bin2
; 
SELECT "Time ", NOW();

SELECT      s.m_bin1, s.m_bin2, COUNT(*) AS num_in_m_bin12 
  FROM      student_trans s
  GROUP BY  s.m_bin1, s.m_bin2
  ORDER BY num_in_m_bin12 DESC
;
SELECT "Time ", NOW();

-- by %white (in bins of 10%), racial makeup of remainder and total school enrollment.
SELECT COUNT(*) AS n_bin_white, FLOOR(white*10) AS bin_white, 
  ROUND(100 * AVG(white))        AS avg_white_pct,
  ROUND(100 * AVG(black))        AS avg_black_pct,
  ROUND(100 * AVG(hispanic))     AS avg_hisp_pct,
  ROUND(100 * AVG(native+asian)) AS avg_other_pct,
  ROUND(      AVG(enrollment))   AS avg_enrollment,
  ROUND(      STD(enrollment))   AS stdev_enrollment
  FROM student_campus_year s
  GROUP BY bin_white DESC
;
SELECT "Time ", NOW();

-- by %white (in bins of 10%), y1 => y2 math_bin transitions
SELECT      s.m_bin1, s.m_bin2,  
  FLOOR(white*10)           AS bin_white,
  COUNT(*)                  AS num_in_m_bin12 
  FROM      student_trans        s
  LEFT JOIN student_campus_year  c ON s.y1 = c.year AND s.id = c.student_id
  GROUP BY  bin_white, s.m_bin1, s.m_bin2
  ORDER BY  bin_white DESC, m_bin1 DESC, m_bin2 DESC
;
SELECT "Time ", NOW();
