%default USERSTYLE '/data/sn/tw/fixd/objects/twitter_user_style'
%default FIXEDIDS  '/data/sn/tw/fixd/objects/twitter_user_id_matched';
%default COOLPPL   '/data/sn/tw/cool/cool_ppl';
%default COOLOUT   '/data/sn/tw/cool/twitter_user_style';

Stylz = LOAD '$USERSTYLE' AS (
                  rsrc:              chararray,
                  user_id:           long,
                  scraped_at:        long,
                  bgrnd_color:       chararray,
                  text_color:        chararray,
                  link_color:        chararray,
                  side_border_color: chararray,
                  side_fill_color:   chararray,
                  bgrnd_tile:        chararray,
                  bgrnd_url:         chararray,
                  profile_image_url: chararray
             );

MatchedIds = LOAD '$FIXEDIDS' AS (
                  rsrc:             chararray,
                  user_id:          long,
                  scraped_at:       long,
                  screen_name:      chararray,
                  protected:        int,
                  followers_count:  long,
                  friends_count:    long,
                  statuses_count:   long,
                  favourites_count: long,
                  created_at:       long,
                  search_id:        long,
                  is_full:          long,
                  health:           chararray
             );
             
CoolPPLZ = LOAD '$COOLPPL' AS (
                screen_name: chararray
           );

CoolPPLOnly = JOIN CoolPPLZ BY screen_name, MatchedIds BY screen_name;
CoolPPLIds  = FOREACH CoolPPLOnly GENERATE
                         MatchedIds::user_id     AS user_id,
                         ;             

Joined          = JOIN CoolPPLIds BY user_id, Stylz BY user_id;
JustStylz = FOREACH Joined GENERATE
                         Stylz::user_id:          AS user_id,
                         Stylz::scraped_at        AS scraped_at, 
                         Stylz::bgrnd_color       AS bgrnd_color,
                         Stylz::text_color        AS text_color,
                         Stylz::link_color        AS link_color,
                         Stylz::side_border_color AS side_border_color,
                         Stylz::side_fill_color   AS side_fill_color,
                         Stylz::bgrnd_tile        AS bgrnd_tile,
                         Stylz::bgrnd_url         AS bgrnd_url,
                         Stylz::profile_image_url AS profile_image_url
                         ;
rmf $COOLOUT;
STORE JustStylz INTO '$COOLOUT';
