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
       s.year,	sid.id,	cid.id,
       s.grade,	s.missing,
       m_irsp,	m_raw,	m_ssc,	m_met,	m_com,	m_scode,
       r_irsp,	r_raw,	r_ssc,	r_met,	r_com,	r_scode,
       ethnic,	disadv,	sex,	migsta,	titlei,	`month`,
       FLOOR(m_raw/6.1), FLOOR(r_raw/6.1)
    FROM          taks.students2007 s,
    		  taks_rawk.student_id_codes sid,
		  taks_rawk.campus_id_codes  cid
    WHERE 	  s.stuidnum = sid.student_code
    AND 	  s.campus   = cid.campus_code
    AND 	  s.missing  = 0
-- LIMIT 200000
;
