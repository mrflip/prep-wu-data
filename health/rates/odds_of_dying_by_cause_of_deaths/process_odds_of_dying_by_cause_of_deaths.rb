#!/usr/bin/env ruby
require ('imw')


dsm = DatasetMunger.new_from_env()

#
# Creating this dataset required several hand-editing steps.
# 
#


#
# 
# I hand-edited one of the text 
#
def parse 
end


# Dir[dsm.path_to(:code_me, 'txt', 'OddsOfDying-2005.txt')].each do |odds_year_filename|
#   year = /OddsOfDying-(\d+)\.txt/.match(odds_year_filename)[1]
#   File.open(odds_year_filename) do |odds_file| 
#     file.each_line("e") {|line| puts "Got #{ line.dump }" } 
#   end 
# 
#   
# end
