

ALTER TABLE `vizsagedb_baseballdatabank`.`Teams` 
	ADD INDEX teamyear (teamIDretro, yearID, lgID), 
	ADD INDEX yearteam (yearID, lgID, teamIDretro), 
	ADD INDEX franchyear (franchID, yearID, lgID), 
	ADD INDEX yearfranch (yearID, franchID, lgID), 
	ADD INDEX DivWin (DivWin), 
	ADD INDEX LgWin (LgWin), 
	ADD INDEX H    (H),
	ADD INDEX HR   (HR),
	ADD INDEX BB   (BB),
	ADD INDEX SO   (SO),
	ADD INDEX ERA  (ERA),
	ADD INDEX park (park)
	;

ALTER TABLE `vizsagedb_retrosheet`.`TeamGames`
	ADD INDEX teamyear (teamID, yearID, lgID), 
	ADD INDEX yearteam (yearID, lgID, teamID), 
	ADD INDEX gameID   (`date`,`gameNumInDay`, `teamID`,`opp_teamID`),
	ADD INDEX yearID   (yearID),
	ADD INDEX homeTeam (homeTeam),
	ADD INDEX park_ID  (park_ID),
	ADD INDEX R    (R),
	ADD INDEX H    (H),
	ADD INDEX HR   (HR),
	ADD INDEX BB   (BB),
	ADD INDEX SO   (SO),
	ADD INDEX ER   (ER),
	ADD INDEX lengthOuts   (lengthOuts)

-- Gamelog Team-years (home only)
SELECT GT.h_team, YEAR(GT.date) AS yearID, COUNT(*) AS G, GT.h_league, 
		GROUP_CONCAT(DISTINCT park_ID ORDER BY park_ID SEPARATOR ', ') AS parkIDs, 
		SUM(GT.h_score) AS R, SUM(GT.v_score) AS RA, 
		SUM(GT.h_AB) AS AB,  SUM(GT.h_H) AS H,  SUM(GT.h_2B) AS 2B,  SUM(GT.h_3B) AS 3B,  SUM(GT.h_HR) AS HR,  SUM(GT.h_BB) AS BB,  SUM(GT.h_HBP) AS HBP,  SUM(GT.h_CatInt) AS CatInt,  
		SUM(GT.v_AB) AS ABA, SUM(GT.v_H) AS HA, SUM(GT.v_2B) AS 2BA, SUM(GT.v_3B) AS 3BA, SUM(GT.v_HR) AS HRA, SUM(GT.v_BB) AS BBA, SUM(GT.v_HBP) AS HBPA, SUM(GT.v_CatInt) AS CatIntA, 
		SUM(GT.h_SO) AS SO,  SUM(GT.h_SB) AS SB,  SUM(GT.h_CS) AS CS,  SUM(GT.h_LOB) AS LOB,  SUM(GT.h_RBI) AS RBI,  SUM(GT.h_SH) AS SH,  SUM(GT.h_SF) AS SF,  SUM(GT.h_IBB) AS IBB,  
		SUM(GT.v_SO) AS SOA, SUM(GT.v_SB) AS SBA, SUM(GT.v_CS) AS CSA, SUM(GT.v_LOB) AS LOBA, SUM(GT.v_RBI) AS RBIA, SUM(GT.v_SH) AS SHA, SUM(GT.v_SF) AS SFA, SUM(GT.v_IBB) AS IBBA, 
		SUM(GT.h_ER) AS ER,   SUM(GT.v_score=0) AS SHO,  SUM(GT.pitSV_ID!='') AS SV,  SUM(GT.h_TeamER) AS TeamER,  SUM(GT.h_WP) AS WP,  SUM(GT.h_BK) AS BK,  
		SUM(GT.v_ER) AS ER_A, SUM(GT.h_score=0) AS SHOA, SUM(GT.pitSV_ID!='') AS SVA, SUM(GT.v_TeamER) AS TeamERA, SUM(GT.v_WP) AS WPA, SUM(GT.v_BK) AS BKA, 
		SUM(GT.h_PO) AS PO,  SUM(GT.h_A) AS A,  SUM(GT.h_E) AS E,  SUM(GT.h_PB) AS PB,  SUM(GT.h_DP) AS DP,  SUM(GT.h_TP) AS TP,  SUM(GT.h_GIDP) AS GIDP,  
		SUM(GT.v_PO) AS POA, SUM(GT.v_A) AS AA, SUM(GT.v_E) AS EA, SUM(GT.v_PB) AS PBA, SUM(GT.v_DP) AS DPA, SUM(GT.v_TP) AS TPA, SUM(GT.v_GIDP) AS GIDPA,
		SUM(GT.attendance) as totAttendance, SUM(GT.duration) AS totDuraction, 1
  FROM vizsagedb_retrosheet.GamesFlat GT
GROUP BY YEAR(GT.date), GT.h_team, GT.h_league


-- Gamelog Team-years 
SELECT GT.teamID, YEAR(GT.date) AS yearID, GT.lgID, 
		COUNT(*) AS G, SUM(GT.hometeam) AS Ghome,
		GROUP_CONCAT(DISTINCT IF(GT.hometeam=1, GT.park_ID, NULL) ORDER BY park_ID SEPARATOR ', ') AS parkIDs, 
		SUM(GT.R) AS R, SUM(GT.opp_R) AS RA, 
		SUM(GT.AB) AS AB,       SUM(GT.H) AS H,         SUM(GT.2B) AS 2B,      SUM(GT.3B) AS 3B,        SUM(GT.HR) AS HR,        SUM(GT.BB) AS BB,      SUM(GT.CatIn) AS CatInt,      
		SUM(GT.opp_AB) AS ABA,  SUM(GT.opp_H) AS HA,    SUM(GT.opp_2B) AS 2BA, SUM(GT.opp_3B) AS 3BA,   SUM(GT.opp_HR) AS HRA,   SUM(GT.opp_BB) AS BBA, SUM(GT.opp_CatIn) AS CatIntA, 
		SUM(GT.SO) AS SO,       SUM(GT.SB) AS SB,       SUM(GT.CS) AS CS,      SUM(GT.HBP) AS HBP,      SUM(GT.LOB) AS LOB,      SUM(GT.RBI) AS RBI,      SUM(GT.SH) AS SH,      SUM(GT.SF) AS SF,       SUM(GT.IBB) AS IBB,      
		SUM(GT.opp_SO) AS SOA,  SUM(GT.opp_SB) AS SBA,  SUM(GT.opp_CS) AS CSA, SUM(GT.opp_HBP) AS HBPA, SUM(GT.opp_LOB) AS LOBA, SUM(GT.opp_RBI) AS RBIA, SUM(GT.opp_SH) AS SHA, SUM(GT.opp_SF) AS SFA,  SUM(GT.opp_IBB) AS IBBA, 
		SUM(GT.ER) AS ER,       SUM(GT.opp_R=0) AS SHO, SUM(GT.NPitchers=1) AS CG,         SUM(GT.TeamER) AS TeamER,      SUM(GT.WP) AS WP,      SUM(GT.BK) AS BK,      
		SUM(GT.opp_ER) AS ER_A, SUM(GT.R=0) AS SHOA,    SUM(GT.opp_NPitchers=1) AS opp_CG, SUM(GT.opp_TeamER) AS TeamERA, SUM(GT.opp_WP) AS WPA, SUM(GT.opp_BK) AS BKA, 
		SUM(GT.PO) AS PO,       SUM(GT.A) AS A,         SUM(GT.E) AS E,      SUM(GT.PB) AS PB,      SUM(GT.DP) AS DP,      SUM(GT.TP) AS TP,      SUM(GT.GIDP) AS GIDP,      
		SUM(GT.opp_PO) AS POA,  SUM(GT.opp_A) AS AA,    SUM(GT.opp_E) AS EA, SUM(GT.opp_PB) AS PBA, SUM(GT.opp_DP) AS DPA, SUM(GT.opp_TP) AS TPA, SUM(GT.opp_GIDP) AS GIDPA,
		SUM(GT.attendance) as totAttendance, SUM(GT.duration) AS totDuraction, 1
  FROM	vizsagedb_retrosheet.TeamGames GT
GROUP BY YEAR(GT.date), GT.teamID, GT.lgID


-- Gamelog & BDB Team-years -- reduced ser
SELECT GT.teamID, YEAR(GT.date) AS yearID, BT.name, BT.park, BT.franchID, GT.lgID, BT.divID, 
		BT.Rank, BT.DivWin, BT.WCWin, BT.LgWin, BT.WSWin, 
		BT.G, BT.Ghome,  BT.W, BT.L, 
		COUNT(*) AS G, SUM(GT.hometeam) AS Ghome, SUM(result='W') AS W, SUM(result='L') AS L, 
		BT.R, BT.AB, BT.H, BT.2B, BT.3B, BT.HR, BT.BB, 
		SUM(GT.R) AS R, SUM(GT.opp_R) AS RA, 
		SUM(GT.AB) AS AB,       SUM(GT.H) AS H,         SUM(GT.2B) AS 2B,      SUM(GT.3B) AS 3B,        SUM(GT.HR) AS HR,        SUM(GT.BB) AS BB, 
		BT.SO, BT.SB, BT.CS, BT.HBP, BT.SF, 
		BT.RA, BT.ER, BT.ERA, BT.CG, BT.SHO, BT.SV, BT.IPouts, BT.HA, BT.HRA, BT.BBA, BT.SOA, BT.E, BT.DP, BT.FP, 
		BT.attendance, 
		GROUP_CONCAT(DISTINCT IF(GT.hometeam=1, GT.park_ID, NULL) ORDER BY park_ID SEPARATOR ', ') AS parkIDs, 1
  FROM		vizsagedb_retrosheet.TeamGames   GT
  LEFT JOIN	vizsagedb_baseballdatabank.Teams BT ON (GT.teamID = BT.teamID) AND (YEAR(GT.date)=BT.yearID) AND (GT.lgID=BT.lgID)
GROUP BY YEAR(GT.date), GT.teamID, GT.lgID



-- Gamelog & BDB Team-years -- big parallel rows
SELECT GT.*, BT.* 
  FROM	(SELECT GTs.teamID, YEAR(GTs.date) AS yearID, GTs.lgID, 
			COUNT(*) AS G, SUM(GTs.hometeam) AS Ghome,
			GROUP_CONCAT(DISTINCT IF(GTs.hometeam=1, GTs.park_ID, NULL) ORDER BY park_ID SEPARATOR ', ') AS parkIDs, 
			SUM(GTs.R) AS R, SUM(GTs.opp_R) AS RA, 
			SUM(GTs.AB) AS AB,       SUM(GTs.H) AS H,         SUM(GTs.2B) AS 2B,      SUM(GTs.3B) AS 3B,        SUM(GTs.HR) AS HR,        SUM(GTs.BB) AS BB,      SUM(GTs.CatIn) AS CatInt,      SUM(GTs.SO) AS SO,       
			SUM(GTs.opp_AB) AS ABA,  SUM(GTs.opp_H) AS HA,    SUM(GTs.opp_2B) AS 2BA, SUM(GTs.opp_3B) AS 3BA,   SUM(GTs.opp_HR) AS HRA,   SUM(GTs.opp_BB) AS BBA, SUM(GTs.opp_CatIn) AS CatIntA, SUM(GTs.opp_SO) AS SOA,  
			SUM(GTs.SB) AS SB,       SUM(GTs.CS) AS CS,      SUM(GTs.HBP) AS HBP,      SUM(GTs.LOB) AS LOB,      SUM(GTs.RBI) AS RBI,      SUM(GTs.SH) AS SH,      SUM(GTs.SF) AS SF,       SUM(GTs.IBB) AS IBB,      
			SUM(GTs.opp_SB) AS SBA,  SUM(GTs.opp_CS) AS CSA, SUM(GTs.opp_HBP) AS HBPA, SUM(GTs.opp_LOB) AS LOBA, SUM(GTs.opp_RBI) AS RBIA, SUM(GTs.opp_SH) AS SHA, SUM(GTs.opp_SF) AS SFA,  SUM(GTs.opp_IBB) AS IBBA, 
			SUM(GTs.ER) AS ER,       SUM(GTs.opp_R=0) AS SHO, SUM(GTs.NPitchers=1) AS CG,         SUM(GTs.TeamER) AS TeamER,      SUM(GTs.WP) AS WP,      SUM(GTs.BK) AS BK,      
			SUM(GTs.opp_ER) AS ER_A, SUM(GTs.R=0) AS SHOA,    SUM(GTs.opp_NPitchers=1) AS opp_CG, SUM(GTs.opp_TeamER) AS TeamERA, SUM(GTs.opp_WP) AS WPA, SUM(GTs.opp_BK) AS BKA, 
			SUM(GTs.PO) AS PO,       SUM(GTs.A) AS A,         SUM(GTs.E) AS E,      SUM(GTs.PB) AS PB,      SUM(GTs.DP) AS DP,      SUM(GTs.TP) AS TP,      SUM(GTs.GIDP) AS GIDP,      
			SUM(GTs.opp_PO) AS POA,  SUM(GTs.opp_A) AS AA,    SUM(GTs.opp_E) AS EA, SUM(GTs.opp_PB) AS PBA, SUM(GTs.opp_DP) AS DPA, SUM(GTs.opp_TP) AS TPA, SUM(GTs.opp_GIDP) AS GIDPA,
			SUM(GTs.attendance) as totAttendance, SUM(GTs.duration) AS totDuraction, 1
		  FROM	vizsagedb_retrosheet.TeamGames GTs
		  GROUP BY YEAR(GTs.date), GTs.teamID, GTs.lgID) GT
  RIGHT JOIN	vizsagedb_baseballdatabank.Teams BT ON (GT.yearID=BT.yearID) AND (GT.lgID=BT.lgID) AND ((GT.teamID = BT.teamIDretro) OR (GT.teamID='ANA' AND BT.teamIDretro='ALA'))



-- Gamelog & BDB Team-years -- check
SELECT 
		SUM(Gdx != 0) AS GdxD,     SUM(GHdx != 0) AS GHdxD,   SUM(Wdx != 0) AS WdxD,     SUM(Ldx != 0) AS LdxD,  
		SUM(Rdx != 0) AS RdxD,     SUM(RAdx != 0) AS RAdxD,   SUM(ERdx != 0) AS ERdxD,    
		SUM(ABdx != 0) AS ABdxD,   SUM(Hdx != 0) AS HdxD,     SUM(2Bdx != 0) AS 2BdxD,   SUM(3Bdx != 0) AS 3BdxD,    
		SUM(HRdx != 0) AS HRdxD,   SUM(BBdx != 0) AS BBdxD,   SUM(SOdx != 0) AS SOdxD,  
		SUM(SBdx != 0) AS SBdxD,   SUM(CSdx != 0) AS CSdxD,   SUM(HBPdx != 0) AS HBPdxD, SUM(SFdx != 0) AS SFdxD,  
		SUM(CGdx != 0) AS CGdxD,   SUM(SHOdx != 0) AS SHOdxD, SUM(HAdx != 0) AS HAdxD,   SUM(HRAdx != 0) AS HRAdxD,  
		SUM(BBAdx != 0) AS BBAdxD, SUM(SOAdx != 0) AS SOAdxD, SUM(Edx != 0) AS EdxD,     SUM(DPdx != 0) AS DPdxD
FROM (
SELECT GT.teamID, GT.yearID, -- BT.name, BT.park, BT.franchID, GT.lgID, BT.divID, BT.Rank, BT.DivWin, BT.WCWin, BT.LgWin, BT.WSWin, 
		BT.R AS btR, GT.R AS gtR, BT.RA AS btRA, GT.RA, BT.ER AS btER, GT.aER, GT.tER, GT.ER AS gtER,
		(CAST(BT.G AS SIGNED INTEGER)-GT.G)       AS Gdx, (BT.Ghome-GT.Ghome) AS GHdx, (BT.W-GT.W)    AS Wdx,   (BT.L-GT.L)   AS Ldx,  
		(BT.R-GT.R)     AS Rdx,   (BT.RA-GT.RA)   AS RAdx,  (BT.ER-GT.ER)   AS ERdx,    
		(BT.AB-GT.AB)   AS ABdx,  (BT.H-GT.H)     AS Hdx,   (BT.2B-GT.2B)   AS 2Bdx,  (BT.3B-GT.3B) AS 3Bdx,    
		(BT.HR-GT.HR)   AS HRdx,  (BT.BB-GT.BB)   AS BBdx,  (BT.SO-GT.SO)   AS SOdx,  
		(BT.CG-GT.CG)   AS CGdx,  (BT.SHO-GT.SHO) AS SHOdx, (BT.HA-GT.HA)   AS HAdx,  (BT.HRA-GT.HRA) AS HRAdx,  
		(BT.BBA-GT.BBA) AS BBAdx, (BT.SOA-GT.SOA) AS SOAdx, (BT.E-GT.E)     AS Edx,   
		IFNULL(BT.SB-GT.SB,0)   AS SBdx,              IFNULL(BT.CS-GT.CS,0)   AS CSdx,  IFNULL(BT.SF-GT.SF,0)   AS SFdx,  
		IFNULL(BT.HBP-GT.HBP,0) AS HBPdx,             IFNULL(BT.DP-GT.DP,0)   AS DPdx,  
		(BT.attendance-GT.attendance) AS attendancedx
  FROM	(SELECT GTs.teamID, YEAR(GTs.date) AS yearID, GTs.lgID, 
			COUNT(*) AS G, SUM(GTs.hometeam) AS Ghome, SUM(GTs.result='W') AS W, SUM(GTs.result='L') AS L, 
			GROUP_CONCAT(DISTINCT IF(GTs.hometeam=1, GTs.park_ID, NULL) ORDER BY park_ID SEPARATOR ', ') AS parkIDs,  
			SUM(GTs.R)      AS R,    SUM(GTs.opp_R)  AS RA, 
			SUM(GTs.AB)     AS AB,   SUM(GTs.H)      AS H,   SUM(GTs.2B)      AS 2B,   SUM(GTs.3B)      AS 3B,    SUM(GTs.HR)      AS HR,   SUM(GTs.BB) AS BB,      SUM(GTs.SO) AS SO,      SUM(GTs.CatIn) AS CatInt,      
			SUM(GTs.opp_AB) AS ABA,  SUM(GTs.opp_H)  AS HA,  SUM(GTs.opp_2B)  AS 2BA,  SUM(GTs.opp_3B)  AS 3BA,   SUM(GTs.opp_HR)  AS HRA,  SUM(GTs.opp_BB) AS BBA, SUM(GTs.opp_SO) AS SOA, SUM(GTs.opp_CatIn) AS CatIntA, 
			SUM(GTs.SB)     AS SB,   SUM(GTs.CS)     AS CS,  SUM(GTs.HBP)     AS HBP,  SUM(GTs.LOB)     AS LOB,   SUM(GTs.RBI)     AS RBI,  SUM(GTs.SH) AS SH,      SUM(GTs.SF) AS SF,      SUM(GTs.IBB) AS IBB,      
			SUM(GTs.opp_SB) AS SBA,  SUM(GTs.opp_CS) AS CSA, SUM(GTs.opp_HBP) AS HBPA, SUM(GTs.opp_LOB) AS LOBA,  SUM(GTs.opp_RBI) AS RBIA, SUM(GTs.opp_SH) AS SHA, SUM(GTs.opp_SF) AS SFA, SUM(GTs.opp_IBB) AS IBBA, 
			SUM(GTs.PO)     AS PO,   SUM(GTs.A)      AS A,   SUM(GTs.E)       AS E,    SUM(GTs.PB)      AS PB,    SUM(GTs.DP)      AS DP,   SUM(GTs.TP) AS TP,      SUM(GTs.GIDP) AS GIDP,      
			SUM(GTs.opp_PO) AS POA,  SUM(GTs.opp_A)  AS AA,  SUM(GTs.opp_E)   AS EA,   SUM(GTs.opp_PB)  AS PBA,   SUM(GTs.opp_DP)  AS DPA,  SUM(GTs.opp_TP) AS TPA, SUM(GTs.opp_GIDP) AS GIDPA,
			SUM(GTs.opp_R=0) AS SHO, SUM(GTs.WP)     AS WP,  SUM(GTs.BK)      AS BK,    
			SUM(GTs.R=0)    AS SHOA, SUM(GTs.opp_WP) AS WPA, SUM(GTs.opp_BK)  AS BKA,   
			SUM(GTs.TeamER+GTs.ER)         AS aER,   SUM(GTs.TeamER)     AS tER,   SUM(GTs.ER)     AS ER,   SUM(GTs.NPitchers=1)     AS CG,         
			SUM(GTs.opp_TeamER+GTs.opp_ER) AS aER_A, SUM(GTs.opp_TeamER) AS tER_A, SUM(GTs.opp_ER) AS ER_A, SUM(GTs.opp_NPitchers=1) AS opp_CG, 
			SUM(IF(GTs.hometeam,GTs.attendance,0)) as attendance, SUM(IF(GTs.hometeam,0,GTs.attendance)) as att_road, 
			SUM(GTs.duration) AS duraction, 1
		  FROM	vizsagedb_retrosheet.TeamGames GTs
		  WHERE GTs.forfeitInfo=''
		  GROUP BY YEAR(GTs.date), GTs.teamID, GTs.lgID) GT
  RIGHT JOIN	vizsagedb_baseballdatabank.Teams BT ON (GT.yearID=BT.yearID) AND (GT.lgID=BT.lgID) AND ((GT.teamID = BT.teamIDretro) OR (GT.teamID='ANA' AND BT.teamIDretro='ALA'))
  WHERE GT.yearID >= 1957
  ORDER BY 	GT.yearID DESC, GT.lgID, GT.teamID, GT.AB IS NULL, 
			ABS(Gdx) DESC,  ABS(GHdx) DESC, ABS(Wdx) DESC,  ABS(Ldx)  DESC, ABS(Rdx) DESC,  ABS(RAdx) DESC, ABS(ABdx) DESC, 
			ABS(Hdx) DESC,  ABS(2Bdx) DESC, ABS(3Bdx) DESC, ABS(HRdx) DESC, ABS(BBdx) DESC, ABS(SOdx) DESC, 
			ABS(HBPdx) DESC,ABS(SFdx) DESC, ABS(CGdx) DESC, ABS(HAdx) DESC, ABS(HRAdx) DESC,ABS(BBAdx) DESC,ABS(SOAdx) DESC, 
			ABS(ERdx) DESC, ABS(SHOdx) DESC,ABS(SBdx) DESC, ABS(CSdx) DESC, ABS(Edx) DESC,  ABS(DPdx) DESC, 
			GT.yearID DESC, GT.lgID, GT.teamID -- 
) Q


GdxD	GHdxD	WdxD	LdxD	RdxD	RAdxD	ABdxD	HdxD	2BdxD	3BdxD	HRdxD	BBdxD	SOdxD	HAdxD	HRAdxD	BBAdxD	SOAdxD	HBPdxD	SFdxD	CGdxD	ERdxD	SHOdxD	SBdxD	CSdxD	EdxD	DPdxD
0  		10  	4  		4  		0  		0	  	18  	5 	 	29  	0 	 	0  		22  	97  	15  	0 	 	28  	94  	1  		0 	 	6 	 	759  	53  	46  	132  	458  	458


  0 	GdxD	 10 	GHdxD	  4 	LdxD	  4 	WdxD	  0 	RdxD	  0 	RAdxD	 
 18 	ABdxD	  5 	HdxD	 29 	2BdxD	  0 	3BdxD	  0 	HRdxD	 22 	BBdxD	 97 	SOdxD	
				 15 	HAdxD									  0 	HRAdxD	 28 	BBAdxD	 94 	SOAdxD	
Innings Pitches, ABA, 2BA, 3Ba

  0 	SFdxD	  1 	HBPdxD	 46 	SBdxD	132 	CSdxD	  6 	CGdxD	 53 	SHOdxD	759 	ERdxD	
458 	DPdxD	458 	EdxD	



SELECT GT.teamID, GT.yearID, -- BT.name, BT.park, BT.franchID, GT.lgID, BT.divID, BT.Rank, BT.DivWin, BT.WCWin, BT.LgWin, BT.WSWin, 
		BT.R AS btR, GT.R AS gtR, BT.RA AS btRA, GT.RA, BT.ER AS btER, GT.aER, GT.tER, GT.ER AS gtER,
		(CAST(BT.G AS SIGNED INTEGER)-GT.G)       AS Gdx, (BT.Ghome-GT.Ghome) AS GHdx, (BT.W-GT.W)    AS Wdx,   (BT.L-GT.L)   AS Ldx,  
		(BT.R-GT.R)     AS Rdx,   (BT.RA-GT.RA)   AS RAdx,  (BT.ER-GT.ER)   AS ERdx,    
		(BT.AB-GT.AB)   AS ABdx,  (BT.H-GT.H)     AS Hdx,   (BT.2B-GT.2B)   AS 2Bdx,  (BT.3B-GT.3B) AS 3Bdx,    
		(BT.HR-GT.HR)   AS HRdx,  (BT.BB-GT.BB)   AS BBdx,  (BT.SO-GT.SO)   AS SOdx,  
		(BT.SB-GT.SB)   AS SBdx,  (BT.CS-GT.CS)   AS CSdx,  (BT.HBP-GT.HBP) AS HBPdx, (BT.SF-GT.SF)   AS SFdx,  
		(BT.CG-GT.CG)   AS CGdx,  (BT.SHO-GT.SHO) AS SHOdx, (BT.HA-GT.HA)   AS HAdx,  (BT.HRA-GT.HRA) AS HRAdx,  
		(BT.BBA-GT.BBA) AS BBAdx, (BT.SOA-GT.SOA) AS SOAdx, (BT.E-GT.E)     AS Edx,   (BT.DP-GT.DP)   AS DPdx,  
		(BT.attendance-GT.attendance) AS attendancedx
  FROM	(SELECT GTs.teamID, YEAR(GTs.date) AS yearID, GTs.lgID, 
			COUNT(*) AS G, SUM(GTs.hometeam) AS Ghome, SUM(GTs.result='W') AS W, SUM(GTs.result='L') AS L, 
			GROUP_CONCAT(DISTINCT IF(GTs.hometeam=1, GTs.park_ID, NULL) ORDER BY park_ID SEPARATOR ', ') AS parkIDs,  
			SUM(GTs.R)      AS R,    SUM(GTs.opp_R)  AS RA, 
			SUM(GTs.AB)     AS AB,   SUM(GTs.H)      AS H,   SUM(GTs.2B)      AS 2B,   SUM(GTs.3B)      AS 3B,    SUM(GTs.HR)      AS HR,   SUM(GTs.BB) AS BB,      SUM(GTs.SO) AS SO,      SUM(GTs.CatIn) AS CatInt,      
			SUM(GTs.opp_AB) AS ABA,  SUM(GTs.opp_H)  AS HA,  SUM(GTs.opp_2B)  AS 2BA,  SUM(GTs.opp_3B)  AS 3BA,   SUM(GTs.opp_HR)  AS HRA,  SUM(GTs.opp_BB) AS BBA, SUM(GTs.opp_SO) AS SOA, SUM(GTs.opp_CatIn) AS CatIntA, 
			SUM(GTs.SB)     AS SB,   SUM(GTs.CS)     AS CS,  SUM(GTs.HBP)     AS HBP,  SUM(GTs.LOB)     AS LOB,   SUM(GTs.RBI)     AS RBI,  SUM(GTs.SH) AS SH,      SUM(GTs.SF) AS SF,      SUM(GTs.IBB) AS IBB,      
			SUM(GTs.opp_SB) AS SBA,  SUM(GTs.opp_CS) AS CSA, SUM(GTs.opp_HBP) AS HBPA, SUM(GTs.opp_LOB) AS LOBA,  SUM(GTs.opp_RBI) AS RBIA, SUM(GTs.opp_SH) AS SHA, SUM(GTs.opp_SF) AS SFA, SUM(GTs.opp_IBB) AS IBBA, 
			SUM(GTs.PO)     AS PO,   SUM(GTs.A)      AS A,   SUM(GTs.E)       AS E,    SUM(GTs.PB)      AS PB,    SUM(GTs.DP)      AS DP,   SUM(GTs.TP) AS TP,      SUM(GTs.GIDP) AS GIDP,      
			SUM(GTs.opp_PO) AS POA,  SUM(GTs.opp_A)  AS AA,  SUM(GTs.opp_E)   AS EA,   SUM(GTs.opp_PB)  AS PBA,   SUM(GTs.opp_DP)  AS DPA,  SUM(GTs.opp_TP) AS TPA, SUM(GTs.opp_GIDP) AS GIDPA,
			SUM(GTs.opp_R=0) AS SHO, SUM(GTs.WP)     AS WP,  SUM(GTs.BK)      AS BK,    
			SUM(GTs.R=0)    AS SHOA, SUM(GTs.opp_WP) AS WPA, SUM(GTs.opp_BK)  AS BKA,   
			SUM(GTs.TeamER+GTs.ER)         AS aER,   SUM(GTs.TeamER)     AS tER,   SUM(GTs.ER)     AS ER,   SUM(GTs.NPitchers=1)     AS CG,         
			SUM(GTs.opp_TeamER+GTs.opp_ER) AS aER_A, SUM(GTs.opp_TeamER) AS tER_A, SUM(GTs.opp_ER) AS ER_A, SUM(GTs.opp_NPitchers=1) AS opp_CG, 
			SUM(IF(GTs.hometeam,GTs.attendance,0)) as attendance, SUM(IF(GTs.hometeam,0,GTs.attendance)) as att_road, 
			SUM(GTs.duration) AS duraction, 1
		  FROM	vizsagedb_retrosheet.TeamGames GTs
		  GROUP BY YEAR(GTs.date), GTs.teamID, GTs.lgID) GT
  RIGHT JOIN	vizsagedb_baseballdatabank.Teams BT ON (GT.yearID=BT.yearID) AND (GT.lgID=BT.lgID) AND ((GT.teamID = BT.teamIDretro) OR (GT.teamID='ANA' AND BT.teamIDretro='ALA'))
  WHERE GT.yearID >= 1957
  ORDER BY 	GT.AB IS NULL, 
			ABS(Gdx) DESC,  ABS(GHdx) DESC, ABS(Wdx) DESC,  ABS(Ldx)  DESC, ABS(Rdx) DESC,  ABS(RAdx) DESC, ABS(ERdx) DESC, ABS(ABdx) DESC, 
			ABS(Hdx) DESC,  ABS(2Bdx) DESC, ABS(3Bdx) DESC, ABS(HRdx) DESC, ABS(BBdx) DESC, ABS(SOdx) DESC, ABS(SBdx) DESC, ABS(CSdx) DESC, 
			ABS(HBPdx) DESC,ABS(SFdx) DESC, ABS(CGdx) DESC, ABS(SHOdx) DESC,ABS(HAdx) DESC, ABS(HRAdx) DESC,ABS(BBAdx) DESC,ABS(SOAdx) DESC, 
			ABS(Edx) DESC,  ABS(DPdx) DESC, GT.yearID, GT.lgID, GT.teamID
