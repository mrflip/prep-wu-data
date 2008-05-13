#!/usr/bin/env ruby

$rm_url         = 'http://www.randmcnally.com/rmc/directions/dirGetMileage.jsp?cmty=0'
$rm_session_id  = '%40%40%40%401587532762.1205914725%40%40%40%40'
$rm_engine_id   = 'ccceadedilediklcefecggfdffhdghh.0'

def pack_address(what, vals)  
  fields = %w{Address City State Zip}
  fields.zip(vals).map{ |f,v| "&txt%s%s=%s" % [what, f, v||''] }
end

puts 'wget %s -O - 


#!/usr/bin/env ruby
# http://www.randmcnally.com/rmc/directions/dirGetMileage.jsp?cmty=0
# ?BV_SessionID=%40%40%40%401587532762.1205914725%40%40%40%40
# &BV_EngineID=ccceadedilediklcefecggfdffhdghh.0
# &txtStartAddress=
# &txtStartCity=
# &txtStartState=
# &txtStartZip=78705
# &txtDestAddress=
# &txtDestCity=
# &txtDestState=
# &txtDestZip=20815

# 3:32:13.544[1041ms][total 1041ms] Status: 200[OK]
# POST http://www.randmcnally.com/rmc/directions/dirGetMileage.jsp?cmty=0 Load Flags[LOAD_FROM_CACHE  LOAD_BYPASS_LOCAL_CACHE_IF_BUSY ] Content Size[-1] Mime Type[text/html]
#    Request Headers:
#       Host[www.randmcnally.com]
#       User-Agent[Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b4) Gecko/2008030317 Firefox/3.0b4]
#       Accept[text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8]
#       Accept-Language[en-us,en;q=0.5]
#       Accept-Encoding[gzip,deflate]
#       Accept-Charset[ISO-8859-1,utf-8;q=0.7,*;q=0.7]
#       Keep-Alive[300]
#       Connection[keep-alive]
#    Post Data:
#       BV_SessionID[%40%40%40%401587532762.1205914725%40%40%40%40]
#       BV_EngineID[ccceadedilediklcefecggfdffhdghh.0]
#       txtStartAddress[]
#       txtStartCity[]
#       txtStartState[]
#       txtStartZip[78705]
#       txtDestAddress[]
#       txtDestCity[]
#       txtDestState[]
#       txtDestZip[20815]
#    Response Headers:
#       Server[Sun-ONE-Web-Server/6.1]
#       Date[Wed, 19 Mar 2008 08:32:40 GMT]
#       Content-Type[text/html]
#       Cache-Control[private]
#       Set-Cookie[BV_IDS=ccceadedilediklcefecggfdffhdghh.0:@@@@1587532762.1205914725@@@@; path=/rmc]
#       Content-Encoding[gzip]
#       Vary[accept-encoding]
#       Transfer-Encoding[chunked]
#
# cookie is optional; first part is the EngineID, 2nd part is the SessionID
# BV_IDS=ccceadedilediklcefecggfdffhdghh.0:@@@@1587532762.1205914725@@@@
#
