module Hadoop
  class Streamer
    attr_accessor :sort_key_fields

    #
    # Convert each line to struct
    # send to processor
    def stream options={ }
      $stdin.each do |line|
        item = itemize line
        process(*item)
      end
    end
    def itemize line
      line.chomp.split("\t")
    end
  end

  class StructStreamer < Streamer
    def itemize line
      klass_name, item_key, *vals = super(line)
      klass = klass_name.to_s.camelize.constantize
      [ klass.new(item_key, *vals) ]
    end
    
  end
  
  class UniqStreamer < Streamer
    attr_accessor :last_item
    def initialize
      self.last_item = nil
    end
    def process item
      next if self.last_item.eq(item)
      self.last_item = item
      item.emit
    end
  end

end



# accumulator:
#  gets 'accumulate' on each line
#  and then 'emit' on final one.

# grep: grep
#
