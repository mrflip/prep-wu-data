%default USER    '/data/sn/tw/fixd/objects/twitter_user'
%default PROFILE '/data/sn/tw/fixd/objects/twitter_user_profile'
%default STYLE   '/data/sn/tw/fixd/objects/twitter_user_style'        
%default OBJ     '/data/sn/tw/client/generic/whole_users'
        
user    = LOAD '$USER'    AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int,         followers:int,     friends:int,        statuses:int,                 favs:int,                   crat:long);                                                                             
profile = LOAD '$PROFILE' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, name:chararray,   url:chararray,     location:chararray, description:chararray,        time_zone:chararray,        utc:chararray);                                                                           
style   = LOAD '$STYLE'   AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, bg_col:chararray, txt_col:chararray, link_col:chararray, sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray, bg_img_url:chararray, img_url:chararray);                    

cut_user    = FOREACH user    GENERATE uid, scrat, sn, prot, followers, friends, statuses, favs, crat;
cut_profile = FOREACH profile GENERATE uid, name, url, location, description, time_zone, utc;
cut_style   = FOREACH style   GENERATE uid, bg_col, txt_col, link_col, sidebar_border_col, sidebar_fill_col, bg_tile, bg_img_url, img_url;

joined_profile = JOIN cut_user BY uid, cut_profile BY uid;
user_profile   = FOREACH joined_profile GENERATE
                     cut_user::uid            AS uid,
                     cut_user::sn             AS sn,
                     cut_user::crat           AS crat,
                     cut_user::scrat          AS scrat,     
                     cut_profile::name        AS name,
                     cut_profile::description AS description,
                     cut_profile::url         AS url,
                     cut_profile::location    AS location,
                     cut_profile::time_zone   AS time_zone,
                     cut_profile::utc         AS utc,
                     cut_user::followers      AS followers,
                     cut_user::friends        AS friends,
                     cut_user::statuses       AS statuses,
                     cut_user::favs           AS favorites,
                     cut_user::prot           AS prot
                 ;

joined_all = JOIN user_profile BY uid, cut_style BY uid;
whole_user = FOREACH joined_all GENERATE
                 user_profile::uid             AS uid,
                 user_profile::sn              AS sn,
                 user_profile::crat            AS crat,
                 user_profile::scrat           AS scrat,
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
                 cut_style::sidebar_fill_col   AS sidebra_fill_col,
                 cut_style::bg_tile            AS bg_tile,
                 cut_style::bg_img_url         AS bg_img_url,
                 cut_style::img_url            AS img_url,
                 user_profile::prot            AS prot
             ;

ordered = ORDER whole_user BY favorites DESC;
rmf $OBJ;

STORE ordered INTO '$OBJ';
