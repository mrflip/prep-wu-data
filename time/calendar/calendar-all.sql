
-- Time Zone Transition info
SELECT TZ.tzName, TZ.tzID, 
	TZT.transTS, 
	DATE_ADD(FROM_UNIXTIME(0), INTERVAL TZT.transTS SECOND) AS transDateTime,
	TZT.transTypeID, 
	TZY.offset, TZY.offset DIV 3600 AS o_hrs, (TZY.offset % 60) DIV 60 AS o_mins, (TZY.offset % 3600) AS o_secs,
	TZY.DST_flag, TZY.tzAbbrev
  FROM  	time_zone_name 		  TZ
  LEFT JOIN	time_zone_transition	  TZT ON (TZ.tzID = TZT.tzID)
  LEFT JOIN	time_zone_transition_type TZY ON (TZ.tzID = TZY.tzID) AND (TZT.transTypeID = TZY.transTypeID)
  WHERE 	TZ.tzName LIKE 'US/Central'

-- The TZ transitions are unique: this returns no rows.
SELECT COUNT(*) AS n FROM time_zone_transition t GROUP BY tzID, transTS HAVING n!=1

-- Turn each transition into an interval, 
-- bracketed by '0001-01-01 00:00:00' and '2037-12-31 23:59:59' 
-- (the end of the UNIX epoch, which is when the info here stops being valid)
SELECT TZB.tzID, TZB.transTypeID,
		TZB.transTS AS ruleBegTS, TZE.transTS AS ruleEndTS, 
 	        DATE_ADD(FROM_UNIXTIME(0), INTERVAL     TZB.transTS    SECOND)                          AS ruleBeg,
	IFNULL( DATE_ADD(FROM_UNIXTIME(0), INTERVAL MIN(TZE.transTS)-1 SECOND), '2037-12-31 23:59:59' ) AS ruleEnd

  FROM  	time_zone_transition TZB 
  LEFT JOIN	time_zone_transition TZE ON (TZB.tzID = TZE.tzID) AND TZB.transTS < TZE.transTS 
  GROUP BY TZB.tzID, TZB.transTypeID, TZB.transTS
  ORDER BY tzID, TZB.transTS

-- Time Zone Rule duration info

SELECT TZ.tzName, TZ.tzID, TZB.transTypeID, 
		TZB.transTS AS ruleBegTS, TZE.transTS AS ruleEndTS, 
 	        DATE_ADD(FROM_UNIXTIME(0), INTERVAL     TZB.transTS    SECOND)                          AS ruleBeg,
	IFNULL( DATE_ADD(FROM_UNIXTIME(0), INTERVAL MIN(TZE.transTS)-1 SECOND), '2037-12-31 23:59:59' ) AS ruleEnd
	TZY.offset, TZY.offset DIV 3600 AS o_hrs, (TZY.offset % 60) DIV 60 AS o_mins, (TZY.offset % 3600) AS o_secs,
	TZY.DST_flag, TZY.tzAbbrev
  FROM  	time_zone_transition      TZB 

  FROM  	time_zone_name 		  TZ
  LEFT JOIN	time_zone_transition	  TZB ON (TZ.tzID = TZB.tzID)
  LEFT JOIN	time_zone_transition      TZE ON (TZ.tzID = TZE.tzID) AND (TZB.transTS < TZE.transTS)
  LEFT JOIN	time_zone_transition_type TZY ON (TZ.tzID = TZY.tzID) AND (TZB.transTypeID = TZY.transTypeID)

  GROUP BY TZB.tzID, TZB.transTypeID, TZB.transTS
  ORDER BY tzID, TZB.transTS

  WHERE 	TZ.tzName LIKE 'US/Central'


-- 0000-00-00 to 2037-12-31

-- CREATE TABLE dbo.Calendar  
-- (  
--     dt 		DATETIME NOT NULL PRIMARY KEY CLUSTERED,  
--     isWeekday 	BOOLEAN 	NOT NULL, 
--     isHoliday 	BOOLEAN 	NOT NULL,  
--     Y  			SMALLINT	NOT NULL,  
--     FY 			SMALLINT,  
--     Q  			TINYINT,  
--     M  			TINYINT,  
--     D  			TINYINT,  
--     DW 			TINYINT, 
--     monthname 	VARCHAR(9), 
--     dayname   	VARCHAR(9), 
--     W         	TINYINT 
-- ) 

-- DATEDIFF('1800-01-01', '2037-12-31')

-- ADDDATE()(v4.1.1)		   Add dates
-- ADDTIME()(v4.1.1)		   Add time
-- CONVERT_TZ()(v4.1.3)		   Convert from one timezone to another
-- CURDATE()			   Return the current date
-- CURRENT_DATE(), CURRENT_DATE	   Synonyms for CURDATE()
-- CURRENT_TIME(), CURRENT_TIME	   Synonyms for CURTIME()
-- CURRENT_TIMESTAMP()		   Synonyms for NOW()
-- CURTIME()			   Return the current time
-- DATE_ADD()			   Add two dates
-- DATE_FORMAT()		   Format date as specified
-- DATE_SUB()			   Subtract two dates
-- DATE()(v4.1.1)		   Extract the date part of a date or datetime expression
-- DATEDIFF()(v4.1.1)		   Subtract two dates
-- DAY()(v4.1.1)		   Synonym for DAYOFMONTH()
-- DAYNAME()(v4.1.21)		   Return the name of the weekday
-- DAYOFMONTH()			   Return the day of the month (1-31)
-- DAYOFWEEK()			   Return the weekday index of the argument
-- DAYOFYEAR()			   Return the day of the year (1-366)
-- EXTRACT			   Extract part of a date
-- FROM_DAYS()			   Convert a day number to a date
-- FROM_UNIXTIME()		   Format date as a UNIX timestamp
-- GET_FORMAT()(v4.1.1)		   Return a date format string
-- HOUR()			   Extract the hour
-- LAST_DAY(v4.1.1)		   Return the last day of the month for the argument
-- LOCALTIME(), LOCALTIME	   Synonym for NOW()
-- LOCALTIMESTAMP, LOCALTIMESTAMP()(v4.0.6)		   Synonym for NOW()
-- MAKEDATE()(v4.1.1)		   Create a date from the year and day of year
-- MAKETIME(v4.1.1)		   MAKETIME()
-- MICROSECOND()(v4.1.1)	   Return the microseconds from argument
-- MINUTE()			   Return the minute from the argument
-- MONTH()			   Return the month from the date passed
-- MONTHNAME()(v4.1.21)		   Return the name of the month
-- NOW()			   Return the current date and time
-- PERIOD_ADD()			   Add a period to a year-month
-- PERIOD_DIFF()		   Return the number of months between periods
-- QUARTER()			   Return the quarter from a date argument
-- SEC_TO_TIME()		   Converts seconds to 'HH:MM:SS' format
-- SECOND()			   Return the second (0-59)
-- STR_TO_DATE()(v4.1.1)	   Convert a string to a date
-- SUBDATE()			   When invoked with three arguments a synonym for DATE_SUB()
-- SUBTIME()(v4.1.1)		   Subtract times
-- SYSDATE()			   Return the time at which the function executes
-- TIME_FORMAT()		   Format as time
-- TIME_TO_SEC()		   Return the argument converted to seconds
-- TIME()(v4.1.1)		   Extract the time portion of the expression passed
-- TIMEDIFF()(v4.1.1)		   Subtract time
-- TIMESTAMP()(v4.1.1)		   With a single argument, this function returns the date or datetime expression. With two arguments, the sum of the arguments
-- TIMESTAMPADD()(v5.0.0)	   Add an interval to a datetime expression
-- TIMESTAMPDIFF()(v5.0.0)	   Subtract an interval from a datetime expression
-- TO_DAYS()			   Return the date argument converted to days

-- UNIX_TIMESTAMP()		   Return a UNIX timestamp
-- UTC_DATE()(v4.1.1)		   Return the current UTC date
-- UTC_TIME()(v4.1.1)		   Return the current UTC time
-- UTC_TIMESTAMP()(v4.1.1)	   Return the current UTC date and time

-- WEEK()			   Return the week number
-- WEEKDAY()			   Return the weekday index
-- WEEKOFYEAR()(v4.1.1)		   Return the calendar week of the date (1-53)
-- YEAR()			   Return the year
-- YEARWEEK()			   Return the year and week
