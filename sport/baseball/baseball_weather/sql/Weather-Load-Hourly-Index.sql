 -- Name of database
use vizsagedb_weather; 

-- =========================================================================
--
--	Impose Indices
--
-- =========================================================================

ALTER TABLE HourlyAir \
	ADD INDEX				(temp)
 ,	ADD INDEX				(temp_dewpt)
 ,	ADD INDEX				(press_sealvl)
 ,	ADD INDEX				(press_atmos)
 ,	ADD INDEX				(press_altim)
 ,	ADD INDEX				(wind_dir)
 ,	ADD INDEX				(wind_obs)
 ,	ADD INDEX				(wind_speed)
 ,	ADD INDEX				(wind_gust_speed)
 ;
 SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


ALTER TABLE HourlyPrecipitation \
	ADD INDEX				(groundcond)
 ,	ADD INDEX				(precip_hist_dur)
 ,	ADD INDEX				(snow_depth)
 ,	ADD INDEX				(snow_depth_weq)
 ,	ADD INDEX				(precip_lq1_depth)
 ,	ADD INDEX				(precip_lq1_period)
 ,	ADD INDEX				(precip_sn1_depth)
 ,	ADD INDEX				(precip_sn1_period)
 ;
 SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


ALTER TABLE HourlyCloud \
	ADD INDEX				(cloud_ceil_height)
 ,	ADD INDEX				(cloud_low_height)
 ,	ADD INDEX				(cloud_cover_total)
 ,	ADD INDEX				(cloud_cover_low)
 ,	ADD INDEX				(cloud_cover_opaque)
 ,	ADD INDEX				(cloud_low_type)
 ,	ADD INDEX				(cloud_mid_type)
 ,	ADD INDEX				(cloud_hi_type)
 ,	ADD INDEX				(vis_dist)
 ,	ADD INDEX				(sunshine_time)
 ;
 SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


ALTER TABLE HourlyCloud \
	ADD INDEX				(cloud_ceil_height)
 ,	ADD INDEX				(cloud_low_height)
 ,	ADD INDEX				(cloud_cover_total)
 ,	ADD INDEX				(cloud_cover_low)
 ,	ADD INDEX				(cloud_cover_opaque)
 ,	ADD INDEX				(cloud_low_type)
 ,	ADD INDEX				(cloud_mid_type)
 ,	ADD INDEX				(cloud_hi_type)
 ,	ADD INDEX				(vis_dist)
 ,	ADD INDEX				(sunshine_time)
 ;
 SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

ALTER TABLE HourlyObservation \
 ,	ADD INDEX				(wea_pr_a_obs)
 ,	ADD INDEX				(wea_pr_m_obs_1)
 ,	ADD INDEX				(wea_pr_m_obs_2)
 ,	ADD INDEX				(wea_pr_m_obs_3)
 ,	ADD INDEX				(wea_pr_m_obs_4)
 ,	ADD INDEX				(wea_pr_m_obs_5)
 ,	ADD INDEX				(wea_pr_m_obs_6)
 ,	ADD INDEX				(wea_pr_m_obs_7)
 ,	ADD INDEX				(wea_pr_v_obs_1)
 ,	ADD INDEX				(wea_pr_v_obs_2)
 ,	ADD INDEX				(wea_pr_v_obs_3)
 ,	ADD INDEX				(wea_pr_v_obs_4)
 ,	ADD INDEX				(wea_pr_v_obs_5)
 ,	ADD INDEX				(wea_pr_v_obs_6)
 ,	ADD INDEX				(wea_pr_v_obs_7)
 ,	ADD INDEX				(wea_pa_a_obs_1)
 ,	ADD INDEX				(wea_pa_a_obs_1_time)
 ,	ADD INDEX				(wea_pa_a_obs_2)
 ,	ADD INDEX				(wea_pa_a_obs_2_time)
 ,	ADD INDEX				(wea_pa_m_obs_1)
 ,	ADD INDEX				(wea_pa_m_obs_1_time)
 ,	ADD INDEX				(wea_pa_m_obs_2)
 ,	ADD INDEX				(wea_pa_m_obs_2_time)
 ;
 SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;
