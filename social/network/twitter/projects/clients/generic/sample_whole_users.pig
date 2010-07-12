%default WHOLE  '/data/sn/tw/client/whole_users'
%default SMPLD '/data/sn/tw/client/generic/sampled_whole_users'

                         user_profile::uid             AS uid,
                 user_profile::sn              AS sn,
                 user_profile::crat            AS crat,
                 user_profile::name            AS name,
                 user_profile::description     AS description,
                 user_profile::url             AS url,
                 user_profile::location        AS location,
                 user_profile::time_zone       AS time_zone,
                 user_profile::utc             AS utc,
                 user_profile::followers       AS followers,
                 user_profile::friends         AS friends,
                 user_profile::statuses        AS statuses,
                 user_profile::favorites       AS favorites,
                 cut_style::bg_col             AS bg_col,
                 cut_style::txt_col            AS txt_col,
                 cut_style::sidebar_border_col AS sidebar_border_col,
                 cut_style::sidebar_fill_col   AS sidebar_fill_col,
                 cut_style::bg_tile            AS bg_tile,
                 cut_style::bg_img_url         AS bg_img_url,
                 cut_style::img_url            AS img_url,
                 user_profile::prot            AS prot
user    = LOAD '$WHOLE' AS (uid:long, sn:chararray, crat:long, name:chararray, descr:chararray, url:chararray, loc:chararray, zone:chararray, utc:chararray, followers:int, friends:int, statuses:int, favs:int. bg_col:chararray, txt_col:chararray, sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray, bg_img_url:chararray, img_url:chararray, prot:int);
sampled = SAMPLE user 0.0001; --get 0.01 percent of users ~4k

rmf $SMPLD;
STORE sampled INTO '$SMPLD';
