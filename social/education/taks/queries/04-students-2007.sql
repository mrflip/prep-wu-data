INSERT IGNORE INTO `taks_rawk`.`student_id_codes` (student_code)
  SELECT DISTINCT s.stuidnum FROM taks.students2007 s
;
INSERT IGNORE INTO `taks_rawk`.`students` (
       `year`,	id,	campus_id,
       grade,	missing,
       m_irsp,	m_raw,	m_ssc,	m_met,	m_com,	m_scode,
       r_irsp,	r_raw,	r_ssc,	r_met,	r_com,	r_scode,
       ethnic,	disadv,	sex,	migsta,	titlei,	`month`,
       m_bin,	r_bin)
  SELECT 
       s.year,	sid.id,	s.campus,
       s.grade,	s.missing,
       m_irsp,	m_raw,	m_ssc,	m_met,	m_com,	m_scode,
       r_irsp,	r_raw,	r_ssc,	r_met,	r_com,	r_scode,
       ethnic,	disadv,	sex,	migsta,	titlei,	`month`,
       FLOOR(m_raw/6.1), FLOOR(r_raw/6.1)
    FROM          taks.students2007 s,
    		  taks_rawk.student_id_codes sid
    WHERE 	  s.stuidnum = sid.student_code
    AND 	  (s.missing  = 0 OR s.missing IS NULL)
-- LIMIT 200000
;
SELECT
  (SELECT COUNT(*) AS num_students    FROM `taks_rawk`.`students` ),
  (SELECT COUNT(*) AS num_students_07 FROM `taks_rawk`.`students` s WHERE s.year = 2007);
