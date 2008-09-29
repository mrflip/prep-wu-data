
-- ---------------------------------------------------------------------------
--
-- Copy values across
--
INSERT IGNORE INTO `taks_rawk`.`student_trans` (
	`y1`,   	`id`,
	`campus_id1`,	`grade1`,
	`m_bin1`,	`m_met1`,	`m_com1`,	`m_scode1`,
	`ethnic1`,	`disadv1`,	`sex1`, 	`migsta1`,	`titlei1`,
	`campus_id2`,	`grade2`,
	`m_bin2`,	`m_met2`,	`m_com2`,	`m_scode2`,
	`ethnic2`,	`disadv2`,	`sex2`, 	`migsta2`,	`titlei2`
)
  SELECT
	sy1.year,	sy1.id,
	sy1.campus_id,	sy1.grade,
	sy1.m_bin,	sy1.m_met,	sy1.m_com,	sy1.m_scode,
	sy1.ethnic,	sy1.disadv,	sy1.sex, 	sy1.migsta,	sy1.titlei,
	sy2.campus_id,	sy2.grade,
	sy2.m_bin,	sy2.m_met,	sy2.m_com,	sy2.m_scode,
	sy2.ethnic,	sy2.disadv,	sy2.sex, 	sy2.migsta,	sy2.titlei
    FROM  	taks_rawk.students sy1
    LEFT JOIN	taks_rawk.students sy2 ON (sy1.id = sy2.id)
    WHERE 	sy1.year = 2003
      AND 	sy2.year = 2004
;
SELECT COUNT(*) AS num_student_trans    FROM `taks_rawk`.`student_trans`;

-- ---------------------------------------------------------------------------
--
-- Copy values across
--
INSERT IGNORE INTO `taks_rawk`.`student_trans` (
	`y1`,   	`id`,
	`campus_id1`,	`grade1`,
	`m_bin1`,	`m_met1`,	`m_com1`,	`m_scode1`,
	`ethnic1`,	`disadv1`,	`sex1`, 	`migsta1`,	`titlei1`,
	`campus_id2`,	`grade2`,
	`m_bin2`,	`m_met2`,	`m_com2`,	`m_scode2`,
	`ethnic2`,	`disadv2`,	`sex2`, 	`migsta2`,	`titlei2`
)
  SELECT
	sy1.year,	sy1.id,
	sy1.campus_id,	sy1.grade,
	sy1.m_bin,	sy1.m_met,	sy1.m_com,	sy1.m_scode,
	sy1.ethnic,	sy1.disadv,	sy1.sex, 	sy1.migsta,	sy1.titlei,
	sy2.campus_id,	sy2.grade,
	sy2.m_bin,	sy2.m_met,	sy2.m_com,	sy2.m_scode,
	sy2.ethnic,	sy2.disadv,	sy2.sex, 	sy2.migsta,	sy2.titlei
    FROM  	taks_rawk.students sy1
    LEFT JOIN	taks_rawk.students sy2 ON (sy1.id = sy2.id)
    WHERE 	sy1.year = 2004
      AND 	sy2.year = 2005
;
SELECT COUNT(*) AS num_student_trans    FROM `taks_rawk`.`student_trans`;

-- ---------------------------------------------------------------------------
--
-- Copy values across
--
INSERT IGNORE INTO `taks_rawk`.`student_trans` (
	`y1`,   	`id`,
	`campus_id1`,	`grade1`,
	`m_bin1`,	`m_met1`,	`m_com1`,	`m_scode1`,
	`ethnic1`,	`disadv1`,	`sex1`, 	`migsta1`,	`titlei1`,
	`campus_id2`,	`grade2`,
	`m_bin2`,	`m_met2`,	`m_com2`,	`m_scode2`,
	`ethnic2`,	`disadv2`,	`sex2`, 	`migsta2`,	`titlei2`
)
  SELECT
	sy1.year,	sy1.id,
	sy1.campus_id,	sy1.grade,
	sy1.m_bin,	sy1.m_met,	sy1.m_com,	sy1.m_scode,
	sy1.ethnic,	sy1.disadv,	sy1.sex, 	sy1.migsta,	sy1.titlei,
	sy2.campus_id,	sy2.grade,
	sy2.m_bin,	sy2.m_met,	sy2.m_com,	sy2.m_scode,
	sy2.ethnic,	sy2.disadv,	sy2.sex, 	sy2.migsta,	sy2.titlei
    FROM  	taks_rawk.students sy1
    LEFT JOIN	taks_rawk.students sy2 ON (sy1.id = sy2.id)
    WHERE 	sy1.year = 2005
      AND 	sy2.year = 2006
;
SELECT COUNT(*) AS num_student_trans    FROM `taks_rawk`.`student_trans`;

-- ---------------------------------------------------------------------------
--
-- Copy values across
--
INSERT IGNORE INTO `taks_rawk`.`student_trans` (
	`y1`,   	`id`,
	`campus_id1`,	`grade1`,
	`m_bin1`,	`m_met1`,	`m_com1`,	`m_scode1`,
	`ethnic1`,	`disadv1`,	`sex1`, 	`migsta1`,	`titlei1`,
	`campus_id2`,	`grade2`,
	`m_bin2`,	`m_met2`,	`m_com2`,	`m_scode2`,
	`ethnic2`,	`disadv2`,	`sex2`, 	`migsta2`,	`titlei2`
)
  SELECT
	sy1.year,	sy1.id,
	sy1.campus_id,	sy1.grade,
	sy1.m_bin,	sy1.m_met,	sy1.m_com,	sy1.m_scode,
	sy1.ethnic,	sy1.disadv,	sy1.sex, 	sy1.migsta,	sy1.titlei,
	sy2.campus_id,	sy2.grade,
	sy2.m_bin,	sy2.m_met,	sy2.m_com,	sy2.m_scode,
	sy2.ethnic,	sy2.disadv,	sy2.sex, 	sy2.migsta,	sy2.titlei
    FROM  	taks_rawk.students sy1
    LEFT JOIN	taks_rawk.students sy2 ON (sy1.id = sy2.id)
    WHERE 	sy1.year = 2006
      AND 	sy2.year = 2007
;
SELECT COUNT(*) AS num_student_trans    FROM `taks_rawk`.`student_trans`;
