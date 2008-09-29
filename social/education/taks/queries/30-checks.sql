SELECT  COUNT(DISTINCT campus_id)  FROM taks_rawk.students s  ;
-- 7908

SELECT  COUNT(DISTINCT id)  	   FROM taks_rawk.campuses c  ;
-- 7597

SELECT * FROM (
  SELECT 'new' AS src, year, COUNT(*) FROM taks_rawk.students AS ct                  GROUP BY year WITH ROLLUP
    UNION
  SELECT 'old' AS src, year, COUNT(*) FROM taks.students      AS ct WHERE missing = 0 GROUP BY year WITH ROLLUP
    UNION
  SELECT '03'  AS src, 2003, COUNT(*) FROM taks.students2003  AS ct WHERE missing = 0
    UNION
  SELECT '04'  AS src, 2004, COUNT(*) FROM taks.students2004  AS ct WHERE missing = 0
    UNION
  SELECT '05'  AS src, 2005, COUNT(*) FROM taks.students2005  AS ct WHERE missing = 0
    UNION
  SELECT '06'  AS src, 2006, COUNT(*) FROM taks.students2006  AS ct WHERE missing = 0
    UNION
  SELECT '07'  AS src, 2007, COUNT(*) FROM taks.students2007  AS ct WHERE missing = 0
) counts
ORDER BY year ASC

