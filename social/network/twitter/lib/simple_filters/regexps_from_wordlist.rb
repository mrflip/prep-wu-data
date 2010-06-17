# Given a set of input search terms generate a set of regexp segements
# (that can be chained with `|') to search for
#
# Will try to be smart about @signs, #tags, and too-common words (uses
# /usr/share/dict to define commonness).

module FilterTweetSearchTerms

  def regexp_from_terms *terms
    '(' + regexps_from_terms(terms).join('|') + ')'
  end
  
  def regexps_from_terms *terms
    terms.flatten.map(&:to_s).map(&:strip).map do |term|
      term.strip!
      next if term.empty?
      if term =~ /^(@|#)/ || is_common?(term)
        # we demand that very common words, @signs, and #tags be
        # surrounded by spaces or start and end the string
        '(^|\\\\s+.*)' + term.upcase + '($|\\\\s+.*)'
      else
        # we can directly search for uncommon words
        ".*#{term.upcase}.*"
      end
    end.compact.flatten.map { |term| term.gsub(/\s+/, '\\\\s+') }
  end

  def is_common? term
    num_dictionary_words_like(term) > 5 # arbitrary!
  end
  
  def num_dictionary_words_like term
    word_count = `grep -i #{term.gsub(/\s+/, '\\ ')} #{dictionary} | wc -l`.chomp.strip
    word_count.empty? ? 0 : word_count.to_i
  end

  def dictionary= path
    path = File.expand_path(path)
    raise ArgumentError.new("#{path} does not exist") unless File.exist?(path)
    @dictionary = path
  end

  def dictionary
    return @dictionary if @dictionary
    self.dictionary= File.join(File.dirname(__FILE__), 'american_british_french_italian_german_spanish')
  end
  
end

if $0 == __FILE__
  include FilterTweetSearchTerms
  puts regexp_from_terms($stdin.map)
end

