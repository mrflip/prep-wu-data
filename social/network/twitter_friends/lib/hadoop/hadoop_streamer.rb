
module Hadoop
  class Streamer
    attr_accessor :sort_key_fields

    #
    # Convert each line to struct
    # send to processor
    def stream
      $sdtin.each do |line|
        item = itemize line
        self.process(item)
      end
    end

    def itemize line
      klass_name, item_key, *vals = line.split "\t"
      klass = klass_name.to_s.camelize.constantize
      klass.new(item_key, *vals)
    end
  end

  class UniqStreamer < Streamer
    attr_accessor last_item
    def initialize
      self.last_item = nil
    end
    def process item
      next if self.last_item.eq(item)
      self.last_item = item
      item.emit
    end
  end

  class Script
    attr_accessor :mapper_klass, :reducer_klass, :options
    def initialize mapper_klass, reducer_klass
      process_argv!
      self.mapper_klass  = mapper_klass
      self.reducer_klass = reducer_klass
    end
    #
    # I should not reinvent the wheel
    # Yet here we are.
    #
    def process_argv!
      self.options = { }
      args = ARGV.dup
      while args do
        case
        when args.first == '--' then last
        when args.first =~ /\A--/
          opt = args.shift
          self.options[opt] = (args.first =~ /\A--.+/) ? true : args.shift
        else last
        end
      end
      self.options[:rest] = args
    end

    def exec_hadoop_streaming
      slug = Time.now.strftime("%Y%m%d")
      input_files, output_dir = ARGV[1..2]
      raise "You need to specify a parsed input directory and a directory for the initial pagerank file: got #{ARGV.inspect}" if input_files.empty? || output_dir.empty?
      mapred_script = Pathname.new(__FILE__).realpath
      dummy_file    = File.dirname(mapred_script)+'/dummy_pagerank_line.tsv'
      $stderr.puts "Launching hadoop streaming on self"
      %x{ hdp-stream '#{input_files}' '#{output_dir}' '#{mapred_script} --map' '#{mapred_script} --reduce' 2 }
      %x{ hdp-cp     '#{dummy_file}'  '#{output_dir}' }
    end

    #
    # If --map or --reduce, dispatch to the mapper or reducer.
    # Otherwise,
    #
    def run
      case phase
      when options[:map]
        mapper_klass.new.stream(self.options)
      when options[:map]
        reducer_klass.new.stream(self.options)
      when options[:go]
        exec_hadoop_streaming
      when options[:fake_hadoop]
        exec_fake_hadoop
      else
        self.help # Normant Vincent Peale is proud of you
      end
    end
  end
end



# accumulator:
#  gets 'accumulate' on each line
#  and then 'emit' on final one.

# grep: grep
#
