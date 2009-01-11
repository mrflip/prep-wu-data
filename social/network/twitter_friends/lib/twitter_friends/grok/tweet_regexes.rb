module TwitterFriends
  module Grok
    module TweetRegexes
      # ===========================================================================
      #
      # Twitter accepts URLs somewhat idiosyncratically, probably for good reason --
      # we rarely see ()![] in urls; more likely in a status they are punctuation.
      #
      # This is what I've reverse engineered.
      #
      #
      # Notes:
      #
      # * is.gd uses a trailing '-' (to indicate 'preview mode'): clever.
      # * pastoid.com uses a trailing '+', and idek.net a trailing ~ for no reason. annoying.
      # * http://www.5irecipe.cn/recipe_content/2307/'/
      #
      # http://www.facebook.com/groups.php?id=1347199977&gv=12#/group.php?gid=18183539495
      #
      RE_DOMAIN_HEAD     = '(?:[a-zA-Z0-9\-]+\.)+'
      RE_DOMAIN_TLD      = '(?:com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|[a-zA-Z]{2})'
      RE_URL_SCHEME      = '[a-zA-Z][a-zA-Z0-9\-\+\.]+'
      RE_URL_UNRESERVED  = 'a-zA-Z0-9'   + '\-\._~'
      RE_URL_OKCHARS     = RE_URL_UNRESERVED + '\'\+\,\;=' + '/%:@'   # not !$&()* [] \|
      RE_URL_QUERYCHARS  = RE_URL_OKCHARS    + '&='
      RE_URL_HOSTPART    = "#{RE_URL_SCHEME}://#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}"
      RE_URL             = %r{(
                #{RE_URL_HOSTPART}                   # Host
     (?:(?: \/ [#{RE_URL_OKCHARS}]+?          )*?    # path:  / delimited path segments
        (?: \/ [#{RE_URL_OKCHARS}]*[\w\-\+\~] )      #        where the last one ends in a non-punctuation.
       |                                             #        ... or no path segment
                                              )\/?   #        with an optional trailing slash
        (?: \? [#{RE_URL_QUERYCHARS}]+  )?           # query: introduced by a ?, with &foo= delimited segments
        (?: \# [#{RE_URL_OKCHARS}]+     )?           # frag:  introduced by a #
      )}x


      # ===========================================================================
      #
      # A hash following a non-alphanum_ (or at the start of the line
      # followed by (any number of alpha, num, -_.+:=) and ending in an alphanum_
      #
      # This is overly generous to those dorky triple tags (geo:lat=69.3), but we'll soldier on somehow.
      #
      RE_HASHTAGS        = %r{(?:^|\W)\#([a-zA-Z0-9\-_\.+:=]+\w)(?:\W|$)}

      # ===========================================================================
      #
      # Retweets and Retweet Whores
      #
      # See ARetweetsB for more info.
      #
      # A retweet 
      #   RT @interesting_user Something so witty Dorothy Parker would just give up
      #   Oh yeah and so's your mom (via @sixth_grader)
      #   retweeting @ogre: KEGGER TONITE RT pls
      #     ^^^ this is not a rtwhore; it matches first as a retweet
      #
      # and rtwhores 
      #   retweet please: Hey here's something I'm whoring xxx
      #   KEGGER TONITE RT pls
      # 
      # or semantically-incorrect matches such as (actual example):
      #    @somebody lol, love the 'please retweet' ending!
      # 
      # Things that don't match:
      #   retweet is silly, @i_think_youre_dumb
      #    misspell the name of my Sony Via
      #
      RE_RETWEET_WORDS  = 'RT|retweet|retweeting'
      RE_RETWEET_ONLY   = %r{(?:#{RE_RETWEET_WORDS})}
      RE_RETWEET_OR_VIA = %r{(?:#{RE_RETWEET_WORDS}|via)}
      RE_PLEASE         = %r{(?:please|plz|pls)}
      RE_RETWEET        = %r{\b#{RE_RETWEET_OR_VIA}\W*@(\w+)\b}i
      RE_RTWHORE        = %r{
          \b#{RE_RETWEET_ONLY}\W*#{RE_PLEASE}\b
        | \b#{RE_PLEASE}\W*#{RE_RETWEET_ONLY}\b}ix

      # ===========================================================================
      #
      # following either the start of the line, or a non-alphanum_ character
      # the string of following [a-zA-Z0-9_]
      #
      # Note carefully: we _demand_ a preceding character (or start of line):
      # \b would match email@address.com, which we don't want.
      #
      # Making an exception for RT@im_cramped_for_space.
      #
      # All retweets 
      # 
      RE_ATSIGNS         = %r{(?:^|\W|#{RE_RETWEET_OR_VIA})@(\w+)\b}
    end
  end
end
