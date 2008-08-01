#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow/scaffold'
require 'imw/extract'
# require 'fileutils'; include FileUtils::Verbose
require 'YAML'
include IMW
require 'zlib'

file = Zlib::GzipReader.new(File.open(file_name))

#
# Define the input file structure
#
FILES = {
  :ncdc_weather_stations => {
    :cartoon =>
    %q{
         i4  .i2.i2.i2i6    i6    i6    i6    i6    i6    i6    i6    
         1902 12 27 20  -117 -9999  9671   320    21     8 -9999 -9999
    },
    :skip_head => 17,
    :fields => %w[
	name					
	id_USAF				id_NCDC				date				hrmn					
	type_source			type_report				
	wind_dir			wind_dir_q			wind_obs				
	wind_speed			wind_speed_q			
	cloud_ceil_height		cloud_ceil_height_q		cloud_ceil_method		cloud_ceil_CAVOK		
	vis_dist			vis_dist_q			vis_variable_flag		vis_variable_flag_q				
	temp				temp_q				temp_dewpt			temp_dewpt_q			
	press_sealvl			press_sealvl_q			
	precip_lq1_period		precip_lq1_depth		precip_lq1_trace_fl		precip_lq1_q			
	precip_lq2_period		precip_lq2_depth		precip_lq2_trace_fl		precip_lq2_q			
	precip_lq3_period		precip_lq3_depth		precip_lq3_trace_fl		precip_lq3_q			
	precip_lq4_period		precip_lq4_depth		precip_lq4_trace_fl		precip_lq4_q			
	precip_hist_dur			precip_hist_contin		precip_hist_q			
	snow_depth			snow_depth_cond			snow_depth_q			
	snow_depth_weq			snow_depth_weq_tr		snow_depth_weq_q		
	precip_sn1_period		precip_sn1_depth		precip_sn1_cond			precip_sn1_depth_q		
	precip_sn2_period		precip_sn2_depth		precip_sn2_cond			precip_sn2_depth_q		
	precip_sn3_period		precip_sn3_depth		precip_sn3_cond			precip_sn3_depth_q		
	precip_sn4_period		precip_sn4_depth		precip_sn4_cond			precip_sn4_depth_q		
	wea_pr_a_obs			wea_pr_a_obs_q			
	wea_pa_m_obs_1			wea_pa_m_obs_1_q		wea_pa_m_obs_1_time		wea_pa_m_obs_1_time_q	
	wea_pa_m_obs_2			wea_pa_m_obs_2_q		wea_pa_m_obs_2_time		wea_pa_m_obs_2_time_q	
	wea_pa_a_obs_1			wea_pa_a_obs_1_q		wea_pa_a_obs_1_time		wea_pa_a_obs_1_time_q	
	wea_pa_a_obs_2			wea_pa_a_obs_2_q		wea_pa_a_obs_2_time		wea_pa_a_obs_2_time_q	
	vis_runway_dir			vis_runway_lrc			vis_runway_dist			vis_runway_dist_q		
	cloud_cover_total		cloud_cover_opaque		cloud_cover_total_q		
	cloud_cover_low			cloud_cover_low_q		
	cloud_low_type			cloud_low_type_q		cloud_low_height		cloud_low_height_q		
	cloud_mid_type			cloud_mid_type_q		cloud_hi_type			cloud_hi_type_q			
	sunshine_time			sunshine_time_q			
	groundcond			groundcond_q			
	temp_minmax1_period		temp_minmax1_minmax		temp_minmax1_temp		temp_minmax1_q			
	temp_minmax2_period		temp_minmax2_minmax		temp_minmax2_temp		temp_minmax2_q			
	press_altim			press_altim_q			press_atmos			press_atmos_q			
	press_chg_3hr_obs		press_chg_3hr_obs_q		press_chg_3hr_del		press_chg_3hr_del_q	
	press_chg_24hr_del		press_chg_24hr_del_q	
	wea_pr_v_obs_1			wea_pr_v_obs_1_q		wea_pr_v_obs_2			wea_pr_v_obs_2_q		
	wea_pr_v_obs_3			wea_pr_v_obs_3_q		wea_pr_v_obs_4			wea_pr_v_obs_4_q		
	wea_pr_v_obs_5			wea_pr_v_obs_5_q		wea_pr_v_obs_6			wea_pr_v_obs_6_q		
	wea_pr_v_obs_7			wea_pr_v_obs_7_q		
	wea_pr_m_obs_1			wea_pr_m_obs_1_q		wea_pr_m_obs_2			wea_pr_m_obs_2_q		
	wea_pr_m_obs_3			wea_pr_m_obs_3_q		wea_pr_m_obs_4			wea_pr_m_obs_4_q		
	wea_pr_m_obs_5			wea_pr_m_obs_5_q		wea_pr_m_obs_6			wea_pr_m_obs_6_q		
	wea_pr_m_obs_7			wea_pr_m_obs_7_q		
	wind_supp1_obs			wind_supp1_period		wind_supp1_speed		wind_supp1_speed_q		
	wind_supp2_obs			wind_supp2_period		wind_supp2_speed		wind_supp2_speed_q		
	wind_supp3_obs			wind_supp3_period		wind_supp3_speed		wind_supp3_speed_q		
	wind_gust_speed			wind_gust_speed_q		tagged_additional_observations
    ],

    :null_placeholders => %w[
	'',				'',				'',				
	'99999999',			'9999',					
	'9',				'99999',				
	'999',				'9',				'9',					
	'999.9',			'9',					
	'99999',			'9',				'9',				'9',						
	'999999',			'9',				'9',				'9',						
	'999.9',			'9',				'999.9',			'9',						
	'9999.9',			
	'9',				
	'99',				'999.9',			'9',				'9',					
	'99',				'999.9',			'9',				'9',					
	'99',				'999.9',			'9',				'9',
	'99',				'999.9',			'9',				'9',					
	'9',				'9',				'9',				
	'9999',				'9',				'9',					
	'99999.9',			'9',				'9',				
	'99',				'999',				'9',				'9',					
	'99',				'999',				'9',				'9',					
	'99',				'999',				'9',				'9',					
	'99',				'999',				'9',				'9',		
	'',				'9',				
	'',				'9',				'99',				'9',					
	'',				'9',				'99',				'9',					
	'',				'9',				'99',				'9',					
	'',				'9',				'99',				'9',
	'99',				'9',				'9999',				'9',					
	'99',				'99',				'9',						
	'99',				'9',				
	'99',				'9',				'99999',			'9',					
	'99',				'9',				'99',				'9',					
	'9999',				'9',					
	'99',				'9',				
	'99.9',				'9',				'999.9',			'9',					
	'99.9',				'9',				'999.9',			'9',					
	'9999.9',			'9',				'9999.9',			'9',				
	'9',				'9',				'99.9',				'9',					
	'99.9',				'9',
	'99',				'9',				'99',				'9',						
	'99',				'9',				'99',				'9',						
	'99',				'9',				'99',				'9',
	'99',				'9',									
	'',				'9',				'',				'9',						
	'',				'9',				'',				'9',						
	'',				'9',				'',				'9',
	'',				'9',
	'9',				'99',				'999.9',			'9',						
	'9',				'99',				'999.9',			'9',						
	'9',				'99',				'999.9',			'9',						
	'999.9',			'9',				'',
 ]
  }
}
FILES[:ncdc_weather_stations_test] =
  FILES[:ncdc_weather_stations].merge({:filepath => [:temp, 'noaa/ish-history-short.txt']})

	

# 
# class ProcessWeatherStations
#   #
#   # set up the workflow paths
#   #
#   def config
#     # workflow paths
#     add_path :ripd_root, [:data_root, 'working/ripd']
#     scaffold_dataset 'weather/ncdc/stations'
#     scaffold_rip_dir 'ftp.ncdc.noaa.gov/pub/data'
#   end
# 
#   #
#   # process the files
#   #
#   def parse file_cfg, outp_file
#     stns = WeatherStationFile.new file_cfg
#     stns.skip_lines file_cfg[:skip_head]
#     File.open(path_to(outp_file), "w") do |f|
#       YAML.dump(stns.records, f)
#     end
# 
#   end
# end
# 
# processor = ProcessWeatherStations.new
# processor.config
# # file = :ncdc_weather_stations_test
# file = :ncdc_weather_stations
# processor.parse FILES[file], [:fixd, file.to_s+'.yaml']
