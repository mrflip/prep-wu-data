c#!/usr/bin/env bash

# time cat infobox_en.csv \
#     | ~/ics/code/munge/huge/wikipedia/dbpedia/fix_tsv.pl \
#     > infobox_en.tsv 2>err.log
#
# real    2m1.740s        user    1m51.446s       sys     0m11.333s       pct     100.00

# the .nt files all start with one of these:
# cat orig/infobox_en.nt | perl -ne 'next if m!^<http://(?:dbpedia.org/resource|upload.wikimedia.org/wikipedia/commons|upload.wikimedia.org/wikipedia)/.+> <http://(?:dbpedia.org/property|purl.org/dc/terms)/[^>]+> (?:".*"@\w\w|<http://[^>]+>|".*"\^\^<.+>) \.$!; print;'
#
# cat orig/infobox_en.nt | perl -ne 'm/^<.+> <.+> .*\^\^<(.+)>/ && print "$1\n"' | sort -u > meta/uniq_types.txt

# all these lines either look like
#   cat orig/infoboxproperties_en.nt | perl -ne 'm!<http://(?:dbpedia\.org/property/[\w\.]+|purl\.org/dc/terms/rights)> (<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property>|<http://www.w3.org/2000/01/rdf-schema#label> ".+") \.! || print;'

# <http://(?:dbpedia\.org/property/[\w\.]+|purl\.org/dc/terms/rights)>
# <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property>
# <http://www.w3.org/2000/01/rdf-schema#label>      ".+"
# \.
