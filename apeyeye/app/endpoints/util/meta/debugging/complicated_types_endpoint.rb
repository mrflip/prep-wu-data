module Util
  module Meta
    module Debugging
      class ComplicatedTypesEndpoint < Endpoint

        #
        handles('parse') do |params, app, responder|
          require 'chronic'
          begin
            time_str    = params[:time_str]
            chronic_hsh = params.slice(:context, :ambiguous_time_range, :now).compact_blank!
            time        = Chronic.parse(time_str, chronic_hsh)
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
              :params          => params.to_hash,
              :my_array_of_string => [":hi","there","friend",3],
              :my_array_of_ints   => [1, 2, 3, 3, 0],
              :my_embedded_record => { :name => 'bob' },
              :my_map_of_records  => { :a => { :label => 'label_a' }, :b => { :label => 'label_b' } },
              :my_enum_field      => 'B',
              :my_fixed_field     => "1863993055d7dbec910ff800c5b809fc",
              :my_complex_record  => { :label => 'bob' },
              :errors => [e].compact,
            })
        end

      end
    end
  end
end
