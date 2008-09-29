
SELECT n_c_03+ n_c_04+ n_c_05+ n_c_06+ n_c_07, sall.*, s03.*, s04.*, s05.*, s06.*, s07.*
  FROM        (SELECT campus AS campus_all,  COUNT(*) AS n_c_all FROM taks.students     GROUP BY campus) sall
  LEFT JOIN   (SELECT campus AS campus_2003, COUNT(*) AS n_c_03  FROM taks.students2003 GROUP BY campus) s03 ON s03.campus_2003 = sall.campus_all
  LEFT JOIN   (SELECT campus AS campus_2004, COUNT(*) AS n_c_04  FROM taks.students2004 GROUP BY campus) s04 ON s04.campus_2004 = sall.campus_all
  LEFT JOIN   (SELECT campus AS campus_2005, COUNT(*) AS n_c_05  FROM taks.students2005 GROUP BY campus) s05 ON s05.campus_2005 = sall.campus_all
  LEFT JOIN   (SELECT campus AS campus_2006, COUNT(*) AS n_c_06  FROM taks.students2006 GROUP BY campus) s06 ON s06.campus_2006 = sall.campus_all
  LEFT JOIN   (SELECT campus AS campus_2007, COUNT(*) AS n_c_07  FROM taks.students2007 GROUP BY campus) s07 ON s07.campus_2007 = sall.campus_all
  LEFT JOIN   (SELECT campus_code AS campus_r, COUNT(*) AS n_c_r  FROM taks_rawk.campus_id_codes) sr ON sr.campus_r = sall.campus_all


SELECT *
  FROM        (SELECT campus      AS campus_old, COUNT(*) AS n_c_old  FROM taks.students     GROUP BY campus) sy
  LEFT JOIN   (SELECT campus_code AS campus_new, 1        AS n_c_new  FROM taks_rawk.campus_id_codes        ) sr ON sr.campus_new = sy.campus_old
  LEFT JOIN   (SELECT DISTINCT campus AS campus_tbl FROM taks.campuses) cold ON sy.campus_old = cold.campus_tbl
  WHERE campus_new IS NULL OR campus_tbl IS NULL

SELECT *
  FROM        (SELECT campus      AS campus_old, COUNT(*) AS n_c_old  FROM taks.students2003 GROUP BY campus) sy
  LEFT JOIN   (SELECT campus_code AS campus_new, 1        AS n_c_new  FROM taks_rawk.campus_id_codes        ) sr ON sr.campus_new = sy.campus_old

SELECT *
  FROM        (SELECT campus      AS campus_old, COUNT(*) AS n_c_old  FROM taks.students2004 GROUP BY campus) sy
  LEFT JOIN   (SELECT campus_code AS campus_new, 1        AS n_c_new  FROM taks_rawk.campus_id_codes        ) sr ON sr.campus_new = sy.campus_old

SELECT *
  FROM        (SELECT campus      AS campus_old, COUNT(*) AS n_c_old  FROM taks.students2005 GROUP BY campus) sy
  LEFT JOIN   (SELECT campus_code AS campus_new, 1        AS n_c_new  FROM taks_rawk.campus_id_codes        ) sr ON sr.campus_new = sy.campus_old

SELECT *
  FROM        (SELECT campus      AS campus_old, COUNT(*) AS n_c_old  FROM taks.students2006 GROUP BY campus) sy
  LEFT JOIN   (SELECT campus_code AS campus_new, 1        AS n_c_new  FROM taks_rawk.campus_id_codes        ) sr ON sr.campus_new = sy.campus_old

SELECT *
  FROM        (SELECT campus      AS campus_old, COUNT(*) AS n_c_old  FROM taks.students2007 GROUP BY campus) sy
  LEFT JOIN   (SELECT campus_code AS campus_new, 1        AS n_c_new  FROM taks_rawk.campus_id_codes        ) sr ON sr.campus_new = sy.campus_old
