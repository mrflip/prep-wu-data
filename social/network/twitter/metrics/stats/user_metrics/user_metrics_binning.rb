
require 'wukong/datatypes/enum'; include Wukong::Datatypes
class FoBin           < Binned    ; enumerates 0, 0, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10_000, 20_000, Infinity ;end
class FrBin           < FoBin     ; end
class NbhdSizeBin     < FoBin     ; end

class TwDayBin       < Binned    ;
  MO = 30.4368499
  WK =  7.0
  enumerates(* (
    [-Infinity, 1.0 / MO, 2.0 / MO,   1 / WK, ] +
    (-2 .. 9).map{|i| octave3(i + 0.5) } +
    [Infinity]))
  self.names = (
    ['<    1/mo', '   1-2/mo', '     2/mo-1/wk', '   1-2/wk', '~    4/wk' ] +
    [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000].map{|i| "~ %4d/day"%i } +
    ['> 1500/day'])
end
class TwDayRecentBin < TwDayBin ; end

# <    1/mo                                       0.032854911177914
#      1-2/mo                                     0.065709822355828
#      2/mo-1/wk                                  0.142857142857143
#      1-2/wk                                     0.316227766016838
# ~    4/wk                                       0.630957344480193
# ~    1/day                                      1.58489319246111
# ~    2/day                                      3.16227766016838
# ~    5/day                                      6.30957344480193
# ~   10/day                                      15.8489319246111
# ~   20/day                                      31.6227766016838
# ~   50/day                                      63.0957344480193
# ~  100/day                                      158.489319246111
# ~  200/day                                      316.227766016838
# ~  500/day                                      630.957344480193
# ~ 1000/day                                      1584.89319246111
# > 1500/day                                      Infinity

class NbhdBalBin      < Binned
  enumerates(* ([-Infinity] + ( (0..15).map{|n| (0.125+(n.to_f/20))} ) + [Infinity]) )
  self.names = (
    ['Few followers'] + (0..14).map{|n| (15+(5*n)) } + ['Mostly Followers'])
  self.names[8] = 'Balanced'
end



# class UserMetrics
#       # 43
#       [:fo_bin,             FoBin      , "# Followers grp"                                       ],
#       [:fr_bin,             FrBin      , "# Friends grp"                                         ],
#       [:nbhd_size_bin,      NbhdSizeBin    , "Neighborhood Size grp"                             ],
#       [:nbhd_bal_bin,       NbhdBalBin     , "Neighborhood Balance grp"                          ],
#       [:tw_day_bin,        TwDayBin      , "Tweets / day grp (*)"                                ],
#       [:tw_day_recent_bin, TwDayRecentBin      , "Recent Tweets / day grp (*)"                   ],
#
    # def fix!
    #   get_tw_day_bin
    #   get_tw_day_recent_bin
    #   get_fo_bin
    #   get_fr_bin
    #   get_nbhd_size_bin
    #   get_nbhd_bal_bin
    #   get_active
    # end


    # #
    # # Bins
    # #
    # def get_fo_bin()        self.fo_bin        = FoBin[fo]   end
    # def get_fr_bin()        self.fr_bin        = FrBin[fr]   end
    # def get_nbhd_size_bin() self.nbhd_size_bin = NbhdSizeBin[nbhd_size]  end
    # def get_nbhd_bal_bin()  self.nbhd_bal_bin  = NbhdBalBin[nbhd_bal]    end
    # def get_tw_day_bin()    self.tw_day_bin    = TwDayBin[tw_day]      end
    # def get_tw_day_recent_bin()  self.tw_day_recent_bin  = TwDayRecentBin[tw_day_recent]   end
#
# end
