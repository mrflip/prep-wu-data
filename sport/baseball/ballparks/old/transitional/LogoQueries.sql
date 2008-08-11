-- All franchise-year-logos
SELECT COUNT(*) AS dupeChk, T.franchID, T.teamID, T.yearID, T.name, F.franchName, L.*
  FROM 		vizsagedb_baseballdatabank.Teams                T
  LEFT JOIN	vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  LEFT JOIN	Parks_logos L ON (T.franchID = L.franchID AND T.yearID BETWEEN L.beg AND L.end)
  WHERE 	(0 OR (L.logoType="LPri"))
  GROUP BY	T.franchID, T.yearID
  ORDER BY 	L.logoID IS NULL DESC, T.franchID, T.yearID, L.logoID

-- All franchise-year-logos grouped by logo
SELECT COUNT(yearID) AS years, T.franchID, F.franchName, L.*
  FROM 		vizsagedb_baseballdatabank.Teams                T
  LEFT JOIN	vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  RIGHT JOIN	Parks_logos L ON (T.franchID = L.franchID)
  WHERE 	(1 OR (L.logoType="LPri"))
	AND		((T.yearID BETWEEN L.beg AND L.end) OR (T.yearID=2006 AND L.beg>2006))
  GROUP BY	logoID
  ORDER BY 	T.franchID, T.yearID, L.logoID


-- =========================================================================================
--
-- Raw table queries
--
-- =========================================================================================


-- Multiple logo types in same year. Sigh.
SELECT Count(*) AS num, L.* 
FROM Parks_logos_raw L
GROUP BY franchName, role, type, beg, end
ORDER BY num DESC, franchName, role, type, beg, end

-- All distinct BDB ID'd franchises with logos
SELECT DISTINCT L.franchID FROM Parks_logos_raw L WHERE L.franchID != ''

-- All franchise-years
SELECT T.franchID, T.teamID, T.yearID, T.name, F.franchName
  FROM 		vizsagedb_baseballdatabank.Teams                T
  LEFT JOIN	vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID

-- franchise history
SELECT T.franchID, 
	COUNT(DISTINCT T.name) AS nNames, GROUP_CONCAT(DISTINCT T.teamID SEPARATOR ' |' ) as teamIDs, 
	MIN(T.yearID) AS beg, MAX(T.yearID) AS end, 
	GROUP_CONCAT(DISTINCT T.name SEPARATOR ' |' ) as teamNames, F.franchName
  FROM 		vizsagedb_baseballdatabank.Teams           T
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  WHERE		1
    AND		(1 OR T.franchID IN ('BAL'))
GROUP BY 	T.franchID
ORDER BY 	T.franchID, T.teamID

-- Team names re-used by different franchises
SELECT T.name, 
	COUNT(DISTINCT T.franchID) AS nFr, GROUP_CONCAT(DISTINCT T.franchID SEPARATOR ' |' ) as teamIDs, 
	MIN(T.yearID) AS beg, MAX(T.yearID) AS end, 
	GROUP_CONCAT(DISTINCT CONCAT(F.franchName, ' (',T.lgID,')') SEPARATOR ' |' ) as franchNames
  FROM 		vizsagedb_baseballdatabank.Teams           T
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  WHERE		1
    AND		(1 OR T.franchID IN ('BAL'))
GROUP BY 	T.name HAVING nFr > 1
ORDER BY 	T.name

-- Team names re-used by different franchises
SELECT COUNT(DISTINCT Q.franchID) AS nFrs, CONCAT('The ', Q.name, ' were in ', GROUP_CONCAT(DISTINCT CONCAT(franchID, ' from ', beg, '-', end, ' as ', Q.franchName) SEPARATOR ' and ')) AS helpful
FROM (
SELECT T.name, 
	CONCAT(F.franchID,   ' (',T.lgID,')') AS franchID, 
	MIN(T.yearID) AS beg, MAX(T.yearID)   AS end, 
	CONCAT(F.franchName, ' (',T.lgID,')') AS franchName
  FROM 		vizsagedb_baseballdatabank.Teams           T
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  WHERE		1
    AND		(1 OR T.franchID IN ('BAL'))
	AND		T.lgID IN ('AL', 'NL')
GROUP BY 	T.name, franchID
ORDER BY 	T.name
) Q
GROUP BY Q.name HAVING nFrs > 1

-- Primary logo information (if any) for each Franchise - Year; AL-NL teams only
SELECT COUNT(*) AS uniqChk, T.franchID, T.teamID, T.yearID, T.lgID, T.name, F.franchName, L.*
  FROM		vizsagedb_baseballdatabank.Teams T 
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  LEFT JOIN	Parks_logos_raw L
	ON  	(L.role='Primary') AND (T.franchID = L.franchID) AND (T.yearID BETWEEN L.beg AND L.end)
  WHERE 	(T.lgID IN ('AL', 'NL')) OR (L.beg IS NOT NULL)
	-- AND  	L.beg IS NULL
  GROUP BY	sl_lgID, T.franchID, T.yearID 
  ORDER BY	uniqChk DESC, L.beg IS NULL DESC, T.lgID, T.franchID, T.yearID

-- Errata :
CHW 	1917 is also 1919-1929 and 1931, 1936-1938
CLE 	1980 is also 1951-1972
CHC	(1905, 1915, 1917)?
STL	(1920, 1921)?


-- Primary logo (if any) for each Franchise - Year is missing; AL-NL teams only
SELECT COUNT(*) AS uniqChk, T.franchID, T.teamID, T.yearID, T.lgID, T.name, F.franchName, L.*
  FROM		vizsagedb_baseballdatabank.Teams T 
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  LEFT JOIN	Parks_logos_raw L
	ON  	(L.role='Primary') AND (T.franchID = L.franchID) AND (T.yearID BETWEEN L.beg AND L.end)
  WHERE 	((T.lgID IN ('AL', 'NL')) OR (L.beg IS NOT NULL)) 
  GROUP BY	sl_lgID, T.franchID, T.yearID 
  ORDER BY	uniqChk DESC, L.beg IS NULL DESC, T.lgID, T.franchID, T.yearID


-- Primary logo (if any) for each Franchise - Year is missing; AL-NL teams only
SELECT T.franchID, T.teamID, T.yearID, T.lgID, IFNULL(L.beg,Lfix.beg) AS beg, IFNULL(L.end,Lfix.end) AS end, IFNULL(L.logoID, Lfix.logoID) AS logoID, IFNULL(L.filename, Lfix.filename) AS filename
  FROM		vizsagedb_baseballdatabank.Teams T 
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON T.franchID = F.franchID
  LEFT JOIN	Parks_logos_raw L
	ON  	( (L.role='Primary') AND (T.franchID = L.franchID) AND (T.yearID BETWEEN L.beg AND L.end) )  
  LEFT JOIN	Parks_logos_raw Lfix
	ON		(L.beg IS NULL) AND ( (CONCAT('_', T.lgID) = Lfix.franchID) AND (Lfix.role='Primary') AND (T.yearID BETWEEN Lfix.beg AND Lfix.end) )
  GROUP BY	T.franchID, T.yearID, L.franchID, Lfix.franchID
  ORDER BY	T.lgID, T.franchID, T.yearID

-- List the missing years, show they have no gaps (except CNA which didn't play for 1872-1873)
SELECT T.franchID, T.teamID, MIN(T.yearID) AS begMiss, MAX(T.yearID) AS endMiss, (1 + MAX(T.yearID) - MIN(T.yearID)), COUNT(DISTINCT yearID)-(1 + MAX(T.yearID) - MIN(T.yearID)), T.lgID, L.beg
	  FROM		vizsagedb_baseballdatabank.Teams T
	  LEFT JOIN	Parks_logos_raw L ON ( (L.role='Primary') AND (T.franchID = L.franchID) AND (T.yearID BETWEEN L.beg AND L.end) )  
	  WHERE L.beg IS NULL
	  GROUP BY	T.franchID
	  ORDER BY T.lgID, T.franchID,begMiss

-- Distinct Logos, including team placeholders, not including leagues
SELECT T.franchID, L.franchID, T.teamID, T.yearID, T.lgID, IFNULL(L.beg,Lfix.beg) AS beg, IFNULL(L.end,Lfix.end) AS end, IFNULL(L.logoID, Lfix.logoID) AS logoID, IFNULL(L.filename, Lfix.filename) AS filename
  FROM		vizsagedb_baseballdatabank.Teams T 
  LEFT JOIN vizsagedb_baseballdatabank.TeamsFranchises F ON (T.franchID = F.franchID)
  LEFT JOIN	Parks_logos_raw L
	ON  	( (T.franchID = L.franchID) AND (T.yearID BETWEEN L.beg AND L.end) )
  LEFT JOIN	Parks_logos_raw Lfix
	ON		(L.beg IS NULL) AND ( (CONCAT('_', T.lgID) = Lfix.franchID) AND (Lfix.role='Primary') AND (T.yearID BETWEEN Lfix.beg AND Lfix.end) )
  GROUP BY	T.franchID, L.franchID, IFNULL(L.beg,Lfix.beg), IFNULL(L.end,Lfix.end), IFNULL(L.filename, Lfix.filename)
  ORDER BY	T.lgID, T.franchID, T.yearID
