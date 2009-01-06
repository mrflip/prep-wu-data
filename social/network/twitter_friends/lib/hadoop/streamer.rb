module Hadoop
  class Streamer
    attr_accessor :sort_key_fields, :options

    def initialize options
      self.options = options
    end

    #
    # Convert each line to struct
    # send to processor
    def stream
      $stdin.each do |line|
        item = itemize line
        process(*item)
      end
    end
    def itemize line
      line.chomp.split("\t")
    end

    def bad_record! *args
      warn "Bad record #{args.inspect[0..400]}"
      puts ["bad_record", args].flatten.join("\t")
    end
  end


  class AccumulatingStreamer < Streamer
    attr_accessor :last_key
    def initialize
      reset!
    end
    def reset!
      self.last_key = nil
    end

    def process key, *vals
      # if we've seen nothing, adopt key
      self.last_key ||= key
      # if this is a new key,
      if key != self.last_key
        finalize                # process what we've collected so far
        reset!                  # then forget about that key
        self.last_key = key     # and start a new one
      end
      # collect the current line
      accumulate key, *vals
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
