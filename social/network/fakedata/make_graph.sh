#!/usr/bin/env bash
cat a_follows_b-input.tsv | ruby -ne 'line= $_.gsub(/#.*/,"").gsub(/\s+/,"\t").strip; puts line unless line.empty?' > a_follows_b-processed.tsv
