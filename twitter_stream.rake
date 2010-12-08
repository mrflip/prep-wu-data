require 'rake'
require 'swineherd' ; include Swineherd

Settings.define :input, :type => Array, :required => true, :description => 'array of directories with files to stream '
Settings.define :output_dir, :required => true, :description =>  'top directory of file stream destination'
Settings.resolve!

def create_tasks list_of_tasks
  list_of_tasks.each do |tsk, input_path|
    task tsk do
      output_path = File.join(Settings.output_dir,tsk)
      HDFS.stream(input_path, output_path)
    end
  end
end

list_of_tasks = Settings.input.inject({}){|hsh, path| hsh[File.basename(path)] = path; hsh}
create_tasks list_of_tasks

multitask :stream_all => list_of_tasks.keys
task :default => [:stream_all]
