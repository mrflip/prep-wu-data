WORK_DIR = File.dirname(__FILE__).to_s + '/work/' 

# This creates a csv file for Joe to send to Mechanical Turk.
# 
# To cleanup the results for someone (Maegan) to look at, run this:
# cat Results_MTURK.csv | ruby -ne 'puts $_.chomp.split("\",\"")[24..29].join("\t")'

followed_file = File.open(WORK_DIR + 'followed_to_turk.csv','w')
followed_twitter = File.open(WORK_DIR + 'followed_twitter_to_turk.csv','w')

# csv_file = File.open(WORK_DIR + 'workstreamer_3700/followedCompanies04152010.csv')
# csv_file.readline 
# csv_file.each do |row|
#   fields = row.chomp.split('","')
#   name, url = fields[3].split(/\"\,\d+\,\"/)
#   followed_file << ['"' + name.rstrip + '"', url, "LinkedIn", "http://www.linkedin.com/companies/"].join(",") + "\n"
#   followed_file << ['"' + name.rstrip + '"', url, "Wikipedia", "http://en.wikipedia.org/wiki/"].join(",") + "\n"
#   followed_file << ['"' + name.rstrip + '"', url, "Del.icio.us", "http://delicious.com/"].join(",") + "\n"
#   followed_file << ['"' + name.rstrip + '"', url, "Facebook", "http://facebook.com/"].join(",") + "\n"
#   followed_twitter << ['"' + name.rstrip + '"', url, "Twitter", "http://www.twitter.com/"].join(",") + "\n"
# end

files_dir = Dir.open(WORK_DIR + 'workstreamer_3700/')
files_dir.each do |filename|
  case filename
  when /fortune_1000_chunk_\d+\.csv/
    csv_file = File.open(WORK_DIR + 'workstreamer_3700/' + filename)
    csv_file.readline
    csv_file.each do |row|
      fields = row.chomp.split('","')
      name, url = fields[1..2]
      followed_file << ['"' + name.rstrip + '"', url, "LinkedIn", "http://www.linkedin.com/companies/"].join(",") + "\n"
      followed_file << ['"' + name.rstrip + '"', url, "Wikipedia", "http://en.wikipedia.org/wiki/"].join(",") + "\n"
      followed_file << ['"' + name.rstrip + '"', url, "Del.icio.us", "http://delicious.com/"].join(",") + "\n"
      followed_file << ['"' + name.rstrip + '"', url, "Facebook", "http://facebook.com/"].join(",") + "\n"
      followed_twitter << ['"' + name.rstrip + '"', url, "Twitter", "http://www.twitter.com/"].join(",") + "\n"
    end
  when /popular_companies_chunk_\d+\.csv/
    csv_file = File.open(WORK_DIR + 'workstreamer_3700/' + filename)
    csv_file.readline
    csv_file.each do |row|
      fields = row.chomp.split('","')
      name, url = fields[3..4]
      followed_file << ['"' + name.rstrip + '"', url, "LinkedIn", "http://www.linkedin.com/companies/"].join(",") + "\n"
      followed_file << ['"' + name.rstrip + '"', url, "Wikipedia", "http://en.wikipedia.org/wiki/"].join(",") + "\n"
      followed_file << ['"' + name.rstrip + '"', url, "Del.icio.us", "http://delicious.com/"].join(",") + "\n"
      followed_file << ['"' + name.rstrip + '"', url, "Facebook", "http://facebook.com/"].join(",") + "\n"
      followed_twitter << ['"' + name.rstrip + '"', url, "Twitter", "http://www.twitter.com/"].join(",") + "\n"
    end
  end
end