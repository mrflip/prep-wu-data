/*
From

TwitterUserPartial 
  -- [:id,                     Integer]       
  -- [:scraped_at,             Bignum]
  -- [:screen_name,            String]
  -- [:protected,              Integer]
  -- [:followers_count,        Integer]
  -- [:name,                   String]        
  -- [:url,                    String]
  -- [:location,               String]
  -- [:description,            String]
  -- [:profile_image_url,      String]         
  
  TwitterUserProfile 
  -- [:id,                     Integer]
  -- [:scraped_at,             Bignum]
  -- [:name,                   String]
  -- [:url,                    String]
  -- [:location,               String]
  -- [:description,            String]
  -- [:time_zone,              String]
  -- [:utc_offset,             String]

*/


-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTPUT '/data/pkgd/social/network/twitter/users_by_location'
%default USER_PROFILE '/data/rawd/social/network/twitter/objects/twitter_user_profile';
%default USER_PARTIAL '/data/rawd/social/network/twitter/objects/twitter_user_partial';

--
-- User profiles with location names
-- 
AllUserProfile     = LOAD '$USER_PROFILE' AS (rsrc:chararray, id:long,
                                              scraped_at:long, name:chararray,
                                              url:chararray, location:chararray,
                                              description:chararray, time_zone:chararray,
                                              utc_offset:chararray);

TwitterUserProfile = FOREACH AllUserProfile GENERATE id, location;
ProfileWLocation   = FILTER TwitterUserProfile BY location IS NOT NULL;

--
-- User partials with location names
-- 
AllUserPartial     = LOAD '$USER_PARTIAL' AS (rsrc:chararray, id:long,
                                              scraped_at:long, screen_name:chararray,
                                              protected:long, followers_count:long,
                                              name:chararray, url:chararray,
                                              location:chararray, description:chararray,
                                              profile_image_url:chararray);

TwitterUserPartial = FOREACH AllUserPartial GENERATE id, location;
PartialWLocation   = FILTER TwitterUserPartial BY location IS NOT NULL;

-- Union of the two things with locations and group by location
AllWLocation       = UNION ProfileWLocation, PartialWLocation;
LocationGroup      = GROUP AllWLocation BY location;
LocationCount      = FOREACH LocationGroup GENERATE group, COUNT(AllWLocation);

rmf $OUTPUT;
STORE LocationCount INTO '$OUTPUT';
