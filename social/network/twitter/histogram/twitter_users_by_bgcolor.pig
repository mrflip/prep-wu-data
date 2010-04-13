/*
From

  TwitterUserStyle   
  -- [:id,                             Integer]
  -- [:scraped_at,                     Bignum]
  -- [:profile_background_color,       String]
  -- [:profile_text_color,             String]
  -- [:profile_link_color,             String]
  -- [:profile_sidebar_border_color,   String]
  -- [:profile_sidebar_fill_color,     String]
  -- [:profile_background_tile,        String]
  -- [:profile_background_image_url,   String]
  -- [:profile_image_url,              String]

	
*/


-- This script results in a tsv of users by their profile colors  across the whole twitter stream.
-- ie:
--
--     color    num_users
--
--     1        1000
--     23       40
--     1498     1
--
--


-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTPUT       '/data/pkgd/social/network/twitter/bgcolor_count';
%default USER_STYLE   '/data/rawd/social/network/twitter/objects/twitter_user_style';

UserStyle        = LOAD '$USER_STYLE' AS (rsrc:chararray, id:long,
                                          scraped_at:long, profile_background_color:chararray,
                                          profile_text_color:chararray, profile_link_color:chararray,
                                          profile_link_color:chararray, profile_sidebar_border_color:chararray,
                                          profile_sidebar_fill_color:chararray, profile_background_tile:chararray,
                                          profile_background_image_url:chararray, profile_image_url:chararray);
                                        
TwitterUserStyle = FOREACH UserStyle GENERATE id, profile_background_color;
UserWBgColor     = FILTER TwitterUserStyle BY profile_background_color IS NOT NULL;

BgColorGroup     = GROUP UserWBgColor BY profile_background_color;
BgColorCount     = FOREACH BgColorGroup GENERATE group, COUNT(UserWBgColor);

rmf $OUTPUT;
STORE BgColorCount INTO '$OUTPUT';
