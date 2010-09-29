#!/usr/bin/env ruby

require 'rubygems'
require 'swineherd/r_script' ; include Swineherd

src  = File.join('templates', 'frequency_distribution.r.erb')
opts = {
  
}

RScript.new(src, opts).run
