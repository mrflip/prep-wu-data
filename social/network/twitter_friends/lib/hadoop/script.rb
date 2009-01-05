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
    # I should not reinvent the wheel
    # Yet here we are.
    #
    def process_argv!
      self.options = { }
      args = ARGV.dup
      while args do
        case
        when args.first == '--' then break
        when args.first =~ /\A--(\w+)(?:=(.+))?\z/
          opt, val = [$1, $2] ; args.shift
          opt = opt.to_sym
          val ||= true
          self.options[opt] = val
        else break
        end
      end
      self.options[:rest] = args
      # $stderr.puts [ self.options, this_script_filename.to_s ].inspect
    end

    def this_script_filename
      Pathname.new($0).realpath
    end

    def map_command
      "#{this_script_filename} --map"
    end

    def reduce_command
      "#{this_script_filename} --reduce"
    end

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

    def help
      $stderr.puts "#{self.class} script"
      $stderr.puts %Q{
        #{__FILE__} --go input_hdfs_path output_hdfs_dir     # run the script with hadoop streaming
        #{__FILE__} --map,
        #{__FILE__} --reduce                                 # dispatch to the mapper or reducer
      }
    end

    #
    # If --map or --reduce, dispatch to the mapper or reducer.
    # Otherwise,
    #
    def run
      case
      when options[:map]
        mapper_klass.new.stream(self.options)
      when options[:reduce]
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
