#!/usr/bin/env ruby

filename = ARGV[0]
data = File.open(filename, 'r')
chnk_hsh = {}
field_mtchr = /\={4}([^\=]+)\={4}/
kill_nms = /^\d{1,2}\./
data.each('<b>') do |chunk|
  #parse chunk for interesting data
  field_mtchr.match(chunk)
  field = $1
  unless  field == nil
    field = $1.strip
  else
    field = "Other"
  end
  chnk_hsh[field] = chunk.gsub('<b>',"").gsub('<HTML>',"").gsub('</b>',"").gsub('<pre>',"").gsub(field_mtchr,"").gsub(kill_nms, "").strip
end

#chnk_hsh.each{|k,v| puts "#{k} => #{v}\n\n"}

p chnk_hsh.keys
#lines = File.readlines
#
#idsection = ProductIdentification.new
#idsection.read(lines)
#idsection.parse
#
#ingred = Ingredients.new
#ingred.read(lines)
#ingred.parse
#
#etc...


