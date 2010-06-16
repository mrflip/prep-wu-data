SELECT COUNT(website),COUNT(facebook),COUNT(linkedin),COUNT(twitter),COUNT(wikipedia),COUNT(youtube)
FROM june_company_listings

SELECT object_id,display_name,website
FROM june_company_listings
WHERE facebook IS NULL
INTO OUTFILE '/Users/doncarlo/data/workstreamer/facebook-needed-20100608.tsv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'

SELECT object_id,display_name,website,facebook,linkedin,twitter,wikipedia,youtube
FROM june_company_listings
INTO OUTFILE '/Users/doncarlo/data/workstreamer/all-results-20100608.tsv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
