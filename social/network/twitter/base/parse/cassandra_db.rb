# For access to the gibbon cluster, have each node point to its own
CASSANDRA_DB_SEEDS = [
  `hostname`.chomp,
  %w[ 10.195.9.124 10.242.81.156 10.194.186.32 10.196.202.63 10.194.186.95 10.195.162.47 10.196.186.112 ]
].flatten.uniq.map{|s| "#{s}:9160"}
