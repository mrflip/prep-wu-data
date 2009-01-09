module TwitterFriends::JsonModel
  class GenericJsonParser
    attr_accessor :raw
    def initialize raw
      self.raw = raw; return unless healthy?
      self.fix_raw!
    end
    def healthy?() raw && raw.is_a?(Hash) end

    #
    # Coerce any fields that need fixin'
    #
    def fix_raw!
    end

    #
    # Safely parse the json object and instantiate with the raw hash
    #
    def self.new_from_json json_str, *args
      return unless json_str
      begin
        raw = JSON.load(json_str) or return
      rescue Exception => e; return ; end
      self.new raw, *args
    end
  end

end
