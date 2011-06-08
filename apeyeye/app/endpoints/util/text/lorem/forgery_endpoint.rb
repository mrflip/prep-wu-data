module Util
  module Text
    module Lorem
      class ForgeryEndpoint < Endpoint

        #
        handles('paragraph') do |params, app, responder|
          require 'forgery'
          quantity = params.paragraphs || 2
          begin
            text = Forgery::LoremIpsum.paragraphs(quantity, params.forgery_options)
          rescue StandardError => e
            raise Apeyeye::MethodFailedError, e.to_s, e.backtrace
          end

          responder.new({
              :text => text,
            })
        end

      end

      class ParagraphParams < Icss::MetaType
        def forgery_options
          forgery_options = {
            :sentences => sentences,
            :wrap => { :start => (beg_wrap||""), :end => (end_wrap||"") },
          }.compact_blank!
        end
      end

    end
  end
end
