
REMAP_HEADS = {
  ["ai~*",           "Uncl"]      => ["be",         "Uncl"],    #!!
  ["ai~*",           "Verb"]      => ["be",         "Verb"],
  ["in~*",           "Verb"]      => ["isn't",      "Verb"],

  ["du~*",           "Verb"]      => ["do",         "Verb"],    # 4
  ["dun~",           "Verb"]      => ["do",         "Verb"],    # 2_2
  ["ca~",            "VMod"]      => ["can",        "VMod"],    # $
  ["sha~",           "VMod"]      => ["shall",      "VMod"],    # 4
  ["wan~",           "Verb"]      => ["want",       "Verb"],    # 4
  ["wo~",            "VMod"]      => ["will",       "VMod"],    # 4 3
  ["~n't",           "Neg"]       => ["not",        "Neg"],     # 4
  ["~na*",           "Inf"]       => ["to",         "Inf"],     # 4
  ["~na~*",          "Inf"]       => ["to",         "Inf"],     # 4
  ["~no*",           "Verb"]      => ["know",       "Verb"],    # 4
  ["~n~*",           "Neg"]       => ["not",        "Neg"],     # 4
  ["~ta*",           "Inf"]       => ["to",         "Inf"],     # 4
  ["gon~",           "Verb"]      => ["going",      "Verb"],    # 4
  ["going (to)*",    "Verb"]      => ["going",      "Verb"],
  ["going* (to)",    "Verb"]      => ["going",      "Verb"],
  ["wan~ [= want]",  "Verb"]      => ["want",       "Verb"],

  ["first",          "Num"]       => ["first",      "Ord"],
  ["third",          "Num"]       => ["third",      "Ord"],
  ["second",         "Num"]       => ["second",     "Ord"],
  ["next",           "Num"]       => ["next",       "Ord"],
  ["last",           "Num"]       => ["last",       "Ord"],

  ["lie (/lay)",     "Verb"]      => ["lie",        "Verb"],
  ["data/datum*",    "NoC"]       => ["data",       "NoC"],
  ["cos*",           "Conj"]      => ["cos",        "Conj"],
  ["all right*",     "Adv"]       => ["alright",    "Adv"],
  ["alright*",       "Adj"]       => ["alright",    "Adj"],
  ["alright*",       "Adv"]       => ["alright",    "Adv"],
  ["be*",            "Verb"]      => ["be",         "Verb"],
  ["because*",       "Conj"]      => ["because",    "Conj"],
  ["bit*",           "NoC"]       => ["bit",        "NoC"],
  ["have*",          "Verb"]      => ["have",       "Verb"],
  ["her*",           "Det"]       => ["her",        "Det"],
  ["labour*",        "Adj"]       => ["labour",     "Adj"],
  ["lot*",           "NoC"]       => ["lot",        "NoC"],
  ["miss*",          "NoC"]       => ["miss",       "NoC"],
  ["more than*",     "Adv"]       => ["more than",  "Adv"],
  ["no one*",        "Pron"]      => ["no one",     "Pron"],
  ["of*",            "Prep"]      => ["of",         "Prep"],
  ["okay*",          "Adj"]       => ["okay",       "Adj"],
  ["okay*",          "Adv"]       => ["okay",       "Adv"],

  ["A / a",          "Lett"]      => ["a",          "Lett"],
  ["B / b",          "Lett"]      => ["b",          "Lett"],
  ["C / c",          "Lett"]      => ["c",          "Lett"],
  ["D / d",          "Lett"]      => ["d",          "Lett"],
  ["E / e",          "Lett"]      => ["e",          "Lett"],
  ["F / f",          "Lett"]      => ["f",          "Lett"],
  ["G / g",          "Lett"]      => ["g",          "Lett"],
  ["H / h",          "Lett"]      => ["h",          "Lett"],
  ["I / i",          "Lett"]      => ["i",          "Lett"],
  ["K / k",          "Lett"]      => ["k",          "Lett"],
  ["L / l",          "Lett"]      => ["l",          "Lett"],
  ["M / m",          "Lett"]      => ["m",          "Lett"],
  ["N / n",          "Lett"]      => ["n",          "Lett"],
  ["O / o",          "Lett"]      => ["o",          "Lett"],
  ["P / p",          "Lett"]      => ["p",          "Lett"],
  ["R / r",          "Lett"]      => ["r",          "Lett"],
  ["S / s",          "Lett"]      => ["s",          "Lett"],
  ["T / t",          "Lett"]      => ["t",          "Lett"],
  ["U / u",          "Lett"]      => ["u",          "Lett"],
  ["X / x",          "Lett"]      => ["x",          "Lett"],
}

# == Fixed by hand ==
#
# let's                 Verb    (changed pos to VMod in 2_1, 3_1, 4_1)
# used (to)             VMod    (changed VMod sense to 'used\tVMod' in 1_1_alpha, 1_2, 2_1, 3_1, 3_2, 4_2)
# &                     Conj    4 & => &amp;

# == Case difference ==
# I                     Pron    1 I
# American              Adj     1 A
# British               Adj     1 B
# English               Adj     1 E
# European              Adj     1 E
# air                   NoC     1 a
# chairman              NoC     1 Chairman => chairman
# Christmas             NoC     1 C
# councillor            NoC     1 c
# doctor                NoC     1 d
# father                NoC     1, 3 f
# field                 NoC     1 f
# home                  NoC     1 h
# king                  NoC     king
# leader                NoC     leader
# lord                  NoC     lord
# mother                NoC     mother
# Mr                    NoC     Mr
# Mrs                   NoC     Mrs
# place                 NoC     place
# president             NoC     president
# Richard               NoP     Richard
# road                  NoC     road
# sir                   NoC     sir
# sister                NoC     sister
# street                NoC     street
# town                  NoC     town

# == turned all underscores '_' into space ' ' in 1_1 ==
# a bit                 Adv
# a little              Adv
# according to          Prep
# and so on             Adv
# as if                 Conj
# as well as            Prep
# as well               Adv
# at all                Adv
# at least              Adv
# away from             Prep
# because of            Prep
# each other            Pron
# for example           Adv
# in terms of           Prep
# of course             Adv
# officer               NoC
# on to                 Prep
# out of                Prep
# over there            Adv
# per cent              NoC
# rather than           Prep
# so that               Conj
# sort of               Adv
# such as               Prep
# up to                 Prep
