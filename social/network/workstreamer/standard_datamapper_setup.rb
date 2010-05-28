require 'dm-core'
require 'configliere'
Settings.use    :config_file, :define, :commandline
Settings.read   'datamapper.yaml'
Settings.define :db_uri,  :description => "Base URI for database -- eg mysql://USERNAME:PASSWORD@localhost:9999"
Settings.define :db_name, :description => "Database name to use"
# Settings.resolve!

module DataMapper
  def self.setup_db_connection db_name=nil, db_uri=nil, conn_name=nil
    conn_name ||= :default
    db_uri    ||= Settings.db_uri
    db_name   ||= Settings.db_name
    self.setup( conn_name, File.join(db_uri, db_name) )
  end


  module LoadsData
    module ClassMethods
      #
      # Bulk load a .csv file into the database
      #
      def load_data_infile_query filename, columns
        # omitted: LINES STARTING BY 'string' TERMINATED BY 'string'  [SET col_name = expr,...]
        filename = File.expand_path(filename)
        %Q{
        LOAD DATA INFILE '#{filename}'
          REPLACE INTO TABLE \`#{self.storage_name}\`
          FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
          IGNORE 1 LINES
          (#{ columns.join(", ") })
          SET filename = '#{File.basename(filename)}'
        }
      end

      def load_data_infile filename, columns
        query_text = load_data_infile_query(filename, columns)
        puts query_text
        self.repository.adapter.execute(query_text)
      end
    end

    def self.included base
      base.class_eval{ extend ClassMethods }
    end
  end
end

