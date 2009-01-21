
-- We want to get anyone who
--   used hashtag of interest	#mumbai
--   tweeted words of interest	mumbai|terror|attack|oberoi|taj
--   has a Indian TZ
--   description or location 	india|paki|bombay|jaipur|delhi|chennai|bangalore|[ck]olkata|calcutta
--   in India (but not Indiana)
-- 
--   is in 0th or 1st degree from http://www.mahalo.com/Mumbai_Terrorist_Attack_Twitter
--

-- ===========================================================================
--
-- Find tweets matching hotwords

-- # Mumbai Oberoi Taj Mahal
-- islam muslim moslem terror terrorist
-- Lashkar-E-Taiba Zardari
-- Chabad Lubavitch 
-- mujahideen
-- Sahadullah
-- |terror|attack
-- 
-- 'india|pakistan|mumbai|bombay|jaipur|delhi|chennai|bangalore|[ck]olkata|calcutta'
-- Godhra, Gujarat, Maharashtra Kashmir
-- Nariman Chabad
-- Ralph Burkei 
-- Colaba
-- NDTV
-- Vile Parle, in the Juhu region
-- 
-- http://www.cnn.com/2008/WORLD/asiapcf/11/27/mumbai.attacks.web.sites/
-- 

-- ===========================================================================
--
-- Find hashtags matching hotwords

-- ===========================================================================
--
-- Find users whose name matches hotwords 


-- ===========================================================================
--
-- Find users in the 1-hood of those mentioned here: http://www.mahalo.com/Mumbai_Terrorist_Attack_Twitter
n0_users_1 = FILTER Users BY screen_name MATCHES '(kari_shma|gsik|Puneet|acmhatre|Netra|anilenand|ahmaurya|bombayaddict|shefaly|primaveron)' ;
n0_users_2 = JOIN n0_users_1 BY user_id, UserProfiles BY user_id ; 
n0_users_3 = FOREACH n0_users_2 GENERATE 'twitter_user_full' AS rsrc:chararray, n0_users_1::user_id AS user_id, n0_users_1::scraped_at AS scraped_at, screen_name, protected, followers_count, friends_count, statuses_count, favorites_count, created_at, full_name, url, location, description, time_zone, utc_offset ;
STORE n0_users_3 INTO 'meta/november/seed_users_full.tsv' ;

-- ===========================================================================
--
-- Find users in India's time zone
tz_users_1 = FILTER UserProfiles BY utc_offset == 19800 ;
tz_users_2 = JOIN tz_users_1 BY user_id, Users BY user_id ; 
tz_users_3 = FOREACH tz_users_2 GENERATE 'twitter_user_full' AS rsrc:chararray, tz_users_1::user_id AS user_id, tz_users_1::scraped_at AS scraped_at, screen_name, protected, followers_count, friends_count, statuses_count, favorites_count, created_at, full_name, url, location, description, time_zone, utc_offset ;
STORE tz_users_3 INTO 'meta/november/seed_users_tz19800.tsv' ;


-- ===========================================================================
--
-- Find users with india hotwords in their location


Hindi           422             hi      hin     -       hin     Hindi
Bengali         180             bn      ben     -       ben     Bengali
Telugu           74             te      tel     -       tel     Telugu
Marathi          72             mr      mar     -       mar     Marathi
Tamil            61             ta      tam     -       tam     
Urdu             52      8%     ur      urd     -       urd     Urdu
Gujarati         46             gu      guj     -       guj     Gujarati
Kannada          38             kn      kan     -       kan     Kannada
Malayalam        33             ml      mal     -       mal     Malayalam
Oriya            33             or      ori     -       ori     Oriya
Punjabi          29     44%     pa      pan     -       pan     Panjabi
Sindhi            3     14%     sd      snd     -       snd     Sindhi
Pashto                  15%     ps      pus     -       pus+3   Pashto


http://en.wikipedia.org/wiki/Languages_of_Pakistan
http://en.wikipedia.org/wiki/Languages_of_India
