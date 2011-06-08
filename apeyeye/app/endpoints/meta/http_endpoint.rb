module Meta
  class HttpEndpoint < Endpoint

    # @example compare
    #   http://127.0.0.1:9393/meta/http/request_info.xml?hi=there
    #   http://127.0.0.1:9393/meta/http/request_info.json?hi=there
    #
    handles('request_info', :skip_params => true) do |params, app, responder|
      hsh = {
        :params               => params,
        :accept_media_types   => app.request.accept_media_types,
        :prefered_media_type  => app.request.accept_media_types.prefered,
      }
      # stuff in info from rack env
      [:path_info, :query_string, :request_method,
        :http_connection, :http_user_agent,
        :http_accept, :http_accept_encoding, :http_accept_charset,
      ].each{|env_attr| hsh[env_attr] = app.env[env_attr.to_s.upcase] }

      responder.new(hsh)
    end

  end

end
