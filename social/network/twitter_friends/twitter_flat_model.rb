include HadoopUtils

TwitterUserPartial  = HadoopStruct.new( [:id],  :id,  :screen_name, :followers_count, :protected, :name,
                                                :url, :location, :description, :profile_image_url )
TwitterUser         = HadoopStruct.new( [:id],  :id,  :screen_name, :created_at, :statuses_count,
                                                :followers_count, :friends_count, :favourites_count, :protected )
TwitterUserProfile  = HadoopStruct.new( [:id],  :id,  :name, :url, :location, :description, :time_zone, :utc_offset )
TwitterUserStyle    = HadoopStruct.new( [:id],  :id,  :profile_background_color, :profile_text_color, :profile_link_color,
                                                :profile_sidebar_border_color, :profile_sidebar_fill_color,
                                                :profile_background_image_url, :profile_image_url, :profile_background_tile )
AFollowsB           = HadoopStruct.new( [:user_a_id, :user_b_id],               :user_a_id, :user_b_id  )
ARepliedB           = HadoopStruct.new( [:user_a_id, :user_b_id,   :status_id], :user_a_id, :user_b_id, :user_a_name,               :status_id, :in_reply_to_status_id )
AAtsignsB           = HadoopStruct.new( [:user_a_id, :user_b_name, :status_id], :user_a_id,             :user_a_name, :user_b_name, :status_id )
Hashtag             = HadoopStruct.new( [:user_a_id, :hashtag],   :user_a_id,  :hashtag,   :status_id )
TweetUrl            = HadoopStruct.new( [:user_a_id, :tweet_url], :user_a_id,  :tweet_url, :status_id )
Tweet               = HadoopStruct.new( [:id],  :id,  :created_at, :twitter_user_id, :text, :favorited, :truncated, :tweet_len,
                                                :in_reply_to_user_id, :in_reply_to_status_id, :fromsource, :fromsource_url,
                                                :all_atsigns, :all_hash_tags, :all_tweeted_urls )
# UserMetric   = HadoopStruct.new( :id,  :replied_to_count, :tweeturls_count, :hashtags_count, :prestige, :pagerank, :twoosh_count )

# spread the hash a bit but still make a total ordering easy
Tweet.class_eval                do ; def resource() ; super() + '-' + self.id[-2..-1] ; end ; end
TwitterUserPartial.class_eval   do ; def resource() ; super() + '-' + self.screen_name[0..0].downcase ; end ; end
AFollowsB.class_eval            do ; def resource() ; super() + '-' + self.user_a_name[0..0].downcase ; end ; end

