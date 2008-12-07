#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils' ; include FileUtils

# to%3Auser
PUBLIC_URL = "http://twitter.com/statuses/public_timeline.json"
TRENDS_URL = "http://search.twitter.com/trends.json"
SEARCH_URL = "http://search.twitter.com/search.atom?q=point+spread&rpp=100" # &since_id=
POOLPATH = "social/network/twitter_friends/public_timeline"
DATADIR  = "/data/rawd/${poolpath}"
LOGDIR   = "/data/log/${poolpath}"
WAITTIME = 30
TERMS = %w[
    drunk party bored carburetor
    osx ubuntu ruby+rails warcraft photon dissertation thesis
    yankees red+sox defensive+line point+spread
    intelligent eyeliner ferragamo knitting britney+spears
    prayed church school
    mortgage rent insurance prius babysitter pokemon lol
    seo
    ]

class PollWatcher
end


def logfile
  "%s/%s" % [LOGDIR, Time.now.strftime('%Y%m/%d/%H/twitter_public_timeline-%Y%m%d.log')]
end
def datedir
  "%s/%s" % [DATADIR, Time.now.strftime('%Y%m/%d/%H')]
end
def destfile token
    Time.now.strftime('%Y%m%d-%H%M%S')
end

mkdir_p LOGDIR
mkdir_p DATADIR
cd      DATADIR
while true
  mkdir_p File.dirname(logfile)
  mkdir_p File.dirname(destfile)
  [ ['statuses/public_timeline.json',   'public_timeline']
    ['statuses/trends.json',            'public_timeline']
  ]
    `wget -nc -nv -a #{logfile} #{twitter_url('public')} -O $datedir/public_timeline-$datetime.json
    wget -nc -nv -a $logname $trends_url -O $datedir/trends-$datetime.json
    sleep $waittime
    true
end
