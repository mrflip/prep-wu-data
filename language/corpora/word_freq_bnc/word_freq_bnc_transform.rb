require 'htmlentities'; $KCODE = 'u'
require 'htmlentities/expanded'
# require "special_cases"

#
# Headword / Lemma structures
#
# KLUDGE -- we're going to stuff these extra entries into the SGML mapping --
# see notes on 'uncaught entities'
HTMLEntities::MAPPINGS['expanded'].merge!({
    "bquo"     => 0x201c,
    "ft"       => 0x0027,
    "ins"      => 0x0022,
    "rehy"     => 0x00ad,
    "shilling" => 0x002f,
    "formula"  => 0x222e,
  })
$entity_decoder = HTMLEntities.new(:expanded)
def decode_str(str)
  # found during processing: only 3, so why be clever.
  str = str.gsub(/&frac17;/, '1/7')
  str.gsub!(/&frac19;/, '1/9')
  str.gsub!(/4&frac47;/,'4 4/7')
  str = $entity_decoder.decode(str)
end

# #
# #
# def fix_vals hsh
#   hsh.keys.each do |f|
#     case
#     when f.to_s =~ /^(log_lkhd|disp).*/  then hsh[f] = hsh[f].to_f
#     when f.to_s =~ /^(freq|range).*/     then hsh[f] = hsh[f].to_i
#     when f == :head
#       head_orig = hsh[:head]
#       pos       = hsh[:pos]
#       if REMAP_HEADS.include?( [head_orig, pos] )
#         head_orig, pos = REMAP_HEADS[ [head_orig, pos] ]
#         hsh[:pos] = pos
#       end
#       #no conflict here because :pos isn't changed except in this block.
#       hsh[:tag]       = "#{head_orig}_#{hsh[:pos]}"
#       hsh[:head_orig] = head_orig
#       hsh[:head]      = decode_str(head_orig||'')
#     when f == :lemma
#       lemma_orig = hsh[:lemma]
#       if REMAP_HEADS.include?( [lemma_orig, hsh[:pos]] )
#         lemma_orig, hsh[:pos] = REMAP_HEADS[ [lemma_orig, hsh[:pos]] ]
#         hsh[:pos] = pos
#       end
#       hsh[:tag_lemma]  = "#{hsh[:tag]}_#{lemma_orig}"
#       hsh[:lemma_orig] = lemma_orig
#       hsh[:lemma]      = decode_str(lemma_orig||'')
#     end
#   end
#   hsh
# end
