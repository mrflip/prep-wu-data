# Note: this is not at all tidy; probably only works in conjunction with other
# modules in this directory; may be harmful to small children ; do not taunt
# happy fun ball.
#
# Subclass must define a method 'batch'
#
class BatchStreamer < Wukong::Streamer::RecordStreamer
  attr_accessor :batch_count, :batch_record_count, :log

  def initialize *args
    super *args
    @batch_size = options.batch_size
    @log = PeriodicLogger.new
  end

  #
  # Batch Streaming mechanics
  #
  def stream
    self.batch_count        = 0
    self.batch_record_count = 0
    while records_remaining? do
      batch do
        self.batch_record_count = 0
        while records_remaining? && batch_not_full? do
          record = get_record ; next if record.blank?
          process(*record) do |output_record|
            emit output_record unless output_record.blank?
          end
          self.batch_record_count += 1
        end
        self.batch_count += 1
      end
    end
    after_stream
  end

  def get_record
    line   = $stdin.gets or return
    recordize(line.chomp)
  end

  def records_remaining?
    !$stdin.eof?
  end

  def batch_not_full?
    self.batch_record_count < @batch_size
  end

  def after_stream
  end

end
