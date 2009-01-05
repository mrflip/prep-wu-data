#
# String Monkeypatched for processing with hadoop: see hadoop/extensions/string
#
String.class_eval do
  #
  # The reverse of +camelize+. Makes an underscored, lowercase form from the expression in the string.
  #
  # Changes '::' to '/' to convert namespaces to paths.
  #
  # Examples:
  #   "ActiveRecord".underscore         # => "active_record"
  #   "ActiveRecord::Errors".underscore # => active_record/errors
  #
  # Stolen from active_support
  #
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
  #
  # Strip control characters that might harsh our buzz, TSV-wise
  #
  def scrub!
    gsub!(/[\t\r\n]+/, ' ')  # KLUDGE
    gsub!(/\\/, '/') # hadoop is barfing on double backslashes. sorry, backslashes.
  end
end

module HadoopUtils
  #
  # For each given field in the hash,
  # scrub characters that will mess us up.
  #
  def scrub_hash hsh, *fields
    fields.each{|field| hsh[field.to_s].scrub! if hsh[field.to_s] }
  end
end
