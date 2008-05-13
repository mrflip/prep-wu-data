#!/usr/bin/env ruby
# Setup environmend
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'traversal'
require 'rubygems'
require 'hpricot'

# run rip-ersys.com.sh first

html_dir    = './rawd/www.ersys.com/usa'
state_code  = '01'
city_code   = '0100820'
html_file   = 'distance.htm'

# 
def fix_crlf(s) 
  s.to_s.gsub(%r![\r\n]!, "").gsub('&nbsp;', ' ')
end

def parse_head_rows(td_list)
  # first we have a bunch of rows with the top titles; they're in reverse order actually
  header_cities = []
  # eat them off the top
  while (! td_list.empty?) do
    td = td_list.shift
    city = fix_crlf(td/"*/*/")                    # get contents
    next if (%r!^(?:&nbsp;|\s)*$!o.match(city))   # skip empty ones 
    if ( city_match = (%r!^([^>]+),\s+([A-Z][A-Z])$!o.match(city)) ) then 
      header_cities.unshift(city_match.captures())
    else
      # oops, there's the first non-header line.  put it back and continue on.
      td_list.unshift(td); break
    end
  end
  header_cities
end


$ROW_CITIES_RE   = %r{(?:<a[^>]*\d+/\d+/distance\.htm[^>]*>)?([^<]+),\s*([A-Z][A-Z])}o
$ROW_MILEAGES_RE = %r{^\s*(\d+)\s*$}o
def parse_col_of_brs(td, re_to_match)
  # split at <br>'s
  rows = fix_crlf(td).split(%r!<br[^>]*>!o)
  rows.map! do |row|
    # strip out bolded rows
    row.gsub!(%r!</?b>!, '')
    # and save captures
    m = re_to_match.match(row) or next
    m.captures()
  end.compact!
  rows
end

def extract_mileages(filename)
  # pull in the whole document, let Hpricot do its thang.
  doc = open(filename) { |f| Hpricot(f) }
  # Depend on the table being at this xpath
  td_list = (doc/"html/body//table//table//table//table//td").to_a
  # first we have a bunch of rows with the top titles; they're in reverse order actually
  header_cities = parse_head_rows(td_list)
  # next are the row cities; they're separated by '<br ?/?>'
  row_cities    = parse_col_of_brs(td_list.shift, $ROW_CITIES_RE)
  # finally, the mileages
  row_mileages  = td_list.map do |td|
    parse_col_of_brs((td/"font/"), $ROW_MILEAGES_RE).flatten
  end

  warn "missing or extra cities in %s: %s cities, %s mileages" % 
    [filename, header_cities.length, row_mileages.length] if (header_cities.length != row_mileages.length)
  row_mileages.each do |mi|
    warn "missing or extra row cities in %s: %s cities, %s mileages" % 
      [filename, row_cities.length, mi.length] if (row_cities.length != mi.length)
  end
  
  [ header_cities, row_cities, row_mileages ]
end

def identify(table, el)
  table[el] = table.length if !table.include?(el)
end

# process each file
cities        = {}
mi_table = {}
Dir["%s/%s/%s/%s" %[ html_dir, '[0-9]*', '[0-9]*', html_file ]].to_a.each do |filename|
  
  header_cities, row_cities, row_mileages = extract_mileages(filename)
  
  header_cities.each{ |city| identify(cities, city) }
  row_cities.each{    |city| identify(cities, city) }
  
  header_cities.zip(row_mileages).each do |col, mis|
    row_cities.zip(mis).each do |row, mi|
      pair = [col, row]
      warn "Differing mileages %s vs %s for %s" % 
        [mi, mi_table[pair], pair.to_json] if ((mi_table.include?(pair)) && (mi_table[pair] != mi))
      mi_table[ [col, row] ] = mi_table[ [row, col] ] = mi
    end
  end
  
  # puts "%s\t%s\t%s\n" % [row_cities.length, filename, row_cities.to_json]
  # puts "%s\t%s\t%s\n" % [header_cities.length, filename, header_cities.to_json]
  # puts row_mileages.length
  # row_mileages.each do |mi|
  #   puts "%s\t%s\n" % [mi.length, mi.to_json]
  # end
end
allcities = cities.keys.map(&:reverse).sort.map(&:reverse)
allcities.each do |city| 
  puts "%-23s\t%s\t%s" % [ city[0], city[1], allcities.map{ |col| "%5s" % (mi_table[[city, col]] || '') }.join('') ]
end

# <table width=100% border=0>
# <tr><td align=right ColSpan=12><font face='Arial,Verdana,Helvetica' size=1>New Orleans, LA</font></td>
# </tr>
# <tr><td align=right bgcolor='#fff2bf' ColSpan=11><font face='Arial,Verdana,Helvetica' size=1>Nashville, TN</font></td>
# <td align=right RowSpan=10><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right ColSpan=10><font face='Arial,Verdana,Helvetica' size=1>Montgomery, AL</font></td>
# <td align=right bgcolor='#fff2bf' RowSpan=9><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right bgcolor='#fff2bf' ColSpan=9><font face='Arial,Verdana,Helvetica' size=1>Mobile, AL</font></td>
# <td align=right RowSpan=8><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right ColSpan=8><font face='Arial,Verdana,Helvetica' size=1>Memphis, TN</font></td>
# <td align=right bgcolor='#fff2bf' RowSpan=7><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right bgcolor='#fff2bf' ColSpan=7><font face='Arial,Verdana,Helvetica' size=1>Columbus, GA</font></td>
# <td align=right RowSpan=6><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right ColSpan=6><font face='Arial,Verdana,Helvetica' size=1>Birmingham, AL</font></td>
# <td align=right bgcolor='#fff2bf' RowSpan=5><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right bgcolor='#fff2bf' ColSpan=5><font face='Arial,Verdana,Helvetica' size=1>Baton Rouge, LA</font></td>
# <td align=right RowSpan=4><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right ColSpan=4><font face='Arial,Verdana,Helvetica' size=1>Augusta, GA</font></td>
# <td align=right bgcolor='#fff2bf' RowSpan=3><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right bgcolor='#fff2bf' ColSpan=3><font face='Arial,Verdana,Helvetica' size=1>Atlanta, GA</font></td>
# <td align=right RowSpan=2><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right bgcolor='#cfdfff' ColSpan=2><font face='Arial,Verdana,Helvetica' size=1>Alabaster, AL</font></td>
# <td align=right bgcolor='#fff2bf' RowSpan=1><font face='Arial,Verdana,Helvetica' size=1>&nbsp;</font></td></tr>
# <tr><td align=right bgcolor='#fff2bf'><font face='Arial,Verdana,Helvetica' size=1><a href='/usa/13/1301052/distance.htm'>Albany,&nbsp;GA</a><br><a href='/usa/01/0101852/distance.htm'>Anniston,&nbsp;AL</a><br><a href='/usa/37/3702140/distance.htm'>Asheville,&nbsp;NC</a><br><a href='/usa/13/1303440/distance.htm'>Athens,&nbsp;GA</a><br><a href='/usa/13/1304000/distance.htm'>Atlanta,&nbsp;GA</a><br><br><a href='/usa/13/1304204/distance.htm'>Augusta,&nbsp;GA</a><br><a href='/usa/22/2205000/distance.htm'>Baton&nbsp;Rouge,&nbsp;LA</a><br><a href='/usa/28/2806220/distance.htm'>Biloxi,&nbsp;MS</a><br><a href='/usa/01/0107000/distance.htm'>Birmingham,&nbsp;AL</a><br><a href='/usa/47/4714000/distance.htm'>Chattanooga,&nbsp;TN</a><br><br><a href='/usa/47/4715160/distance.htm'>Clarksville,&nbsp;TN</a><br><a href='/usa/45/4516000/distance.htm'>Columbia,&nbsp;SC</a><br><a href='/usa/13/1319007/distance.htm'>Columbus,&nbsp;GA</a><br><a href='/usa/01/0120104/distance.htm'>Decatur,&nbsp;AL</a><br><a href='/usa/01/0121184/distance.htm'>Dothan,&nbsp;AL</a><br><br><a href='/usa/18/1822000/distance.htm'>Evansville,&nbsp;IN</a><br><a href='/usa/01/0126896/distance.htm'>Florence,&nbsp;AL</a><br><a href='/usa/12/1224475/distance.htm'>Ft.&nbsp;Walton&nbsp;Beach,&nbsp;FL</a><br><a href='/usa/01/0128696/distance.htm'>Gadsden,&nbsp;AL</a><br><a href='/usa/45/4530850/distance.htm'>Greenville,&nbsp;SC</a><br><br><a href='/usa/28/2829700/distance.htm'>Gulfport,&nbsp;MS</a><br><a href='/usa/28/2831020/distance.htm'>Hattiesburg,&nbsp;MS</a><br><a href='/usa/01/0135896/distance.htm'>Hoover,&nbsp;AL</a><br><a href='/usa/22/2236255/distance.htm'>Houma,&nbsp;LA</a><br><a href='/usa/01/0137000/distance.htm'>Huntsville,&nbsp;AL</a><br><br><a href='/usa/28/2836000/distance.htm'>Jackson,&nbsp;MS</a><br><a href='/usa/47/4737640/distance.htm'>Jackson,&nbsp;TN</a><br><a href='/usa/47/4738320/distance.htm'>Johnson&nbsp;City,&nbsp;TN</a><br><a href='/usa/05/0535710/distance.htm'>Jonesboro,&nbsp;AR</a><br><a href='/usa/22/2239475/distance.htm'>Kenner,&nbsp;LA</a><br><br><a href='/usa/47/4740000/distance.htm'>Knoxville,&nbsp;TN</a><br><a href='/usa/05/0541000/distance.htm'>Little&nbsp;Rock,&nbsp;AR</a><br><a href='/usa/13/1349000/distance.htm'>Macon,&nbsp;GA</a><br><a href='/usa/13/1349756/distance.htm'>Marietta,&nbsp;GA</a><br><a href='/usa/47/4748000/distance.htm'>Memphis,&nbsp;TN</a><br><br><a href='/usa/01/0150000/distance.htm'>Mobile,&nbsp;AL</a><br><a href='/usa/22/2251410/distance.htm'>Monroe,&nbsp;LA</a><br><a href='/usa/01/0151000/distance.htm'>Montgomery,&nbsp;AL</a><br><a href='/usa/47/4751560/distance.htm'>Murfreesboro,&nbsp;TN</a><br><a href='/usa/47/4752006/distance.htm'>Nashville,&nbsp;TN</a><br><br><a href='/usa/22/2255000/distance.htm'>New&nbsp;Orleans,&nbsp;LA</a><br><a href='/usa/05/0550450/distance.htm'>North&nbsp;Little&nbsp;Rock,&nbsp;AR</a><br><a href='/usa/21/2158620/distance.htm'>Owensboro,&nbsp;KY</a><br><a href='/usa/12/1254700/distance.htm'>Panama&nbsp;City,&nbsp;FL</a><br><a href='/usa/12/1255925/distance.htm'>Pensacola,&nbsp;FL</a><br><br><a href='/usa/05/0555310/distance.htm'>Pine&nbsp;Bluff,&nbsp;AR</a><br><a href='/usa/13/1367284/distance.htm'>Roswell,&nbsp;GA</a><br><a href='/usa/13/1369000/distance.htm'>Savannah,&nbsp;GA</a><br><a href='/usa/12/1270600/distance.htm'>Tallahassee,&nbsp;FL</a><br><a href='/usa/01/0177256/distance.htm'>Tuscaloosa,&nbsp;AL</a><br><br></font></td>

