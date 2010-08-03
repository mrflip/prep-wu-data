require 'json'
module GeoIPCensus
  RawIPCensus = TypedStruct.new(
    [:zip_code,               String ],
    [:country_code,           String ],
    [:region_code,            String ],
    [:city,                   String ],
    [:latitude,               Float  ],
    [:longitude,              Float  ],
    [:area_code,              String ],
    [:metro_code,             String ],
    [:logical_record_number,  String ],
    [:population,             Bignum ],
    [:percent_under_5,        Float  ],
    [:percent_under_18,       Float  ],
    [:percent_over_65,        Float  ],
    [:percent_female,         Float  ],
    [:percent_white,          Float  ],
    [:percent_black,          Float  ],
    [:percent_native,         Float  ],
    [:percent_asian,          Float  ],
    [:percent_pacific,        Float  ],
    [:percent_dual_race,      Float  ],
    [:percent_hispanic,       Float  ],
    [:percent_semi_permanent, Float  ],
    [:percent_foreign,        Float  ],
    [:percent_non_english,    Float  ],
    [:percent_hs_graduate,    Float  ],
    [:percent_bs_graduate,    Float  ],
    [:work_travel_time,       Float  ], # minutes
    [:housing_units,          Integer],
    [:percent_homeownership,  Float  ],
    [:housing_unit_value,     Float  ],
    [:households,             Integer],
    [:people_per_household,   Float  ],
    [:household_income,       Float  ],
    [:per_capita_income,      Float  ],
    [:percent_below_poverty,  Float  ]
    )
  RawIPCensus.class_eval do

    def to_hash *args
      hsh = super(*args)
      hsh.delete('logical_record_number')
      hsh
    end
  end


  class IpBlock
    attr_accessor :bot_ip, :top_ip
    attr_accessor :census_record
    def initialize bot_ip, top_ip, census_record
      self.bot_ip, self.top_ip = [bot_ip.to_i, top_ip.to_i]
      self.census_record = census_record
    end

    #
    # Generates ip blocks that lie entirely within a /24 range.
    #
    # yields a series of tuples
    #    [ip_head, bot_ip_tail, top_ip_tail]
    # ip_head is the first three octets in a ip/24 block
    # the block starts at bot_ip_0 and ends at top_ip_0 (inclusive)
    #
    def ip_24_blocks
      bot_head, bot_tail = split_ip(bot_ip)
      top_head, top_tail = split_ip(top_ip)

      if bot_head < top_head
        yield [bot_head, bot_tail, 255]
        bot_head += 1
        bot_tail  = 0
      end
      (bot_head ... top_head).each do |seg|
        yield [seg, 0, 255]
      end
      yield [top_head, bot_tail, top_tail]
    end

    def split_ip ip
      ip_head = ip / 2**8
      ip_tail = ip % 2**8
      [ip_head, ip_tail]
    end
  end

end

