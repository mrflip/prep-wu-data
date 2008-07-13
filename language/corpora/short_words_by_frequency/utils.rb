
# Utils
# Create a hash from an array of keys and corresponding values.
def Hash.zip(keys, values, default=nil, &block)
  hash = block_given? ? Hash.new(&block) : Hash.new(default)
  keys.zip(values) { |k,v| hash[k]=v }
  hash
end
def announce(s) puts "#{Time.now} #{s.to_s}" end
def announce_progress(reps, what='at', period=10_000) announce "#{what} #{reps/1000}k" if (reps % period == 0) end

# Get a random element from an array
Array.class_eval do
  def at_random()
    return nil if empty?
    self[ rand(length) ]
  end
end

# Get a random element from an array
String.class_eval do
  def at_random()
    return nil if empty?
    self[ rand(length), 1 ]
  end
end


def gauss_rand(width, offset=0) offset + width*( 0.5 + 2*(rand-0.5)*(rand-0.5) ) end

#
# Load table to hash.
#
def csv_load_words words_file_in, key, fields_all, fields_want
  words = {}
  _reps = 0
  field_idxs = fields_want.map{ |i| fields_all.index(i) }
  # silently swallows header, so no need to explicitly nil it.
  FasterCSV.open(words_file_in, 'r').each do |row|
    word = Hash.zip(fields_want, row.values_at(*field_idxs))
    words[word[key]] = word
    _reps += 1 ; puts "#{Time.now} parsed #{_reps/1000}k" if (_reps % 10_000 == 0)
  end
  words
end



# #
# # Load table to hash.
# #
# def csv_load_words words_file_in, key, fields_all, fields_want
#   words = {}
#   _reps = 0
#   field_idxs = fields_want.map{ |i| fields_all.index(i) }
#   # silently swallows header, so no need to explicitly nil it.
#   FasterCSV.open(words_file_in, 'r').each do |row|
#     word = Hash.zip(fields_want, row.values_at(*field_idxs))
#     words[word[key]] = word unless (words[word[key]] && (words[word[key]][:freq].to_i < word[:freq].to_i))
#     _reps += 1 ; puts "#{Time.now} parsed #{_reps/1000}k" if (_reps % 10_000 == 0)
#   end
#   words
# end
