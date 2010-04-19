$: << '/Users/doncarlo/ics/rubygems/fastercsv-1.5.1/lib/'
require 'rubygems'
require 'fastercsv'

WORK_DIR = File.dirname(__FILE__).to_s + '/work/' 

csv_file = File.open(WORK_DIR + 'workstreamer_3700/followedCompanies04152010.csv')
csv_file.readline

followed_file = File.open(WORK_DIR + 'followed_to_turk.csv','w')
followed_twitter = File.open(WORK_DIR + 'followed_twitter_to_turk.csv','w')

csv_file.each do |row|
  fields = row.chomp.split('","')
  name, url = fields[3].split(/\"\,\d+\,\"/)
  followed_file << ['"' + name.rstrip + '"', url, "LinkedIn", "http://www.linkedin.com/companies/"].join(",") + "\n"
  followed_file << ['"' + name.rstrip + '"', url, "Wikipedia", "http://en.wikipedia.org/wiki/"].join(",") + "\n"
  followed_file << ['"' + name.rstrip + '"', url, "Del.icio.us", "http://delicious.com/"].join(",") + "\n"
  followed_file << ['"' + name.rstrip + '"', url, "Facebook", "http://facebook.com/"].join(",") + "\n"
  followed_twitter << ['"' + name.rstrip + '"', url, "Twitter", "http://www.twitter.com/"].join(",") + "\n"
end