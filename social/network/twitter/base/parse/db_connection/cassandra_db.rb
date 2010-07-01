#
# Gibbon cluster
#
# CASSANDRA_DB_SEEDS = [
#   `hostname`.chomp,
#   %w[ 10.195.9.124 10.242.81.156 10.194.186.32 10.196.202.63 10.194.186.95 10.195.162.47 10.196.186.112 ]
# ].flatten.uniq.map{|s| "#{s}:9160"}

#
# Zaius (new) cluster
#
CASSANDRA_DB_SEEDS = [
  %w[ 10.244.142.192 10.194.93.123 10.195.77.171 10.218.1.178 10.218.71.212 ]
].flatten.uniq.map{|s| "#{s}:9160"}




