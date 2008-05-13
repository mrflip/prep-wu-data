-- Table of positive integers from 0 to 2^16-1 :
-- You could whip this up in a command line, like
--   perl -e 'for $i (0..(1<<16)-1) { printf "%-6d\n",$i }' | more
-- but here's a pure MySQL version

-- Run with 
-- time mysql -E -h localhost -u vizsagedb -p < AuxTable-Integers.sql

-- You should get the following output:
--             MIN(i): 1
--             MAX(i): 65536
--  COUNT(DISTINCT i): 65536
--           COUNT(i): 65536
--            MIN(i0): 0
--            MAX(i0): 65535
-- COUNT(DISTINCT i0): 65536
--          COUNT(i0): 65536
--          POW(2,16): 65536
--
-- If you need more do something like: 
-- (SELECT i FROM Integers WHERE i < 50000 UNION SELECT 50000+i0 FROM Integers WHERE i0 < 50000 )

-- Replace this with your database's name.
use vizsagedb_aux;

-- Make a View with numbers from 0 to 10
DROP VIEW IF EXISTS `Digits` ;
CREATE VIEW Digits AS SELECT 0 'Digit' 
  UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 
  UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 
  UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ;
SELECT * FROM `Digits`;

-- SET UP Auxiliary table (auxSequence) of numbers 0-65535 (2^16 in all)
DROP TABLE IF EXISTS Integers 
;
CREATE TABLE Integers (
  `i` 		  INT UNSIGNED	NOT NULL,  -- count from 1: good for row-based indexing
  `i0` 		  INT UNSIGNED	NOT NULL,  -- count from 0
  PRIMARY KEY       (`i`),
  INDEX        `i0` (`i0`)
) CHARACTER SET utf8 PACK_KEYS = 0 ROW_FORMAT = FIXED
  COMMENT = 'Integers from 0 to 2^16-1'
;

INSERT INTO Integers
SELECT i0+1 AS i, i0 FROM (
SELECT (d4.Digit*10000 + d3.Digit*1000 + d2.Digit*100 + d1.Digit*10 + d0.Digit) AS i0
  FROM   	 Digits d0
  CROSS JOIN Digits d1
  CROSS JOIN Digits d2
  CROSS JOIN Digits d3
  CROSS JOIN Digits d4
  WHERE ((d4.Digit*10000 + d3.Digit*1000 + d2.Digit*100 + d1.Digit*10 + d0.Digit) <= POW(2,16)-1)
) zerobased;
SELECT MIN(i), MAX(i), COUNT(DISTINCT i), COUNT(i),
	MIN(i0), MAX(i0), COUNT(DISTINCT i0), COUNT(i0), POW(2,16)
  FROM	Integers
;



