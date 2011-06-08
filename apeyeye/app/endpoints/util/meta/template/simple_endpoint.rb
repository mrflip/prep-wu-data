module Util
  module Meta
    module Template

      #
      # replace:
      # * util.meta.template    with your namespace
      # * simple                with your protocol name
      # * my_msg                with your message name
      #
      # In the _endpoint.rb, replace:
      # * util, meta, template  in the module part at top with your cat/subcat/family names
      # * simple                with your protocol name
      # * my_msg                with your message name
      #

      class SimpleEndpoint < Endpoint

        #
        # Describe: http://127.0.0.1:9393/describe/util/meta/template/simple/my_msg
        # Call:     http://127.0.0.1:9393/util/meta/template/simple/my_msg
        #
        handles('my_msg') do |params, endpoint, responder|
          require 'chronic'
          p params
          chronic_hsh = params.slice(:context, :ambiguous_time_range, :now)
          begin
            time = Chronic.parse(params[:time_str], chronic_hsh)
            time = time.utc unless time.nil?
          rescue StandardError => e
            error = e
          end
          hsh = {
              :time => time, :epoch_seconds => time.to_i,
              :params => params.to_hash,
              :errors => [e].compact,
              :debug => [
                response_obj('my_msg', {}),
                namespace,
                protocol.to_hash,
            ] }
          # resp_as_obj = response_obj('my_msg', hsh) # uncomment this (instead of hsh) to send an obj back
          hsh
        end

        # ---------------------------------------------------------------------------
        #
        # below this is generic code that will be replaced

        prepares('my_msg') do |params|
          params_obj 'my_msg', params
        end

        finalizes('my_msg') do |result|
          result.delete(:errors) if result[:errors].blank?
          result.to_json
        end

      end
    end
  end
end
