#!/usr/bin/env ruby
require 'imw/utils'
require 'twitter_names_model'
include IMW; IMW.verbose = true
as_dset __FILE__

#
# read
#
file_in  = [:fixd, 'stats/twitter_names.yaml']
names    = DataSet.load(file_in){ |data| data[:names] }

#
# write
#
names.report(1)
names.hist(1).dump [:fixd, 'stats/twitter_hist.yaml']

announce "done."

