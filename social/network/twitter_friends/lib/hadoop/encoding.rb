require 'htmlentities'
module Hadoop
  #
  # Convert string to
  # * XML-encoded ASCII,
  #
  # * with a guarantee that the characters " quote, ' apos \\ backslash,
  #   carriage-return \r newline \n and tab \t (as well as all other control
  #   characters) are encoded.
  #
  # * Any XML-encoding in the original text is encoded with no introspection:
  #     encode_str("&lt;a href=\"foo\"&gt;")
  #     # => "&amp;lt;a href=&quot;foo&quot;&amp;gt;"
  #
  # Hadoop.decode_str(Hadoop.encode_str(str)) returns the original str
  #
  # Useful:
  #   http://rishida.net/scripts/uniview/conversion.php
  #
  def self.encode_str str
    begin
      self.html_encoder.encode(str, :basic, :named, :decimal).gsub(/\\/, '&#x5C;')
    rescue ArgumentError => e
      str.gsub!(/[^\w\s\.\-@#\:\/%]+/, '')
      '!!bad_encoding!! ' + str
    end
  end
  # HTMLEntities encoder instance
  def self.html_encoder
    @html_encoder ||= HTMLEntities.new
  end

  #
  # Decode string from its encode_str representation.  This can include
  # dangerous things such as tabs, newlines, backslashes and cryptofascist
  # propaganda.
  #
  def self.decode_str str
    HTMLEntities.decode_entities(str)
  end

  #
  # Replace each given field in the hash with its
  # encoded value
  #
  def self.encode_components hsh, *fields
    fields.each do |field|
      hsh[field] = hsh[field].to_s.hadoop_encode if hsh[field]
    end
  end
end

String.class_eval do

  #
  # Strip control characters that might harsh our buzz, TSV-wise
  # See Hadoop.encode_str
  #
  def hadoop_encode!
    replace self.hadoop_encode
  end

  def hadoop_encode
    Hadoop.encode_str(self)
  end

  #
  # Decode string into original (and possibly unsafe) form
  # See Hadoop.encode_str and Hadoop.decode_str
  #
  def hadoop_decode!
    replace self.hadoop_decode
  end

  def hadoop_decode
    Hadoop.decode_str(self)
  end
end

