
#
# wget url_to_get, ripd_file, sleep_time
#
# Crudely scrape a url
#
# get the url
# leave a 0-byte turd on failure to prevent re-fetching; use find ripd/ -size 0 --exec rm {} \; to scrub
# sleeps for sleep_time
#
def wget rip_url, ripd_file, sleep_time=1
  cd path_to(:ripd_root) do
    mkdir_p   File.dirname(ripd_file)
    if File.exists?(ripd_file)
      puts "Skipping #{rip_url}"
    else
      print `wget -nv --timeout=8 --http-user=#{TWITTER_USERNAME} --http-passwd=#{TWITTER_PASSWD} -O'#{ripd_file}' '#{rip_url}' `
      # puts "(sleeping #{sleep_time})" ;
      sleep sleep_time
    end
    success = File.exists?(ripd_file) && (File.size(ripd_file) != 0)
    return success
  end
end
