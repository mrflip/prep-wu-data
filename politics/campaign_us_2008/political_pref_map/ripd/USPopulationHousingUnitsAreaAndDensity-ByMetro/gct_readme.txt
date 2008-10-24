Readme File for Geographic Comparison Tables (GCTs) 

1. gct_readme.txt

This readme file is provided to explain the file naming conventions and general content of the downloaded files.

When applicable, a second data set specific readme file is also provided to explain potential gaps in the data for the selected geographic areas. In many data sets in American FactFinder (AFF), not all data are available for all geographic areas. The specific reason varies with each data set but in general is due to one of the following reasons:

- sampling sizes
- population thresholds
- geographic thresholds for selected tables 	  

Be sure to consult the data set specific readme file when it is provided.


2. Geographic Comparison Table data file and what it contains. 

a) File type extensions: 

The data file is either a comma or pipe delimited text file (.txt), or Microsoft Excel (.xls) file. The data file name is formatted as follows:

	gct_<dataset>_data<iteration>0.<ext> 
	
	<dataset> = the unique data set name
	<iteration> = a 3 digit iteration code followed by an underscore '_'
	<ext> = the chosen file extension (.txt or .xls)

<iteration> is only included for data sets containing tables that are repeated for Race and Ethnic Groups and/or Ancestries, for example, Summary Files 2 and 4 from Census 2000. 

The data file includes the following columns related to the geographic areas in the GCT:

	GEO_ID: the Geographic Identifier
	GEO_ID2: the GIS-compatible Geographic Identifier
	SUM_LEVEL: the Summary Level Code
	CHARITER: for data sets containing iterations, the 3 digit code 
	that corresponds to the selected Race and/or Ethnic Group

GCTs can only be displayed and downloaded one at a time

	
b) Formation of the Geographic Identifier (GEO_ID).
	
The GEO_ID is used in the American FactFinder to uniquely identify each geography.  A GEO_ID is formed by appending a series of text strings: 3-digit summary level code + '00US' + applicable geocodes.  For example, the GEO_ID for Autauga County, Alabama would be formed by appending: '050' + '00US' + '01' (State FIPS) + '001' (County FIPS) to produce: '05000US01001'.

The GEO_ID2 can be used by GIS software users who use Census data and need a common key to link AFF tabular data to TIGER spatial data.  GEO_ID2 is a field that contains the applicable geocodes without the 3-digit summary level code and the '00US'.


3) Refer to the Readme_<dataset>.txt for more information

Refer to individual readme files for each data set for further explanation. 

4) Data Set Technical Documentation

The technical documentation is available from the data sets page. Click on the data set radio button and then click on the Technical Documentation link. The data set page can be bookmarked:

http://factfinder.census.gov/servlet/DatasetMainPageServlet?_lang=en
