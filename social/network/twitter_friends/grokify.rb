#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'

require 'hadoop'                       ; include Hadoop
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/grok/grok_tweets'

#
# See bundle.sh for running pattern
#

module Grokify
  class Mapper < Hadoop::StructStreamer
    #
    #
    def process thing
      return unless thing.is_a?(Tweet)
      thing.text_elements.each do |text_element|
        puts text_element.output_form
      end
    end

    #
    # Skip bogus records
    #
    def itemize line
      return if line =~ /^(?:bogus|bad_record)/
      super line
    end
  end

  class Script < Hadoop::Script
    def reduce_command
      '/usr/bin/uniq'
    end
  end
end

#
# Executes the script
#
Grokify::Script.new(Grokify::Mapper, nil).run
