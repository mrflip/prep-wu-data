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

end

