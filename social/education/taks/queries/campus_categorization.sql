SELECT COUNT(*), s.campus_id, s.year, s.disadv, ct.tot_students
  FROM 		students_years s, 
  (SELECT COUNT(*) AS tot_students, campus_id, year FROM students_years GROUP BY campus_id, year) ct
  WHERE ct.campus_id = s.campus_id AND ct.year = s.year
  GROUP BY	s.campus_id, s.year, s.disadv


SELECT COUNT(*), s.campus_id, s.year, s.disadv, if(disadv = 0, 1, 0) AS w
  FROM 		students_years s
  GROUP BY	s.campus_id, s.year, s.disadv  

SELECT DISTINCT s.disadv
  FROM 		students_years s
-- 0 1 2 9  
