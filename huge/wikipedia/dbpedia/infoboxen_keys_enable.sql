use `infochimps_data`;


-- ===========================================================================
--
-- Index tables
--
-- ===========================================================================

-- Expect this to take, on a fast machine, about 
--   


ALTER    TABLE `joins` 		ENABLE  KEYS; 
ALTER    TABLE `vals` 		ENABLE  KEYS; 
ALTER    TABLE `names` 		ENABLE  KEYS; 
ALTER    TABLE `props` 		ENABLE  KEYS; 
ALTER    TABLE `sub_tpls`	ENABLE  KEYS; 
ALTER    TABLE `types` 		ENABLE  KEYS; 

