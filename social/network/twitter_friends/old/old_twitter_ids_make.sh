#!/usr/bin/env bash
find twitter.com -type f -exec cat {} \; \
    | ruby -ne '$_ =~ %r{^    <a href="http://twitter.com/([^"]+)" class="url" rel="contact"} and puts $1' \
    | sort | uniq -c | sort -rn > twitter_ids.txt
