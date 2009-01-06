require 'hadoop/utils'
require 'pathname'
module Hadoop
  class Script
    attr_accessor :mapper_klass, :reducer_klass, :options
    def initialize mapper_klass, reducer_klass
      process_argv!
      self.mapper_klass  = mapper_klass
      self.reducer_klass = reducer_klass
    end

    #
    # Parse the command-line args into the options hash.
    #
    # I should not reinvent the wheel.
    # Yet here we are.
    #
    def process_argv!
      self.options = { }
      options[:all_args] = ARGV - ['--go']
      args = ARGV.dup
      while args do
        arg = args.shift
        case
        when arg == '--' then break
        when arg =~ /\A--(\w+)(?:=(.+))?\z/
          opt, val = [$1, $2]
          opt = opt.to_sym
          val ||= true
          self.options[opt] = val
        else args.unshift(arg) ; break
        end
      end
      self.options[:rest] = args
      # $stderr.puts [ self.options, this_script_filename.to_s ].inspect
    end

    def this_script_filename
      Pathname.new($0).realpath
    end

    #
    # by default, call this script in --map mode
    #
    def map_command
      "#{this_script_filename} --map " + options[:all_args].join(" ")
    end

    #
    # Shell command for reduce phase
    # by default, call this script in --reduce mode
    #
    def reduce_command
      "#{this_script_filename} --reduce " + options[:all_args].join(" ")
    end

    #
    # Number of fields for the KeyBasedPartitioner
    # to sort on.
    #
    def sort_fields
      self.options[:sort_fields] || 2
    end

    def exec_hadoop_streaming
      slug = Time.now.strftime("%Y%m%d")
      input_path, output_path = options[:rest][0..1]
      raise "You need to specify a parsed input directory and a directory for output. Got #{ARGV.inspect}" if input_path.blank? || output_path.blank?
      $stderr.puts "Launching hadoop streaming on self"
      if options[:fake]
        command = %Q{ cat '#{input_path}' | #{map_command} | sort | #{reduce_command} > '#{output_path}'}
        $stderr.puts command
        $stdout.puts `#{command}`
      else
        %x{ hdp-stream '#{input_path}' '#{output_path}' '#{map_command}' '#{reduce_command}' #{sort_fields} }
      end
    end

    #
    # If --map or --reduce, dispatch to the mapper or reducer.
    # Otherwise,
    #
    def run
      case
      when options[:map]
        mapper_klass.new(self.options).stream
      when options[:reduce]
        reducer_klass.new(self.options).stream
      when options[:go]
        exec_hadoop_streaming
      when options[:fake_hadoop]
        exec_fake_hadoop
      else
        self.help # Normant Vincent Peale is proud of you
      end
    end

    #
    # Command line usage
    #
    def help
      $stderr.puts "#{self.class} script"
      $stderr.puts %Q{
        #{__FILE__} --go input_hdfs_path output_hdfs_dir     # run the script with hadoop streaming
        #{__FILE__} --map,
        #{__FILE__} --reduce                                 # dispatch to the mapper or reducer
      }
    end
  end

end
