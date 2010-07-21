-- params
%default OUTPUT_PATH   '${OUTPUT_DIR}/tweets'
%default BEGIN         20060101000000 -- Jan 1st, 2006
%default END           30000101000000 -- In the year 3000...	

-- load	
%default TWEET         '/data/sn/tw/fixd/objects/tweet'	
tweet         = LOAD '$TWEET'         AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);

-- group 
handle_and_hour           = FOREACH tweet GENERATE sn, crat / 10000 AS hour;
matching_handle_and_hour  = FILTER handle_and_hour BY sn == '$HANDLE', crat >= $BEGIN, crat < END;
grouped_hourly            = GROUP matching_handle_and_hour BY hour;
hourly_count              = FOREACH grouped_hourly GENERATE group AS hour, COUNT(matching_handle_and_hour) AS num;
	
rmf OUTPUT_PATH
STORE hourly_count INTO '$OUTPUT_PATH';
