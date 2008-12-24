#!/usr/bin/env ruby
require 'optiflag'

# Title:  Help flag can be used for a specific flag.
#  Description:  The normal help flag can be used with a parameter so that you can get more information on any of the particular flags.
module Options extend OptiFlagSet
  optional_flag("field_numbers"){ description "" }
  usage_flag "h","help","?"
end

# ruby -e 'puts [0..2,4..6,9].inject([]){|sum,r| sum + r.to_a} '
