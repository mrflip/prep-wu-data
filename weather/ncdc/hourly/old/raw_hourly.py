#!/usr/local/bin/python

import  csv
from    vzgutil.NamedTuple          import  NamedTuple
from    vzgutil.RawFixUtil          import  fixForSQL
from    posix                       import  listdir

#**********************************************************************
# 
# Hourly Weather data
#
#**********************************************************************

rawHourly  = NamedTuple('rawHourly', """
    name                    
    id_USAF                 id_NCDC                 date                    hrmn                    
    type_source             type_report             
    wind_dir                wind_dir_q              wind_obs                
    wind_speed              wind_speed_q            
    cloud_ceil_height       cloud_ceil_height_q     cloud_ceil_method       cloud_ceil_CAVOK        
    vis_dist                vis_dist_q              vis_variable_flag       vis_variable_flag_q             
    temp                    temp_q                  temp_dewpt              temp_dewpt_q            
    press_sealvl            press_sealvl_q          
    precip_lq1_period       precip_lq1_depth        precip_lq1_trace_fl     precip_lq1_q            
    precip_lq2_period       precip_lq2_depth        precip_lq2_trace_fl     precip_lq2_q            
    precip_lq3_period       precip_lq3_depth        precip_lq3_trace_fl     precip_lq3_q            
    precip_lq4_period       precip_lq4_depth        precip_lq4_trace_fl     precip_lq4_q            
    precip_hist_dur         precip_hist_contin      precip_hist_q           
    snow_depth              snow_depth_cond         snow_depth_q            
    snow_depth_weq          snow_depth_weq_tr       snow_depth_weq_q        
    precip_sn1_period       precip_sn1_depth        precip_sn1_cond         precip_sn1_depth_q      
    precip_sn2_period       precip_sn2_depth        precip_sn2_cond         precip_sn2_depth_q      
    precip_sn3_period       precip_sn3_depth        precip_sn3_cond         precip_sn3_depth_q      
    precip_sn4_period       precip_sn4_depth        precip_sn4_cond         precip_sn4_depth_q      
    wea_pr_a_obs            wea_pr_a_obs_q          
    wea_pa_m_obs_1          wea_pa_m_obs_1_q        wea_pa_m_obs_1_time     wea_pa_m_obs_1_time_q   
    wea_pa_m_obs_2          wea_pa_m_obs_2_q        wea_pa_m_obs_2_time     wea_pa_m_obs_2_time_q   
    wea_pa_a_obs_1          wea_pa_a_obs_1_q        wea_pa_a_obs_1_time     wea_pa_a_obs_1_time_q   
    wea_pa_a_obs_2          wea_pa_a_obs_2_q        wea_pa_a_obs_2_time     wea_pa_a_obs_2_time_q   
    vis_runway_dir          vis_runway_lrc          vis_runway_dist         vis_runway_dist_q       
    cloud_cover_total       cloud_cover_opaque      cloud_cover_total_q     
    cloud_cover_low         cloud_cover_low_q       
    cloud_low_type          cloud_low_type_q        cloud_low_height        cloud_low_height_q      
    cloud_mid_type          cloud_mid_type_q        cloud_hi_type           cloud_hi_type_q         
    sunshine_time           sunshine_time_q         
    groundcond              groundcond_q            
    temp_minmax1_period     temp_minmax1_minmax     temp_minmax1_temp       temp_minmax1_q          
    temp_minmax2_period     temp_minmax2_minmax     temp_minmax2_temp       temp_minmax2_q          
    press_altim             press_altim_q           press_atmos             press_atmos_q           
    press_chg_3hr_obs       press_chg_3hr_obs_q     press_chg_3hr_del       press_chg_3hr_del_q 
    press_chg_24hr_del      press_chg_24hr_del_q    
    wea_pr_v_obs_1          wea_pr_v_obs_1_q        wea_pr_v_obs_2          wea_pr_v_obs_2_q        
    wea_pr_v_obs_3          wea_pr_v_obs_3_q        wea_pr_v_obs_4          wea_pr_v_obs_4_q        
    wea_pr_v_obs_5          wea_pr_v_obs_5_q        wea_pr_v_obs_6          wea_pr_v_obs_6_q        
    wea_pr_v_obs_7          wea_pr_v_obs_7_q        
    wea_pr_m_obs_1          wea_pr_m_obs_1_q        wea_pr_m_obs_2          wea_pr_m_obs_2_q        
    wea_pr_m_obs_3          wea_pr_m_obs_3_q        wea_pr_m_obs_4          wea_pr_m_obs_4_q        
    wea_pr_m_obs_5          wea_pr_m_obs_5_q        wea_pr_m_obs_6          wea_pr_m_obs_6_q        
    wea_pr_m_obs_7          wea_pr_m_obs_7_q        
    wind_supp1_obs          wind_supp1_period       wind_supp1_speed        wind_supp1_speed_q      
    wind_supp2_obs          wind_supp2_period       wind_supp2_speed        wind_supp2_speed_q      
    wind_supp3_obs          wind_supp3_period       wind_supp3_speed        wind_supp3_speed_q      
    wind_gust_speed         wind_gust_speed_q       tagged_additional_observations
    """)
    
rawHourly_NULLS =   (
    '',                     '',             '',             
    '99999999',             '9999',                 
    '9',                    '99999',                
    '999',                  '9',                    '9',                    
    '999.9',                '9',                        
    '99999',                '9',                    '9',                    '9',                        
    '999999',               '9',                    '9',                    '9',                        
    '999.9',                '9',                    '999.9',                '9',                        
    '9999.9',               
    '9',                    
    '99',                   '999.9',                '9',                    '9',                    
    '99',                   '999.9',                '9',                    '9',                    
    '99',                   '999.9',                '9',                    '9',
    '99',                   '999.9',                '9',                    '9',                    
    '9',                    '9',                    '9',                    
    '9999',                 '9',                    '9',                        
    '99999.9',              '9',                    '9',                    
    '99',                   '999',                  '9',                    '9',                    
    '99',                   '999',                  '9',                    '9',                    
    '99',                   '999',                  '9',                    '9',                    
    '99',                   '999',                  '9',                    '9',        
    '',                     '9',                    
    '',                     '9',                    '99',                   '9',                    
    '',                     '9',                    '99',                   '9',                    
    '',                     '9',                    '99',                   '9',                    
    '',                     '9',                    '99',                   '9',
    '99',                   '9',                    '9999',                 '9',                    
    '99',                   '99',                   '9',                            
    '99',                   '9',                    
    '99',                   '9',                    '99999',                '9',                    
    '99',                   '9',                    '99',                   '9',                    
    '9999',                 '9',                        
    '99',                   '9',                    
    '99.9',                 '9',                    '999.9',                '9',                    
    '99.9',                 '9',                    '999.9',                '9',                    
    '9999.9',               '9',                    '9999.9',               '9',                
    '9',                    '9',                    '99.9',                 '9',                    
    '99.9',                 '9',
    '99',                   '9',                    '99',                   '9',                        
    '99',                   '9',                    '99',                   '9',                        
    '99',                   '9',                    '99',                   '9',
    '99',                   '9',                                            
    '',                     '9',                    '',                     '9',                        
    '',                     '9',                    '',                     '9',                        
    '',                     '9',                    '',                     '9',
    '',                     '9',
    '9',                    '99',                   '999.9',                '9',                        
    '9',                    '99',                   '999.9',                '9',                        
    '9',                    '99',                   '999.9',                '9',                        
    '999.9',                '9',                    ''
    )


#**********************************************************************
# 
# Read a CSV File into a named tuple
#
#**********************************************************************
def snarf_raw(filename, tupleFactory, nullvals, skiphead = 0):
    """Read CSV file into corresponding tuple structure"""
    records = []
    csvFile  = open(filename, "rb")
    # discared skiphead lines of header junk
    for i in range(0,skiphead): csvFile.readline()
    # Read the rest as a CSV
    csvLines = csv.reader(csvFile)
    for line in csvLines:
        line = rawFixNulls(line, nullvals)
        if (len(line) != len(tupleFactory.__fields__)):
            raise Exception("Shoot! Only got "+str(len(line))+" fields in record \n\t" + \
                str(line) + "\nbut "+str(len(tupleFactory.__fields__))+" were desired")
        records.append(tupleFactory(*line))
    return records


#**********************************************************************
# 
# Fix Null records
#
#**********************************************************************
def rawFixNulls(record, nullvals):
    # Signed entries may have a spurious ' ' in front
    return [ None if (val.lstrip() == nullvall or val.lstrip() == '') 
             else val.lstrip()
             for (val, nullvall) in zip(record, nullvals) ]


#**********************************************************************
# 
# Dump as separate files. 
#
#**********************************************************************

weatherComponents = ('Air', 'Precipitation', 'Cloud', 'Observation', 
    # 'StationName', 'StationHistory', 'ReadingQuality'
    )

weatherComponentFields = {
    'Air': (
        'temp',                 'temp_dewpt',       
        'press_sealvl',         'press_atmos',          'press_altim',          
        'press_chg_3hr_del',    'press_chg_3hr_obs',    'press_chg_24hr_del',       
        'wind_dir',             'wind_obs',             
        'wind_speed',           'wind_gust_speed',          
        'temp_minmax1_minmax',  'temp_minmax1_period',  'temp_minmax1_temp',    
        'temp_minmax2_minmax',  'temp_minmax2_period',  'temp_minmax2_temp',    
        'wind_supp1_obs',       'wind_supp1_period',    'wind_supp1_speed', 
        'wind_supp2_obs',       'wind_supp2_period',    'wind_supp2_speed', 
        'wind_supp3_obs',       'wind_supp3_period',    'wind_supp3_speed', 
        ),
    'Precipitation': (
        'groundcond',                   
        'precip_hist_dur',      'precip_hist_contin',   
        'snow_depth',           'snow_depth_weq',   
        'precip_lq1_depth',     'precip_lq1_period',    'precip_lq2_depth',     'precip_lq2_period',    
        'precip_lq3_depth',     'precip_lq3_period',    'precip_lq4_depth',     'precip_lq4_period',    
        'precip_sn1_depth',     'precip_sn1_period',    'precip_sn2_depth',     'precip_sn2_period',    
        'precip_sn3_depth',     'precip_sn3_period',    'precip_sn4_depth',     'precip_sn4_period',    
        ),
    'Cloud': (
        'cloud_ceil_height',    'cloud_low_height',         
        'cloud_cover_total',    'cloud_cover_low',      'cloud_cover_opaque',   
        'cloud_low_type',       'cloud_mid_type',       'cloud_hi_type',        
        'vis_dist',             'vis_variable_flag',                
        'vis_runway_dist',      'vis_runway_dir',       'vis_runway_lrc',       
        'sunshine_time',        
        ),
    'Observation': (
        'wea_pr_a_obs',         'wea_pr_m_obs_1',       'wea_pr_m_obs_2',       'wea_pr_m_obs_3',       
        'wea_pr_m_obs_4',       'wea_pr_m_obs_5',       'wea_pr_m_obs_6',       'wea_pr_m_obs_7',       
        'wea_pr_v_obs_1',       'wea_pr_v_obs_2',       'wea_pr_v_obs_3',       'wea_pr_v_obs_4',       
        'wea_pr_v_obs_5',       'wea_pr_v_obs_6',       'wea_pr_v_obs_7',       
        'wea_pa_a_obs_1',       'wea_pa_a_obs_1_time',  'wea_pa_a_obs_2',       'wea_pa_a_obs_2_time',  
        'wea_pa_m_obs_1',       'wea_pa_m_obs_1_time',  'wea_pa_m_obs_2',       'wea_pa_m_obs_2_time',  
        ),
    'ReadingQuality': (
        'type_source',          'type_report',          
        'wind_dir_q',           'wind_speed_q',         'cloud_ceil_height_q',  
        'cloud_ceil_CAVOK',     'cloud_ceil_method',    'vis_dist_q',           'vis_variable_flag_q',          
        'temp_q',               'temp_dewpt_q',         'press_sealvl_q',       
        'precip_lq1_q',         'precip_lq2_q',         'precip_lq3_q',         'precip_lq4_q',     
        'precip_hist_q',        'snow_depth_q',         'snow_depth_weq_q', 
        'precip_sn1_depth_q',   'precip_sn2_depth_q',   'precip_sn3_depth_q',   'precip_sn4_depth_q',   
        'wea_pr_a_obs_q',       'wea_pa_m_obs_1_q',     'wea_pa_m_obs_1_time_q','wea_pa_m_obs_2_q',     
        'wea_pa_m_obs_2_time_q','wea_pa_a_obs_1_q',     'wea_pa_a_obs_1_time_q',
        'wea_pa_a_obs_2_q',     'wea_pa_a_obs_2_time_q','vis_runway_dist_q',    
        'cloud_cover_total_q',  'cloud_cover_low_q',    'cloud_low_type_q',     'cloud_low_height_q',   
        'cloud_mid_type_q',     'cloud_hi_type_q',      'sunshine_time_q',      'groundcond_q',     
        'temp_minmax1_q',       'temp_minmax2_q',       'press_altim_q',        'press_atmos_q',        
        'press_chg_3hr_obs_q',  'press_chg_3hr_del_q',  'press_chg_24hr_del_q',
        'wea_pr_v_obs_1_q',     'wea_pr_v_obs_2_q',     'wea_pr_v_obs_3_q',     'wea_pr_v_obs_4_q', 
        'wea_pr_v_obs_5_q',     'wea_pr_v_obs_6_q',     'wea_pr_v_obs_7_q', 
        'wea_pr_m_obs_1_q',     'wea_pr_m_obs_2_q',     'wea_pr_m_obs_3_q',     'wea_pr_m_obs_4_q', 
        'wea_pr_m_obs_5_q',     'wea_pr_m_obs_6_q',     'wea_pr_m_obs_7_q', 
        'wind_supp1_speed_q',   'wind_supp2_speed_q',   'wind_supp3_speed_q',   'wind_gust_speed_q',    
        'precip_lq1_trace_fl',  'precip_lq2_trace_fl',  'precip_lq3_trace_fl',  'precip_lq4_trace_fl',  
        'precip_sn1_cond',      'precip_sn2_cond',      'precip_sn3_cond',      'precip_sn4_cond',      
        'snow_depth_cond',      'snow_depth_weq_tr',    
        ),
    }

def getSQLCSVWriters(dirname, filebase):
    writers = {}
    for component in weatherComponents:
        filename = dirname+'/'+filebase+'-'+component+'.csv'
        writers[component] = csv.writer(open(filename, "wb"))
    return writers

def dumpSQLCSVFiles(writers, records):
    for record in records:
        # fix datetime "%Y-%m-%d %H:%M:00"
        datetime = record.date[0:4]+'-'+record.date[4:6]+'-'+record.date[6:8]+' '+ \
            record.hrmn[0:2]+':'+record.hrmn[2:4]+':00' 
        # FIXME -- unmunge the temp_minmax readings
        # FIXME --  vis_variable_flag           precip_hist_contin
        #           temp_minmax[12]_minmax      cloud_ceil_CAVOK    precip_lq[1234]_trace_fl
        # dump each record subset in the appropriate file.
        key = (record.id_NCDC, record.id_USAF, datetime)
        for component in weatherComponents:
            vals = tuple( fixForSQL(getattr(record, field)) for field in weatherComponentFields[component] )
            writers[component].writerow(key + vals)
        
        # FIXME -- Switch order of minimax_temp fields
    
        
#**********************************************************************
# 
# Read Hourly Weather data 
#
#**********************************************************************

def main():
    """Pull in an hourly weather file, 
    rectify and normalize its structure, and
    dump as a SQL LOAD FILE.
    """
    # Files to read in
    indirname     = '/work/DataSources/Data_Weather/data/hourly'
    infilenames   = (indirname+'/'+filename for filename in listdir(indirname)) 
    # infilenames    = ('/Users/flip/now/vizsage/apps/Rainmaker/sample-hourly.txt',)
    # Files to dump out 
    outdirname    = '/work/DataSources/Data_Weather/sqlcsv'
    outfilebase   = 'Weather-Hourly' 
    sqlcsvWriters = getSQLCSVWriters(outdirname, outfilebase)
    # Process
    for filename in infilenames:
        print filename;
        rawWeatherH     = snarf_raw(filename, rawHourly, rawHourly_NULLS, 2)
        dumpSQLCSVFiles(sqlcsvWriters, rawWeatherH)
main()



#       synopsis= ('date', 'hrmn', 
#                   'wind_dir', 'wind_speed',   
#                   'vis_dist', 'temp', 'press_sealvl', 'precip_lq1_period', 
#                   'cloud_cover_total', 'cloud_cover_opaque', 'sunshine_time', 'groundcond', 
#                   'wea_pr_m_obs_1', 'wea_pr_m_obs_2',)
#       for raw in rawWeatherH:
#           #print ''.join([ s + ':' + str(getattr(raw, s)) + '  ' for s in raw.__fields__])
#           print ','.join([ str(getattr(raw, s)) for s in raw.__fields__])
