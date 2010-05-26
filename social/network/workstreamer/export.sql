SELECT md5,jigsaw_id,jigsaw_url,display_name,num_followers,website,ticker,phone,address_1,address_2,city,state,zip,country,linkedin,wikipedia,yg_finance,manta,zoominfo,twitter_all,blog,
facebook,flickr,youtube,scribd,delicious
FROM final_company_listings
WHERE filename='li_tw_wp-p1-1.csv'
INTO OUTFILE '/data/work/workstreamer/results/followedCompanies_20100427.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT md5,jigsaw_id,jigsaw_url,display_name,website,ticker,phone,address_1,address_2,city,state,zip,country,linkedin,wikipedia,yg_finance,manta,zoominfo,twitter_all,blog,
facebook,flickr,youtube,scribd,delicious
FROM final_company_listings
WHERE filename='popular_companies.csv'
INTO OUTFILE '/data/work/workstreamer/results/popular_companies_20100427.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT jigsaw_id,display_name,website,phone,address_1,city,state,zip,country,ind_1,ind_1_sub,ind_2,ind_2_sub,ind_3,ind_3_sub,
sic,employees,employees_rg,revenue,revenue_rg,ownership,ticker,n_contacts,jigsaw_url,
linkedin,wikipedia,yg_finance,manta,zoominfo,twitter_all,blog,facebook,flickr,youtube,scribd,delicious
FROM final_company_listings
WHERE filename='fortune.csv'
INTO OUTFILE '/data/work/workstreamer/results/fortune_1000_20100427.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';