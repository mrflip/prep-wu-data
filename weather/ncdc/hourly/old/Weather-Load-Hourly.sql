 -- Name of database
 use vizsagedb_weather; 

 -- =========================================================================
 --
 --	  Define GameEvents Table
 --
 -- =========================================================================

 -- TODO:
 -- Split off the mostly-invariant rows
 -- Find correlated rows and convert to 'NULL'?
 -- Build Fielder table
 -- Pivot res_batter_ID, res_batter_hand, res_pitcher_ID, rres_pitcher_hand, esp_rnr1_pitcher_ID, resp_rnr2_pitcher_ID, resp_rnr3_pitcher_ID

DROP TABLE IF EXISTS HourlyAir;
CREATE TABLE HourlyAir (
	ID_NCDC					INTEGER		UNSIGNED	NOT NULL																				
 ,	ID_USAF					INTEGER		UNSIGNED	NOT NULL	
 ,	datetime				DATETIME				NOT NULL
 ,	temp					DOUBLE							
 ,	temp_dewpt				DOUBLE									
 ,	press_sealvl			DOUBLE									
 ,	press_atmos				DOUBLE									
 ,	press_altim				DOUBLE									
 ,	press_chg_3hr_del		DOUBLE									
 ,	press_chg_3hr_obs		INTEGER		UNSIGNED					
 ,	press_chg_24hr_del		DOUBLE									
 ,	wind_dir				INTEGER		UNSIGNED					
 ,	wind_obs				CHAR(1)					
 ,	wind_speed				DOUBLE									
 ,	wind_gust_speed			DOUBLE									
 ,	temp_minmax1_minmax		CHAR(1)								-- BOOLEAN		
 ,	temp_minmax1_period		DOUBLE									
 ,	temp_minmax1_temp		DOUBLE									
 ,	temp_minmax2_minmax		CHAR(1)								-- BOOLEAN		
 ,	temp_minmax2_period		DOUBLE									
 ,	temp_minmax2_temp		DOUBLE								-- FIXME -- Switch order
 ,	wind_supp1_obs			INTEGER		UNSIGNED					
 ,	wind_supp1_period		INTEGER		UNSIGNED					
 ,	wind_supp1_speed		DOUBLE									
 ,	wind_supp2_obs			INTEGER		UNSIGNED					
 ,	wind_supp2_period		INTEGER		UNSIGNED					
 ,	wind_supp2_speed		DOUBLE									
 ,	wind_supp3_obs			INTEGER		UNSIGNED					
 ,	wind_supp3_period		INTEGER		UNSIGNED					
 ,	wind_supp3_speed		DOUBLE							
 , PRIMARY KEY	stndatetime	(ID_NCDC, ID_USAF, datetime)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

DROP TABLE IF EXISTS HourlyPrecipitation;
CREATE TABLE HourlyPrecipitation (
	ID_NCDC					INTEGER		UNSIGNED	NOT NULL																				
 ,	ID_USAF					INTEGER		UNSIGNED	NOT NULL	
 ,	datetime				DATETIME				NOT NULL
 ,	groundcond				INTEGER		UNSIGNED					
 ,	precip_hist_dur			INTEGER		UNSIGNED					
 ,	precip_hist_contin		CHAR(1)						-- BOOLEAN					
 ,	snow_depth				INTEGER		UNSIGNED					
 ,	snow_depth_weq			INTEGER		UNSIGNED					
 ,	precip_lq1_depth		DOUBLE									
 ,	precip_lq1_period		INTEGER		UNSIGNED					
 ,	precip_lq2_depth		DOUBLE									
 ,	precip_lq2_period		INTEGER		UNSIGNED					
 ,	precip_lq3_depth		DOUBLE									
 ,	precip_lq3_period		INTEGER		UNSIGNED					
 ,	precip_lq4_depth		DOUBLE									
 ,	precip_lq4_period		INTEGER		UNSIGNED					
 ,	precip_sn1_depth		DOUBLE									
 ,	precip_sn1_period		INTEGER		UNSIGNED					
 ,	precip_sn2_depth		DOUBLE									
 ,	precip_sn2_period		INTEGER		UNSIGNED					
 ,	precip_sn3_depth		DOUBLE									
 ,	precip_sn3_period		INTEGER		UNSIGNED					
 ,	precip_sn4_depth		DOUBLE									
 ,	precip_sn4_period		INTEGER		UNSIGNED			
 , PRIMARY KEY	stndatetime	(ID_NCDC, ID_USAF, datetime)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

DROP TABLE IF EXISTS HourlyCloud;
CREATE TABLE HourlyCloud (
	ID_NCDC					INTEGER		UNSIGNED	NOT NULL																				
 ,	ID_USAF					INTEGER		UNSIGNED	NOT NULL	
 ,	datetime				DATETIME				NOT NULL
 ,	cloud_ceil_height		INTEGER		UNSIGNED					
 ,	cloud_low_height		INTEGER		UNSIGNED					
 ,	cloud_cover_total		INTEGER		UNSIGNED					
 ,	cloud_cover_low			INTEGER		UNSIGNED					
 ,	cloud_cover_opaque		INTEGER		UNSIGNED					
 ,	cloud_low_type			INTEGER		UNSIGNED					
 ,	cloud_mid_type			INTEGER		UNSIGNED					
 ,	cloud_hi_type			INTEGER		UNSIGNED					
 ,	vis_dist				INTEGER		UNSIGNED					
 ,	vis_variable_flag		CHAR(1)						-- BOOLEAN		
 ,	vis_runway_dist			INTEGER		UNSIGNED					
 ,	vis_runway_dir			INTEGER		UNSIGNED					
 ,	vis_runway_lrc			CHAR(1)					
 ,	sunshine_time			INTEGER		UNSIGNED			
 , PRIMARY KEY	stndatetime	(ID_NCDC, ID_USAF, datetime)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

DROP TABLE IF EXISTS HourlyObservation;
CREATE TABLE HourlyObservation (
	ID_NCDC					INTEGER		UNSIGNED	NOT NULL																				
 ,	ID_USAF					INTEGER		UNSIGNED	NOT NULL	
 ,	datetime				DATETIME				NOT NULL
 ,	wea_pr_a_obs			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_1			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_2			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_3			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_4			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_5			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_6			INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_7			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_1			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_2			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_3			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_4			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_5			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_6			INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_7			INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_1			INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_1_time		INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_2			INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_2_time		INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_1			INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_1_time		INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_2			INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_2_time		INTEGER		UNSIGNED			
 , PRIMARY KEY	stndatetime	(ID_NCDC, ID_USAF, datetime)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

DROP TABLE IF EXISTS HourlyDataQuality;
CREATE TABLE HourlyDataQuality (
	ID_NCDC					INTEGER		UNSIGNED	NOT NULL																				
 ,	ID_USAF					INTEGER		UNSIGNED	NOT NULL	
 ,	datetime				DATETIME				NOT NULL
 ,	type_source				CHAR(1)									
 ,	type_report				CHAR(5)									
 ,	wind_dir_q				INTEGER		UNSIGNED					
 ,	wind_speed_q			INTEGER		UNSIGNED					
 ,	cloud_ceil_height_q		INTEGER		UNSIGNED					
 ,	cloud_ceil_CAVOK		CHAR(1)								-- BOOLEAN		
 ,	cloud_ceil_method		CHAR(1)					
 ,	vis_dist_q				INTEGER		UNSIGNED					
 ,	vis_variable_flag_q		INTEGER		UNSIGNED					
 ,	temp_q					INTEGER		UNSIGNED					
 ,	temp_dewpt_q			INTEGER		UNSIGNED					
 ,	press_sealvl_q			INTEGER		UNSIGNED					
 ,	precip_lq1_q			INTEGER		UNSIGNED					
 ,	precip_lq2_q			INTEGER		UNSIGNED					
 ,	precip_lq3_q			INTEGER		UNSIGNED					
 ,	precip_lq4_q			INTEGER		UNSIGNED					
 ,	precip_hist_q			INTEGER		UNSIGNED					
 ,	snow_depth_q			INTEGER		UNSIGNED					
 ,	snow_depth_weq_q		INTEGER		UNSIGNED					
 ,	precip_sn1_depth_q		INTEGER		UNSIGNED					
 ,	precip_sn2_depth_q		INTEGER		UNSIGNED					
 ,	precip_sn3_depth_q		INTEGER		UNSIGNED					
 ,	precip_sn4_depth_q		INTEGER		UNSIGNED					
 ,	wea_pr_a_obs_q			INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_1_q		INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_1_time_q	INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_2_q		INTEGER		UNSIGNED					
 ,	wea_pa_m_obs_2_time_q	INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_1_q		INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_1_time_q	INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_2_q		INTEGER		UNSIGNED					
 ,	wea_pa_a_obs_2_time_q	INTEGER		UNSIGNED					
 ,	vis_runway_dist_q		INTEGER		UNSIGNED					
 ,	cloud_cover_total_q		INTEGER		UNSIGNED					
 ,	cloud_cover_low_q		INTEGER		UNSIGNED					
 ,	cloud_low_type_q		INTEGER		UNSIGNED					
 ,	cloud_low_height_q		INTEGER		UNSIGNED					
 ,	cloud_mid_type_q		INTEGER		UNSIGNED					
 ,	cloud_hi_type_q			INTEGER		UNSIGNED					
 ,	sunshine_time_q			INTEGER		UNSIGNED					
 ,	groundcond_q			INTEGER		UNSIGNED					
 ,	temp_minmax1_q			INTEGER		UNSIGNED					
 ,	temp_minmax2_q			INTEGER		UNSIGNED					
 ,	press_altim_q			INTEGER		UNSIGNED					
 ,	press_atmos_q			INTEGER		UNSIGNED					
 ,	press_chg_3hr_obs_q		INTEGER		UNSIGNED					
 ,	press_chg_3hr_del_q		INTEGER		UNSIGNED					
 ,	press_chg_24hr_del_q	INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_1_q		INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_2_q		INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_3_q		INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_4_q		INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_5_q		INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_6_q		INTEGER		UNSIGNED					
 ,	wea_pr_v_obs_7_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_1_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_2_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_3_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_4_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_5_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_6_q		INTEGER		UNSIGNED					
 ,	wea_pr_m_obs_7_q		INTEGER		UNSIGNED					
 ,	wind_supp1_speed_q		INTEGER		UNSIGNED					
 ,	wind_supp2_speed_q		INTEGER		UNSIGNED					
 ,	wind_supp3_speed_q		INTEGER		UNSIGNED					
 ,	wind_gust_speed_q		INTEGER		UNSIGNED					
 ,	precip_lq1_trace_fl		INTEGER		UNSIGNED					
 ,	precip_lq2_trace_fl		INTEGER		UNSIGNED					
 ,	precip_lq3_trace_fl		INTEGER		UNSIGNED					
 ,	precip_lq4_trace_fl		INTEGER		UNSIGNED					
 ,	precip_sn1_cond			INTEGER		UNSIGNED					
 ,	precip_sn2_cond			INTEGER		UNSIGNED					
 ,	precip_sn3_cond			INTEGER		UNSIGNED					
 ,	precip_sn4_cond			INTEGER		UNSIGNED					
 ,	snow_depth_cond			INTEGER		UNSIGNED					
 ,	snow_depth_weq_tr		INTEGER		UNSIGNED			
 , PRIMARY KEY	stndatetime	(ID_NCDC, ID_USAF, datetime)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


-- =========================================================================
--
--	 Load Tables from disk
--
-- =========================================================================
--
TRUNCATE TABLE HourlyAir;
LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/Weather-Hourly-Air.csv' 			
		REPLACE INTO TABLE HourlyAir
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/Weather-Hourly-Precipitation.csv' 	
		REPLACE INTO TABLE HourlyPrecipitation
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/Weather-Hourly-Cloud.csv' 	
		REPLACE INTO TABLE HourlyCloud
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/Weather-Hourly-Observation.csv' 	
		REPLACE INTO TABLE HourlyObservation
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

--LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/Weather-Hourly-DataQuality.csv' 	
--		REPLACE INTO TABLE HourlyDataQuality
--		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\n';

