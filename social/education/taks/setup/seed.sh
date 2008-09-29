#!/usr/bin/env bash
killall mysqld 2>/dev/null

# Make directories
echo "Making directories"
mkdir -p /d2/flip/{bkup,mysql/db,mysql/log} /tmp/mysql 
# Create mysql scaffold
echo "Making mysql scaffold"
/public/share/mysql/bin/mysql_install_db --user=flip --datadir=/d2/flip/mysql/db --basedir=/public/share/mysql --defaults-file=/home/flip/.my.cnf >> /tmp/mysql-seed.log
# Start DB
echo "Starting database"
mysqld_safe --defaults-file=/home/flip/.my.cnf &
# Set passwords
echo "Setting passwords: hit enter"
/public/share/mysql/bin/mysqladmin -u root -p password "$password"
for machine in $machines ; do
  echo "grant all privileges on *.* to root@$machine  identified by '$password';" | mysql
done

# Create databases
echo "create database taks;"      	| mysql
echo "create database taks_rawk;" 	| mysql
# Load in initial data
echo "Getting initial data"
rsync -Cuzrtlp womper.ph.utexas.edu:/foo/taks-data/ /d2/flip/bkup/
mkdir /tmp/mysqlload
for foo in /d2/flip/bkup/*.mysql.bz2 ; do echo "Extracting initial data $foo" ;  bzcat $foo > /tmp/mysqlload/`basename $foo .bz2`           ; done
for foo in /tmp/mysqlload/*          ; do echo "Loading initial data $foo"    ;  cat $foo   | mysql taks ; done
#cat ~/now/taks/queries.sql        	| mysql
#cat ~/now/taks/transitiontable.sql 	| mysql
cat ~/now/taks/01-create-tables-alt.sql | mysql

