Settings.define :keyspace,     :default => 'Twitter',            :description => 'Cassandra keyspace'
Settings.define :batch_size,   :default => 50, :type => Integer, :description => 'Thrift buffer batch size'

module CassandraDb
  CASSANDRA_DB_SEEDS = %w[ 10.195.77.171 10.218.71.212 10.244.142.192 10.194.93.123 10.218.1.178 ].map{|s| "#{s}:9160"}.sort_by{ rand }

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
    safely("Insert #{[column_family, row_key, column_values].inspect}") do
      cassandra_db.insert(column_family, row_key, column_values, :consistency => Cassandra::Consistency::ANY)
    end
  end

  def db_get *args
    safely("Fetch #{args.inspect}") do
      cassandra_db.get(*args)
    end
  end

  #
  # stores up commits within this block, and passes them all at once to
  #
  # Note that this is nothing like a transaction: it's just a way to make the
  # Thrift interface slightly less wasteful.
  def batch &blk
    safely("Batch process") do
      cassandra_db.batch(&blk)
    end
  end

  def safely action, &block
    begin
      block.call
    rescue StandardError => e ; handle_error(action, e); end
  end

  def handle_error action, e
    warn "#{action} failed: #{e} #{e.backtrace.join("\t")}" ;
    @cassandra_db = nil
    sleep 0.2
  end

end
