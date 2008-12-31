TODO

-- rescrape followers with the ?since= parameter
-- scrape users/show for a contiguous stretch of IDs


-- normalize tup into timestamped columnss


-- twoosh: take most frequent tweet length as fraction of tweets -> histogram

- for each dimension pair X, Y, by %ile find ∂y for that x
  also cut out a sample

-- compare in-link and out-link prestige; also each vs prestige of high-value 1-hood.

  metafilter			disX
  memeorandum via waxy.org	
  blog authorship corpus 	is.gd/dile	blogger.com 2004
  111 MB of ycombinator 	dilP
get.theinfo
  spinn3r 142 GB blog crawl	dimU
  boards.ie			9RHh
  share.opml.org		
  persai			diog  

  twitter			diyl

potts@linguist.umass.edu




****************************************************************************
Scraper
  ++ 	scrape_request:
	  context		priority	id	page	screen_name
  =>	fetches file
****************************************************************************
Bundler
  ++	listing of scraped files,
  ++	scraped files
  => 	emit file metadata in order;
	cat files in order
	-> paste
	   context	scrape_date	priority	id	page	screen_name	size	scraped_at

****************************************************************************
Parser
  ++	bundled files
  => 	raw parsed data


- PARSE_JSON
  twitter_user_partial:	user_id		scraped_at	screen_name	protected	followers_count	
  		       	  		  		name		url		location	description
	       	  					image_url 
  twitter_user	      :	user_id		scraped_at	screen_name	protected	followers_count	friends_count	faves_count	statuses_count	created_at	
  twitter_user_profile:	user_id		scraped_at	name		url		location	description	time_zone	utc_offset
  twitter_user_style  :	user_id		scraped_at	image_url	bg_color	text_color	link_color	sb_border_color	sb_fill_color	bg_image_url	bg_tile
  a_follows_b	      :	a_id-b_id	scraped_at
  tweet		      :	tweet_id	created_at	user_id		text		favorited	truncated	tweet_len	inre_user_id	inre_status_id	fromsource	fromsource_url

- PARSE_TWEETS		tweet, user_ids
  a_atsigns_b		a_id		b_id		status_id	inre_status_id	is_retweet
  hashtag		user_id		hashtag		status_id
  tweet_url		user_id		url		status_id

- USER_WORDS		
  user_tweet_word	user_id		word		count		freq_user	freq_corpus	bnc_head	bnc_written_freq
  tweet_word		word		count		freq_corpus
  bnc_headwords		word				freq_corpus	freq_written	freq_spoken	range		dispersion	pos_list
  bnc_lemmas		word		headword	freq_corpus	freq_written	freq_spoken	range		dispersion	pos_list

- LIST_SCRAPED_FILES
  scraped_file		scraped_at	context 	user_id		page		screen_name	size		scrape_session
  
- PLAN_SCRAPE		< twitter_user_*, scraped_files 
  scrape_status		user_id		screen_name	protected	followers_count	friends_count	created_at	u_scraped_at	tup_scraped_at	foll_scraped_at	fr_scraped_at
  scrape_request	user_id		context		priority	page		screen_name	

- EXPAND_URLS
  expanded_urls		short_url	dest_url

- 

  
****************************************************************************
Metrics:

* followers/day, ∂(followers) in last (21?) days (see SHAQ for picture of ascent)
* avg, stdev of tweets/day
* influx: Sum[(tweets/day)] for all followed 
* outflux: followers * tweets/day
* friends/followers
* geolocation
* 

****************************************************************************
2-hood properties
Consider edges (in- and out-) of all members (in- and out-) of a node's 1-hood.

* out-perimeter: unique nodes at distance 2 following two out-edges.
* in-perimeter: similarly

* out-triangles: friends of
  
* loops: triangles with 'flow' (A follows B, B follows C, C follows A).
  shared interest: A follows B and 
 
  triangle categorization


****************************************************************************

Corpora:
by user, text stream: <bio | location | tweets... >

