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
        item = itemize(line) ; next if item.blank?
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

  class StructStreamer < Streamer
    def itemize line
      klass_name, *vals = super(line)
      klass_name.gsub!(/-.*$/, '') # kill off all but class name
      begin klass = klass_name.to_s.camelize.constantize
      rescue ; warn "Bogus class name starting line '#{line}'" ; return ; end
      [ klass.new(*vals) ]
    end
  end

  class AccumulatingReducer < Streamer
    attr_accessor :last_key
    def initialize options
      super options
      reset!
    end

    #
    # override for multiple-field keys, etc.
    #
    def get_key vals
      vals.first
    end

    #
    # Accumulate all values for a given key.
    #
    # When the last value for the key is seen, finalize processing and adopt the
    # new key.
    #
    def process *vals
      key = get_key(vals)
      # if we've seen nothing, adopt key
      self.last_key ||= key
      # if this is a new key,
      if key != self.last_key
        finalize                # process what we've collected so far
        reset!                  # then forget about that key
        self.last_key = key     # and start a new one
      end
      # collect the current line
      accumulate *vals
    end

    #
    # reset! is called after finalizing a batch of key sightings
    #
    # Make sure to call +super+ if you override
    #
    def reset!
      self.last_key = nil
    end

    #
    # Override this to accumulate each value for the given key in turn.
    #
    def accumulate
      raise "override the accumulate method in your subclass"
    end

    #
    #
    # You must override this method.
    #
    def finalize
      raise "override the finalize method in your subclass"
    end

    #
    # Must make sure to finalize the last-seen accumulation.
    #
    def stream
      super
      finalize
    end
  end


  #
  # To extract the *latest* value for each property, set hadoop to use
  # <resource, item_id, timestamp> as the sort keys
  #
  # Accumulate just acts like an insecure high-schooler, adopting in turn the
  # latest value seen. Then the finalized value is the last in sort order.
  #
  #
  class UniqByLastReducer < AccumulatingReducer
    attr_accessor :final_value

    #
    # Key on first two fields by default
    #
    def get_key vals
      vals[0..1]
    end

    #
    # Just adopt each value in turn: the last one's the one you want.
    #
    def accumulate *vals
      self.final_value = *vals
    end
    #
    def reset!
      self.final_value = nil
    end
    #
    # Emit the last-seen (latest) value
    #
    def finalize
      puts final_value.join("\t") if final_value
    end
  end


end
