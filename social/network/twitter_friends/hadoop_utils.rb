module HadoopUtils


  def key_for resource, id, timestamp
    [resource, id].join('-')
  end

  def emit resource, id, timestamp, hsh
    puts [ key_for(resource, id, timestamp), timestamp, *hsh.values_at(*FIELDS[resource]) ].to_tsv
  end

  String.class_eval do
    def scrub!
      gsub!(/[\t\r\n]/, ' ')  # KLUDGE
    end
  end
  Array.class_eval do
    def to_tsv options={}
      to_csv options.merge( :col_sep => "\t" )
    end
  end
  def scrub hsh, *fields
    fields.each{|field| hsh[field.to_s].scrub! if hsh[field.to_s] }
  end

  def convert_timestamp ts
    # 2008-11-28T18:19:33+00:00
    ts.gsub(/\+00:00$/, '').gsub(/[^\d]/, '')
  end

end
