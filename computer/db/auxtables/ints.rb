
(0..(2**16-1)).each do |i|
  puts "%d\t%d" % [i, i-(2**15-1)]
end

# MySQL code to
# Generate the numbers,
# Create the ints table in your database,
# and bulk-load the file:
#
# # from the shell:
# ./ints.rb > /tmp/ints.tsv
#
# # from the mysql console:
# CREATE TABLE `auxtables`.`ints` (
#   `i`         MEDIUMINT UNSIGNED      NOT NULL,
#   `is`        MEDIUMINT               NOT NULL,
#   PRIMARY KEY (`i`)
# )
# LOAD DATA INFILE '/tmp/ints.tsv' INTO TABLE   `auxtables`.`ints` (`i`, `is`)

