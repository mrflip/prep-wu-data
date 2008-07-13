
REMAP_HEADS = {
  ["ai~*",           "Uncl"]      => ["be",         "Uncl"],            #!!
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
