
#DataMapper::Logger.new(STDOUT, :debug)
# DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_ics_scaffold' })
DataSet.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS
