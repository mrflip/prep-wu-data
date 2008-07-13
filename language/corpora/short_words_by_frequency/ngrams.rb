#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require "rubygems"
require "JSON"
require "YAML"
require "fastercsv"
require "utils"

RE_FILTHY_WORDS       = 'abac|acoc|adab|adam|aels|aeps|aerb|aerc|aerf|agac|agib|agij|agro|agus|aihc|ajar|ajat|ajip|akuf|alac|alfp|alne|alro|aluc|alur|amak|amul|anat|anil|anup|aohc|apr|arac|arom|atap|atet|atid|atom|atts|atup|auda|auga|auqs|ayam|azib|baca|baet|barc|bbil|bbow|bbub|bbus|behs|beuq|bmub|bolb|boob|brat|breh|brey|bsel|bser|bssa|bteg|btew|buhc|cahc|cahw|caje|carc|ccel|ccos|cehc|ceip|cies|cihc|cihs|cips|cirp|cirt|cits|clef|cnac|cnan|cnar|cnim|cnip|cnoc|cnon|cnum|cohc|conk|corf|cpol|cric|crop|cros|csra|ctib|ctin|ctip|ctub|ctud|cuhc|cuod|daeh|dalf|daw|ddid|ddij|ddim|ddog|deep|deht|dews|dgib|diy|dlid|dlog|dnac|dnah|dnep|dnob|dnoc|dnyh|dog|dohc|dood|doow|drah|drem|drob|drow|drum|drut|dtoh|duod|duts|ebeh|ebup|ecal|ecir|ecni|edep|edog|edoj|edun|edup|eehs|eerg|eeuq|eews|efed|eihc|eirb|ejap|eka|ekam|ekat|ekid|ekik|ekup|ekyd|elet|eloh|eluc|elur|emac|emes|emla|emoc|emug|enev|enob|eorg|epar|epat|epop|ercs|erht|eruh|esib|esid|esir|esra|essa|esub|etah|etaw|etni|etup|evig|evol|ewej|exiw|fdlo|feeb|ffan|ffav|ffib|ffum|firg|firo|fits|fnin|foop|forg|frus|fssa|ftew|fuop|gaf|gaps|gard|gauq|gdoh|gduf|gdun|gehs|gerf|gerp|ggaf|ggif|ggig|ggin|ggod|ggrd|ggub|girf|gloc|gluv|gnab|gnag|gnav|gnaw|gnid|gnif|gnip|gnod|gnub|gnud|gnuh|gnuj|goon|gow|grev|griv|gurd|hcaf|hcib|hcti|hgaf|hkuk|hmub|hsag|hsho|hspu|hssa|hsub|htac|htno|htom|htum|iaf|iart|ibal|ibil|ibup|icar|idir|idub|idun|ieep|igav|igum|ihs|ilig|ilne|imaf|ineg|inep|inuc|ipap|ipar|ipop|irep|ires|irhc|irom|isij|iteg|itep|itit|itom|iuoc|iuog|iuoj|iuqs|iurf|iwej|iyog|izan|jjam|jkot|jmir|kcac|kcaj|kcak|kcar|kcat|kcep|kces|kcid|kcif|kcik|kcil|kcim|kciw|kcoc|kcoh|kcop|kcub|kcuf|kcuj|kcul|kcus|kgib|kihs|kips|kirf|kkk|kkub|kkuf|knaw|knid|knik|knil|knit|knoh|knok|knom|knuf|knuh|knur|kohc|koog|kooh|koon|krad|kreb|krej|krod|kroh|kssa|kuf|kuk|lacs|ladp|lana|lank|laro|ldum|legv|lell|lfed|lgaf|lguf|lhcs|lhvr|lihc|lirg|liub|liuq|llab|llef|lleh|llen|llif|llij|llip|lliw|llnk|llob|llof|llub|llup|llut|lmub|loah|lohc|lrip|lrut|lssa|lteg|luks|lunk|lur|lyag|mar|marc|mcos|mehs|mhcs|miks|mir|miuq|mjad|mlm|mmip|mmop|mmot|mmug|mmuh|mooz|mop|mops|msdb|msij|mub|muc|mucs|nac|naeb|naks|nalf|nalk|nals|naps|nawt|nder|nerf|ngac|ngim|ngio|nhcs|nhoj|niap|niar|niat|nihc|niob|nirg|nirt|niru|niws|niwt|nmad|nnoc|nnps|nnuc|noeb|nooc|noon|noop|norf|nork|nroc|nroh|nrop|nuhp|nuon|nups|nurk|nyls|oau|obeg|ocat|ocep|odas|odep|odog|odos|odot|ofne|ogad|ogni|ohar|ojip|ojoc|okhs|okuf|olas|olep|oloc|oluc|omog|omoh|onim|onos|ooc|oohs|ool|oolb|oops|opic|orbs|orcs|oreh|orts|oseb|osub|otap|oteg|oter|otoj|otom|otup|oypu|ozab|pahc|palc|pals|parc|parcparc|pdum|peep|pilc|pirt|pmip|pmop|pmuh|pmur|pmyn|pocs|pons|poop|pow|ppin|ppip|prac|puhc|pws|qirt|qsac|raeb|raep|raet|rahc|rbac|rbc|rbiv|rdam|rehc|reih|reps|reuq|riaf|riah|riht|rjts|robs|rohc|rohw|rolg|roop|rots|rret|rromnrom|rrot|rruc|rrum|rtoh|ruof|saeb|salb|salf|sarb|sbut|sder|sdiy|seer|seht|seid|seno|seod|sgaf|sgow|sguj|shco|shkp|skuk|smoc|smop|smub|snlf|snub|soba|solc|sool|sorf|sorg|sorp|spid|spow|sreh|ssa|ssay|ssik|ssip|ssis|ssot|ssp|ssum|ssup|ssw|stae|staf|steg|stit|suas|sum|suna|suop|swej|swoh|syag|syog|tacs|taeb|taem|tahc|tahs|taib|talf|tals|tans|tarx|tawt|tbog|tcer|tder|tfig|tfos|tihs|tihw|tiks|tilc|tilk|tils|tit|tlef|tnap|tnat|tnep|tnom|tnuc|tocw|tooc|tooh|toot|tore|traf|treg|trev|trot|tsab|tsam|tsaw|tseb|tset|tsif|tsis|tsop|tsuh|tsul|ttif|ttit|ttoc|ttof|ttub|ttum|ttup|tuc|tuls|tums|tun|tuof|txaw|txis|ucne|umma|unep|uqof|urom|urps|urts|usej|uths|vaeb|virp|voop|vrep|vruk|vuev|wder|weew|wej|wgar|whcs|wmub|wohc|wolb|wolp|wonk|worb|wsot|wssa|wwpw|xes|xip|xulk|xxx|yafo|yaj|yalp|ygro|yhcs|yog|zel|zihw|zij|ztik|zzac|zzel|zzij'

#
#
#
class AdjList
  FREQ_TYPES = [:freq_lexical, :freq, :freq_sp, :freq_wr]

  attr_accessor :len, :adj_lists
  attr_accessor :census
  def initialize(len, words_info)
    @len    = len
    @census = { :words => Hash.zip(FREQ_TYPES, [0]*FREQ_TYPES.length),
                :ltrs  => Hash.zip(FREQ_TYPES, [0]*FREQ_TYPES.length), }
    self.adj_lists = make_adj_lists(len)
    fill_adj_lists words_info
  end

  def make_adj_lists(n)
    # ngrams = ('a'*n)..('z'*n);
    # tos  = ngrams.map{ {} }
    # Hash.zip(ngrams, tos)
    lists = FREQ_TYPES.map do |ft|
      (1..@len).map{|n| { } }
    end
    Hash.zip(FREQ_TYPES, lists)
  end

  #
  #
  # * rejects words with
  #
  def fill_adj_lists words_info
    words_info.each do |_, info|
      ltrs, word = get_letters(info)
      next unless ltrs
      census_record_word info, word
      ngrams     = [ '^' ] ; ltrs << '$'
      ltrs.length.times do
        ltr = ltrs.shift
        census_record_ltr  info, ltr
        record_adjacencies info, ngrams, ltr
        ngrams = ngrams.map{|s| s+ltr }.unshift(ltr)[0..@len-1]
      end
    end
    adj_lists
  end

  def get_letters(info)
    word = info[:lemma]
    word.gsub /[\s\-]+/, ' '          # space-separate hyphens, whitespace
    # word.gsub /[^a-z\s]+/, ''       # -??- nuke  non-characters
    return nil if word =~ /[^a-z\s]/  # -??- reject words with non-characters
    return nil unless word && word.length > 1
    ltrs = word.downcase.split(//)     # all lower-case
    [ltrs, word]
  end

  def census_freq freq
    freq && freq.to_f + 0.5  # This is fairly arbitrary.
  end
  def record_adjacency adj_list, ngram, ltr, freq
    return unless freq
    adj_list[ngram]      ||= {}
    adj_list[ngram][ltr] ||= 0
    adj_list[ngram][ltr] += freq
  end
  def record_adjacencies info, ngrams, ltr
    ngrams.each_with_index do |ngram,n|
      ft = :freq_lexical
      record_adjacency adj_lists[ft][n], ngram, ltr, 1
      (FREQ_TYPES-[:freq_lexical]).each do |ft|
        record_adjacency adj_lists[ft][n], ngram, ltr, census_freq(info[ft])
      end
    end
  end
  def census_record_word info, word
    census[:words][:freq_lexical] += 1
    (FREQ_TYPES-[:freq_lexical]).each do |ft|
      census[:words][ft] += census_freq(info[ft]) if info[ft]
    end
  end
  def census_record_ltr info, ltr
    census[:ltrs][:freq_lexical] += 1
    (FREQ_TYPES-[:freq_lexical]).each do |ft|
      census[:ltrs][ft] += census_freq(info[ft]) if info[ft]
    end
  end

  def dump out_file
    out_struct = {
      'adjacency' => adj_lists,
      'census'    => census }
    out_struct = { 'infochimps_dataset' => { 'payload' => out_struct } }
    YAML.dump(out_struct, File.open(out_file, 'w'))
  end

  def to_s
    str = ''
    rand_chains.each do |rand_chain|
      rand_chain.sort_by{|ngram, chain| [ngram, chain.length, ngram] }.each do |ngram, chain|
        str << { ngram => chain }.to_json + "\n"
      end
    end
    str << chain_ngrams.to_json
    str
  end
end

BNC_FIELDS_ALL         = [:head, :pos, :lemma, :freq, :disp, :freq_sp, :freq_wr, :tag, :head_orig, :tag_lemma]
BNC_FIELDS_WANT        = [:head, :pos, :lemma, :freq, :freq_sp, :freq_wr, :tag_lemma]

max_ngram_len                = ARGV[0]
words_info_in_filename       = ARGV[1]
ngram_adjacency_out_filename = ARGV[2]

announce "loading words"
words_info     = csv_load_words words_info_in_filename, :tag_lemma, BNC_FIELDS_ALL, BNC_FIELDS_WANT
announce "loading adjacency"
adj_list = AdjList.new(max_ngram_len.to_i, words_info)
announce "dumping adjacency"
adj_list.dump ngram_adjacency_out_filename
announce "done"


# class Babbler
#   attr_accessor :adj_list, :rand_chains, :chain_ngrams
#   def initialize(adj_list)
#   end
#
#
#   def flatten_freq freq, order
#     z_ish = order * freq / Math.sqrt(ltrs_seen)
#     (10 * z_ish).to_i
#   end
#   def rand_chains
#     return @rand_chains if @rand_chains
#     @rand_chains = []
#     adj_lists.each_with_index do |adj_list, n|
#       @rand_chains[n] = {}
#       adj_list.each do |ngram, adj|
#         chain = adj.map{|ltr,freq| [ltr]*flatten_freq(freq, n+1) }.flatten.sort.join('')
#         @rand_chains[n][ngram] = chain unless chain.empty?
#       end
#     end
#     @rand_chains
#   end
#
#   def chain_ngrams
#     return @chain_ngrams if @chain_ngrams
#     @chain_ngrams = rand_chains.map{ |chain| chain.map{ |ng,adj| ng*Math.sqrt(adj.length) }}.flatten.join('')
#   end
#
#   def bowdlerize word
#     clean_word = word.reverse.gsub(/(#{RE_FILTHY_WORDS})/, '').reverse
#     # puts "#{word} is dirty: #{$1} (clean: #{clean_word})" if $1
#     clean_word
#   end
#
#   def rand_word_len
#     gauss_rand(5,3).to_i
#   end
#
#   def babble
#     # prev = chain_ngrams.at_random
#     prev = ' '
#     str = prev
#     goal_len = rand_word_len + 1
#     until str.length >= goal_len do
#       case
#       when rand_chains[2][prev] then ltr = rand_chains[2][prev].at_random
#       when rand_chains[1][prev] then ltr = rand_chains[1][prev].at_random
#       when rand_chains[0][prev] then ltr = rand_chains[0][prev].at_random
#       else                           ltr = chain_ngrams.at_random end
#       str += ltr
#       # str = bowdlerize str
#       prev = ltr
#     end
#     str[1..-1]
#   end
#
#   def get_nonsense(min_words, min_chars)
#     sentence = []
#     until ((sentence.length > min_words) && (sentence.to_s.length > min_chars)) do
#       word = babble
#       # if (word.reverse =~ /(#{RE_FILTHY_WORDS})/) then puts "filthy #{word} (#{$1.reverse})" ; next end
#       sentence << word unless (word.reverse =~ /#{RE_FILTHY_WORDS}/)
#     end
#     sentence.join ' '
#   end
#
# end

# announce "babbling"
# File.open '/tmp/foo.txt', 'w' do |out_file|
#   2000.times do
#     out_file << adj_list.get_nonsense(2, 10)
#     out_file << "\n"
#   end
# end
