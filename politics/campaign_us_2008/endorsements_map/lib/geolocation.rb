require File.dirname(__FILE__)+'/hash_of_structs'

#
# data from the geonames.org data dump
#
# geonameid         : integer id of record in geonames database
# ** u_name         : name of geographical point (utf8) varchar(200)
# city              : name of geographical point in plain ascii characters, varchar(200)
# ** alternatenames : alternatenames, comma separated varchar(4000) (varchar(5000) for SQL Server)
# latitude          : latitude in decimal degrees (wgs84)
# longitude         : longitude in decimal degrees (wgs84)
# feature class     : see http://www.geonames.org/export/codes.html, char(1)
# feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
# country code      : ISO-3166 2-letter country code, 2 characters
# cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 60 characters
# admin1 code       : fipscode (subject to change to iso code), isocode for the us and ch, see file admin1Codes.txt for display names of this code; varchar(20)
# admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80)
# admin3 code       : code for third level administrative division, varchar(20)
# admin4 code       : code for fourth level administrative division, varchar(20)
# population        : integer
# elevation         : in meters, integer
# gtopo30           : average elevation of 30'x30' (ca 900mx900m) area in meters, integer
# timezone          : the timezone id (see file timeZone.txt)
# modification date : date of last modification in yyyy-MM-dd format
#
#geonameid      u_name  city    altnm   lat     lng     f_cl    f_code  cc      cc2     admin1  admin2  admin3  admin4  pop     elev    gtopo30 timezone        modification_date
#4099296        Alma    Alma            35.4778 -94.221 P       PPL     US              AR      033                     4474    132     133     America/Chicago 2006-01-17
# 0             1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17              18
#               -omit-          -omit-
class Geolocation < Struct.new(
    :geonameid,
    # :unicode_name,
    :city,
    # :altnm,
    :lat, :lng, :f_cl, :f_code,
    :cc, :cc2, :st, :admin2, :admin3, :admin4,
    :pop, :elev, :gtopo30, :timezone, :modification_date)
  include HashOfStructs
  def self.make_key(st, city) [st, city]            end
  def key()                   [self.st, self.city]  end
end
