#!/usr/bin/env ruby 
require 'imw'
$VERBOSE=false 
$imw = IMW.new('sport','golf','course_handicaps_usga')

require 'hpricot'
Hpricot.buffer_size = 262144 # huge for less of the overflow fail

class IMW
  def logfile(task)
    log_dir       = path_to(:rawd)
    log_datestamp = Time.now.strftime("%Y%m%d")
    "%s/%s-%s-%s.log" % [log_dir, pool, task, log_datestamp]
  end


  def wget(url)
    puts "Fetching #{url}"
    delay = 5
    sh %{ wget -x --no-clobber --no-parent --no-verbose -a #{logfile("wget")} --wait=#{delay} #{url} }
    sleep delay
  end

  def wget_robots_txt(url)
    url = url.gsub(%r{(http://[^/]+)(?:/.*)?}, '\1/robots.txt') #'
    wget(url) rescue true
  end
  
  
end

# baseurl = "http://golf.sports.yahoo.com/tracker/763582/submitscore?course="
# Dir.chdir($imw.path_to(:ripd)) do
#   $imw.wget_robots_txt baseurl
#   max_course_num = 5 # 6612
#   (1..max_course_num).each do |course_num|
#     $imw.wget baseurl+("%04d" % [course_num])
#   end
# end

def state_filename(state)
  $imw.path_to(:rawd, 'states', "state-%s" % [state])
end

def state_list()
  states = %w{ CA AK AL AR AZ BR CO CT DC DE FL GA GU HI IA ID IL IN KS KY LA MA
  MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT
  VA VT WA WI WV WY } 
end

def scrape_states()
  require 'scrubyt'
  golf_ex = { }
  state_list.each do |state|
    golf_ex = Scrubyt::Extractor.define do
      puts "Getting #{state}"
      fetch 'http://63.240.106.223/natcrsrating/ncrlisting.aspx'
      select_option 'ddState', state
      submit
      
      club_list "//table[@id='grdCourses']" do
        club "/tr" do
          club_name     "/td[1]"
          course_name   "/td[2]"
          course_url    "href", :type => :attribute
          course_city   "/td[3]"
          course_state  "/td[4]"
        end
      end
    end # extractor
    #
    # Write data out
    mkdir_p File.dirname(state_filename(state))
    File.open(state_filename(state)+".yaml", 'wb') do |f|
      f << golf_ex.to_hash.to_yaml
    end      
    File.open(state_filename(state)+".xml", 'wb') do |f|
      f << golf_ex.to_xml
    end
  end

end


def scrape_courses()
  state_list.each do |state|
    state_courseinfo = Hash.from_xml(File.open("rawd/states/state-#{state}.xml"))
    
    state_courseinfo[0].map{|c| c.course.url}.each do |url|
      puts url
      Dir.chdir($imw.path_to(:ripd)) do
        $imw.wget(url)
      end
      
    end
    
  end
end

#scrape_states()
scrape_courses()

# ripd_course_filename = 'ripd/63.240.106.223/natcrsrating/courseTeeInfo.aspx?assocID=469&crsCourseID=9007'
# doc = Hpricot(File.open(ripd_course_filename))
# 
# cells_table = (doc/"//td[@id='contentarea']/div/table").map do |table|
#   (table/"//tr").map do |row|
#     (row/"/td").map do |cell| cell.inner_text.to_s end
#   end
# end
# puts cells_table.to_yaml  
