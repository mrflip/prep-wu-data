#!/bin/bash

dbhost="localhost"
dbname="vizsagedb_aux"
dbuser="vizsagedb"
zoneinfo=/work/DataSources/Data_Aux/zoneinfo/tzdir/etc/zoneinfo-leaps/

echo >&2  "Don't sweat it if you see a few warnings about skipping Riyadh87 or zone.tab or somesuch"

( 
  echo "use $dbname;"; 
  cat AuxTable-TZ-Create.sql
  mysql_tzinfo_to_sql $zoneinfo; 
  cat AuxTable-TZ-Alter.sql

) | mysql -E -h $dbhost -u $dbuser -p
