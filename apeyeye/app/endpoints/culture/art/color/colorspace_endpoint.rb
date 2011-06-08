module Culture
  module Art
    module Color
      class ColorspaceEndpoint < Endpoint

        handles('from_cmyk') do |params, app, responder|
        end

        handles('from_css') do |params, app, responder|
          responder.new({})
        end

        handles('from_grayscale') do |params, app, responder|
        end

        handles('from_hsl') do |params, app, responder|
        end

        handles('from_lab_star') do |params, app, responder|
        end

        # @param base: default 1
        handles('from_rgb') do |params, app, responder|
        end

        handles('from_yiq') do |params, app, responder|
        end

        handles('from_named') do |params, app, responder|
        end

        class << self
          def color_response color
            rgb  = color.to_rgb
            hsl  = color.to_hsl
            cmyk = color.to_cmyk
            yiq  = color.to_yiq
            gray = color.to_grayscale
            #
            Culture::Art::Color::Colorspace.new({
                :rgb_red        => rgb.r,
                :rgb_green      => rgb.g,
                :rgb_blue       => rgb.b,
                #
                :hsl_hue        => hsl.h,
                :hsl_hue_deg    => hsl.hue,
                :hsl_saturation => hsl.s,
                :hsl_lightness  => hsl.l,
                #
                :cmyk_cyan      => cmyk.c,
                :cmyk_yellow    => cmyk.m,
                :cmyk_magenta   => cmyk.y,
                :cmyk_black     => cmyk.k,
                #
                :yiq_y          => yiq.y,
                :yiq_i          => yiq.i,
                :yiq_q          => yiq.q,
                #
                :grayscale_gray => gray.g,
                #
                # :std_brightness => color.brightness,
                # :w3c_brightness => w3c_brightness,
                #
                :rgb_hex        => rgb.html,
                :rgb_str        => (has_alpha ? color.css_rgba : color.css_rgb ),
                :hsl_str        => (has_alpha ? color.css_hsla : color.css_hsl ),
                #
                # :closest_name   => x,
              })
          end
        end

      end
    end
  end
end

