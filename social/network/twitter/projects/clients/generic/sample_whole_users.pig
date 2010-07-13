%default WHOLE  '/data/sn/tw/client/generic/whole_users'
%default SMPLD '/data/sn/tw/client/generic/sampled_whole_users'

user    = LOAD '$WHOLE' AS (uid:long, sn:chararray, crat:long, name:chararray, descr:chararray, url:chararray, loc:chararray, zone:chararray, utc:chararray, followers:int, friends:int, statuses:int, favs:int, bg_col:chararray, txt_col:chararray, sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray, bg_img_url:chararray, img_url:chararray, prot:int);
sampled = SAMPLE user 0.0001; --get 0.01 percent of users ~4k

rmf $SMPLD;
STORE sampled INTO '$SMPLD';
