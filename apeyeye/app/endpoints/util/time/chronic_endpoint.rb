module Util
  module Time
    class ChronicEndpoint < Endpoint

      #
      handles('parse') do |params, app, responder|
        require 'chronic'
        begin
          time_str    = params[:time_str]
          chronic_hsh = params.slice(:context, :ambiguous_time_range, :now).compact_blank!
          time = Chronic.parse(time_str, chronic_hsh)
          unless time.nil?
            time          = time.utc
            iso_time      = time.utc.iso8601
            epoch_seconds = time.to_i
          end
        rescue StandardError => e
          raise Apeyeye::MethodFailedError, e.to_s, e.backtrace
        end
        responder.new({
            :time          => iso_time,
            :epoch_seconds => epoch_seconds,
        })
      end

    end
  end
end
