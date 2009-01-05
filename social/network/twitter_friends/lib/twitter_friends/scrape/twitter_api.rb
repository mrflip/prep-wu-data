module TwitterApi
  #
  # The URI for a given resource
  #
  def uri
    "http://twitter.com/#{resource_path}/#{identifier}.json?page=#{page}"
  end
  # Regular expression to grok resource from uri
  GROK_URI_RE = %r{http://twitter.com/(\w+/\w+)/(\w+)\.json\?page=(\d+)}

  # Context <=> resource mapping
  #
  # aka. repairing the non-REST uri's
  RESOURCE_PATH_FROM_CONTEXT = {
    :user            => 'users/show',
    :followers       => 'statuses/followers',
    :friends         => 'statuses/friends',
    :favorites       => 'favorites',
    :timeline        => 'statuses/user_timeline',
    :public_timeline => 'statuses'
  }
  # Get url resource for context
  def resource_path
    RESOURCE_PATH_FROM_CONTEXT[context]
  end

  module ClassMethods
    # Get context from url resource
    def context_for_resource(resource)
      RESOURCE_PATH_FROM_CONTEXT.invert[resource]
    end

  end

  def self.included base
    base.extend ClassMethods
  end
end
