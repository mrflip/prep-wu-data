class MultiEdge < TypedStruct.new(
    [:user_a_id,   Integer],
    [:user_b_id,   Integer],
    [:a_follows_b, Integer],
    [:b_follows_a, Integer],
    [:at_o,        Integer],
    [:at_i,        Integer],
    [:re_o,        Integer],
    [:re_i,        Integer],
    [:rt_o,        Integer],
    [:rt_i,        Integer]    
    )

  #  
  # My Wild-Assed-Guess for strong link score
  # where
  #   AT_sy_bool    1 if at_i > 0 && at_o > 0
  #   FO_sy            1 if fo_i and fo_o
  # 
  # we do strong links as
  #   1.0 * FO_o + 0.2 * FO_sy + 1.0 * sqrt(AT_o) + 0.5 * sqrt(RT_o) + 0.25 * AT_sy_bool
  # and strong-links-minus-reciprocation
  #   1.0 * FO_o +                        1.0 * sqrt(AT_o) + 0.5 * sqrt(RT_o)
  # 
  # flip
  #
  #  
  def weight
    1.0*a_follows_b.to_f + 0.2*fo_sy + 1.0*Math.sqrt(at_o.to_f) + 0.5*Math.sqrt(rt_o.to_f) + 0.25*at_sy
  end

  #
  # Mutually following
  #
  def fo_sy
    return 1.0 if (a_follows_b.to_i == 1) && (b_follows_a.to_i == 1)
    0.0
  end

  #
  # A <3 B
  #
  def at_sy
    return 1.0 if (at_o.to_i > 0) && (at_i.to_i > 0)
    0.0
  end
  
end
