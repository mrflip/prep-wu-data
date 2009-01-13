#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'

require 'hadoop'
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/json_model'   ; include TwitterFriends::JsonModel

# rsrc=public_timeline ;
# hdp-rm -r fixd/$rsrc
# ./parse_json.rb --go --public_timeline rawd/bundled/$rsrc fixd/$rsrc/


#
#
# We only extract
# * user, user_partial, user_profile, and user_style;
# * tweet
# * a_follows_b, a_favorites_b
#
# All of the derived objects -- replies, @atsigns, hashtags, etc -- are done in
# the grokify pass.
#
module ParseJson
  class Mapper < Hadoop::Streamer
    PARSER_FOR_CONTEXT = {
      'user'            => UserParser,
      'followers'       => FriendsFollowersParser,
      'friends'         => FriendsFollowersParser,
      'favorites'       => FriendsFollowersParser,
      'timeline'        => PublicTimelineParser,
      'public_timeline' => PublicTimelineParser,
    }
    # user:     context, scraped_at, user_id,        page, screen_name, json_str
    # f/f/f:    context, scraped_at, owning_user_id, page, screen_name, json_str
    # p_t:      context, scraped_at, identifier,     page, moreinfo,    json_str

    def process context, scraped_at, identifier, page, moreinfo, json_str
      return if context =~ /^bogus-/
      parsed = PARSER_FOR_CONTEXT[context].new_from_json(json_str, context, scraped_at, identifier, page, moreinfo)
      unless parsed && parsed.healthy?  then bad_record!(context, scraped_at, identifier, page, moreinfo, json_str); return ; end
      #
      # output
      #
      parsed.each do |obj|
        puts obj.output_form
      end
    end
  end

  class Reducer < Hadoop::UniqByLastReducer
    # #
    # # constantizing the classes, etc took macroscopic time (yup)
    # # and I don't feel like thinking so we'll be non-DRY. Careful!
    # NUM_KEY_FIELDS = {
    #   :hashtag => 2, :tweet_url => 2,
    #   :a_follows_b  => 2,
    #   :a_replies_b  => 3, :a_atsigns_b => 3, :a_favorites_b => 3, :a_retweets_b => 3,
    #   :tweet        => 1,
    #   :twitter_user => 1, :twitter_user_profile => 1, :twitter_user_style => 1,
    #   :twitter_user_partial => 1,
    #   }
    #
    # def get_key klass_name, *vals
    #   resource = klass_name.gsub(/-.*/, '').to_sym
    #   num_key_fields = NUM_KEY_FIELDS[resource] or raise  "Oops, forgot to say how many keys in #{klass_name}"
    #   [klass_name] + vals[0..(num_key_fields-1)]
    # end

    def get_key item_key, *vals
      item_key
    end
    # attr_accessor :class_num_key_fields_hsh
    # #
    # # Memoize number of key fields for this class
    # #
    # def class_num_key_fields klass_name
    #   return class_num_key_fields_hsh[klass_name] if (class_num_key_fields_hsh||={})[klass_name]
    #   klass = self.class.class_from_resource(klass_name)
    #   if klass && klass.respond_to?(:num_key_fields)
    #     class_num_key_fields_hsh[klass_name] = klass.num_key_fields
    #   else
    #     class_num_key_fields_hsh[klass_name] = -1
    #   end
    # end
  end

  #
  # using UniqByLastReducer
  #
  # class UniqWithoutScrapedAt < Hadoop::Streamer
  #   attr_accessor :records, :last_val
  #
  #   def reset!
  #     self.records = []
  #   end
  #
  #   def comparable resource, key, scraped_at, *rest
  #     if mutable(resource, key, scraped_at, *rest)
  #       [resource, key, *rest]
  #     else
  #       [resource, key, scraped_at, *rest]
  #     end
  #   end
  #
  #   def process *record
  #     # find values without
  #     val = comparable(*record)
  #     return if val == self.last_val
  #     puts record.join("\t")
  #     self.last_val = val
  #   end
  # end

  class Script < Hadoop::Script
    # def initialize
    #   process_argv!
    #   case
    #   when options[:user]                           then self.mapper_klass = ParseJson::UserMapper
    #   when options[:friends] || options[:followers] then self.mapper_klass = ParseJson::FriendsFollowersMapper
    #   when options[:favorites]                      then self.mapper_klass = ParseJson::FriendsFollowersMapper
    #   when options[:public_timeline]                then self.mapper_klass = ParseJson::PublicTimelineMapper
    #   else raise "Need to know what I'm parsing: --user, --public_timeline, --followers, ..."
    #   end
    #   # self.reducer_klass = UniqWithoutScrapedAt
    #   self.reducer_klass = ParseJson::Reducer
    # end

    #
    # Sort on <resource   id      scraped_at> (harmlessly using an extra field on immutable rows)
    #
    def sort_fields
      4
    end
  end
end

#
# Executes the script
#
ParseJson::Script.new(ParseJson::Mapper, ParseJson::Reducer).run
