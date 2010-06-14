Settings.define :keyspace,     :default => 'Twitter',                :description => 'Cassandra keyspace'
Settings.define :batch_size,   :default => 50,     :type => Integer, :description => 'Thrift buffer batch size'
Settings.define :log_interval, :default => 10_000, :type => Integer, :description => 'How many iterations between log statements'

class CassandraBulkLoadStreamer < Wukong::Streamer::RecordStreamer
  attr_accessor :batch_count, :batch_record_count, :insert_count, :run_start_time
  CASSANDRA_DB_SEEDS = %w[ 10.195.77.171 10.218.71.212 10.244.142.192 10.194.93.123 10.218.1.178 ].map{|s| "#{s}:9160"}.sort_by{ rand }

  def initialize *args
    super *args
    initialize_logging
    @batch_size = options.batch_size
  end

  #
  # Batch Streaming mechanics
  #
  def stream
    30_000.times{ $stdin.gets }
    while still_lines? do
      batch do
        while still_lines? && batch_not_full? do
          record = get_record or break
          next if record.blank?
          process(*record) do |output_record|
            emit output_record unless output_record.blank?
          end
          self.batch_record_count += 1
        end
      end
      break if @insert_count > 20_000
    end
    after_stream
    $stdin.each{|l| true }
  end

  def batch &blk
    self.batch_record_count = 0
    self.batch_count += 1
    begin
      cassandra_db.batch(&blk)
    rescue StandardError => e ; warn "Insert failed: #{e} #{e.backtrace}" ; @cassandra_db = nil ; sleep 1; end
  end

  def get_record
    line   = $stdin.gets or return
    recordize(line.chomp)
  end

  def still_lines?
    !$stdin.eof?
  end

  def batch_not_full?
    self.batch_record_count < @batch_size
  end

  def after_stream
    log_sometimes( "%7d"%@batch_size, :force => true )
  end

  #
  # Periodic logger
  #

  def initialize_logging
    self.batch_count        = 0
    self.batch_record_count = 0
    self.insert_count       = 0
    self.run_start_time     = current_time
    @log_interval           = options.log_interval
  end

  def log_sometimes *stuff, &block
    options = stuff.extract_options!
    if options[:force] || (self.insert_count % @log_interval == 0)
      dump_line = [batch_count, "%15d" % insert_count, "%7.2f"%run_elapsed_time, "sec", "%7.2f"%(insert_count.to_f / run_elapsed_time), "/sec", current_time, *stuff ].join("\t")
      $stderr.puts dump_line
      emit         dump_line
    end
    block.call(batch_count, insert_count) if block
  end

  def run_elapsed_time
    current_time - self.run_start_time
  end
  def current_time
    Time.now.utc
  end

  #
  # Database mechanics
  #
  def cassandra_db
    @cassandra_db ||= Cassandra.new(options.keyspace, CASSANDRA_DB_SEEDS)
  end

  #
  # Insert into the cassandra database with default settings
  #
  def db_insert column_family, row_key, column_values
    begin
      cassandra_db.insert(column_family, row_key, column_values, :consistency => Cassandra::Consistency::ANY)
    rescue StandardError => e ; warn "Insert failed: #{e} #{e.backtrace.join("\t")}" ; @cassandra_db = nil ; sleep 0.2; end
    self.insert_count += 1
    log_sometimes( "%7d"%@batch_size )
  end

end
