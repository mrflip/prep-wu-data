#!/bin/bash

#
# This script isn't very smart, but it is handy.
#
# To do the whole thing, run
#    ./wikipedia-index-all.sh get extract chunk index xmlgen xmllint cat_logs
#
# The order doesn't matter. It does it in the order things appear below.
#

#
# fix this to match
#
wpdump='enwiki-latest-pages-articles.xml'
rootdir='/work/DataSources/Huge/Wikipedia'
chunkglob='*' # lets you restrict which chunks -- make with the 'single quotes', number part only

#
# shouldn't need to mess arount below this
#

# rootdir='.'
dumpdir=$rootdir/dump
chunkdir=$rootdir/chunks
indexdir=$rootdir/indexes
scriptdir=$rootdir
metadir=$rootdir
templatedir=$rootdir/templates
log=$metadir/wikipedia-index-out-`date '+%Y%m%d'`.log
errlog=$metadir/wikipedia-index-err-`date '+%Y%m%d'`.log

#
# Setup
#
phase=kill_logs;
if `echo "$*" | grep -q "${phase}"` ; then rm $log $errlog 2>/dev/null ; fi

# announce
echo "Indexing wikipedia dump ${wpdump} on `date`" >> $log

#
# Get it
#
phase=get
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    # wget -a $log -P $dumpdir -nv \
    #	"http://download.wikimedia.org/enwiki/latest/${wpdump}.bz2" 2>>$errlog

    for metafile in page.sql.gz          page_restrictions.sql.gz pagelinks.sql.gz          categorylinks.sql.gz   \
                    templatelinks.sql.gz externallinks.sql.gz     langlinks.sql.gz          logging.sql.gz         \
                    redirect.sql.gz      site_stats.sql.gz        stub-meta-current.xml.gz  stub-articles.xml.gz ; do
	wget  -a $log -P $dumpdir -nv \
    	    http://download.wikimedia.org/enwiki/latest/enwiki-latest-${metafile}
    done
fi

#
# Extract
#
phase=extract
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    # bunzip2 -k ${dumpdir}/${wpdump}.bz2 2>>$errlog
fi

#
# Chunk
#
phase=chunk
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    mkdir -p $chunkdir
    cd       $chunkdir
    ( cat ${dumpdir}/${wpdump} | ${scriptdir}/wikipedia-index-chunk.pl ) >> ${log} 2>>$errlog
    cd $rootdir
fi

#
# Index
#
phase=index
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    mkdir -p $indexdir
    for chunk in $chunkdir/*-${chunkglob}.xml ; do
	filebase=`basename "$chunk" '.xml'`
	filename=${filebase}-index.yaml
	echo "indexing  $chunk => $filename"
	time ( cat $chunk | $scriptdir/wikipedia-index-yamlgen.pl  > $indexdir/${filename} 2>>$errlog )
    done
fi

#
# YAML => XML
#   (also checks YAML goodness)
#
phase=xmlgen
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    mkdir -p $indexdir
    for index in $indexdir/*-${chunkglob}-index.yaml ; do
	filebase=`basename "$index" '.yaml'`
	filename=${filebase}.xml
	echo "xmlifying $index => $filename"
	time ( $scriptdir/wikipedia-index-yaml2xml.pl ${index} > $indexdir/${filename} 2>>$errlog )
    done
fi

#
# Check XML
#
phase=xmllint
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    mkdir -p $indexdir
    for index in $indexdir/*-${chunkglob}-index.xml ; do
	filebase=`basename "$index" '.xml'`
	filename=${filebase}.xml
	echo "checking  $filename"
	time ( xmllint  ${index} > /dev/null 2>>$errlog )
    done
fi

#
# Make template-only files
#
phase=templ_extr
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    mkdir -p $templatedir
    for index in $indexdir/*-${chunkglob}-index.yaml ; do
	filebase=`basename "$index" '-index.yaml'`
	filename=${filebase}-template.yaml
	echo "Dumping only templates into $filename"
	# note that perl -ne 'm//&&print;' is hundreds of times faster than egrep
	( echo "wikipedia_index:";
	      cat $index | perl -ne 'm/ - (?:template|titleid|page)\:/ && print;' ) > \
	  ${templatedir}/${filename}
    done
fi

#
# Parse template-only files
#
phase=templ_parse
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase" >> $log
    mkdir -p $templatedir
    for template in $templatedir/*-${chunkglob}-template.yaml ; do
	filebase=`basename "$template" '-template.yaml'`
	filename=${filebase}-tree.yaml
	echo "Parsing template into $filename"
	cat $template \
	    | $scriptdir/wikipedia-index-templates-extract.pl \
	    > ${templatedir}/${filename} 2>>$errlog
    done
fi

#
# Count and classify tags
#
phase=tags_count
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase on ${indexdir}/*-${chunkglob}-index.yaml" >> $log
    mkdir -p $indexdir

    time  ( cat ${indexdir}/*-${chunkglob}-index.yaml | \
		${scriptdir}/wikipedia-index-tags_count.pl > \
		${metadir}/meta-tags-count.txt )
fi


#
# Full census of templates
#
phase=templ_census
if `echo "$*" | grep -q "${phase}"` ; then
    echo "  ... `date`: $phase on ${templatedir}/*-${chunkglob}-tree.yaml" >> $log
    mkdir -p ${metadir}
    ${scriptdir}/wikipedia-index-templates-segment.pl \
    	${templatedir}/*-${chunkglob}-tree.yaml > \
	${metadir}/meta-template-counts.txt
fi




## list Template titles and IDs
# ( echo 'wikipedia_template_titleids';
#   cat ../indexes/enwiki-chunk-*-index.yaml | \
#     perl -ne 'm/- titleid: .*Template\:/ && print;'
# ) > meta-template-titleids.yaml

## List templates by occurrence count
# ( cat ../templates/enwiki-chunk-*-tree.yaml | \
#     perl -ne 'm/^        templ_id: /&&print;' | \
#     sort | uniq -c | sort -rn \
# ) > templatefiles-list.txt 

## Yaml showing all redirects
# ( echo "template_redirects:" ;
#   grep  '#REDIRECT' * | \
#   perl -ne 'if ((my ($from, $to)) = m/([^\:]*)\.xml:.*#REDIRECT\s*\[\[(.*?)\]\]/s) { \
#       $to=~s/Template\://s; $to=~s/\s/_/g;
#       printf " - %-40s %s\n", "$from:", "\"$to\"";
#   } else {
#       print "$_\n";
#   }'
# ) > meta-template-redirected.yaml


# exporturl="http://en.wikipedia.org/w/index.php?title=Special:Export&action=submit&dir=desc&limit=1";
# for foo in `cat meta-template-titlestofetch.txt` ; do \
#    if [[ -f "$foo.xml" ]] ; then \
#        echo "got it"; \
#    else
#        wget "${exporturl}&pages=Template:${foo}"     -O "$foo.xml"; \
#        wget "${exporturl}&pages=Template:${foo}/doc" -O "$foo-doc.xml"; \
#    fi
# done




#
# Done
#
phase=cat_logs; if `echo "$*" | grep -q "${phase}"` ; then
    echo ; echo "############# Output Log Summary:"
    ( cat $log    | cut -c 1-150 | more )
    echo ; echo "############# End Output Log"
    echo ; echo "############# Error Log Summary"
    ( cat $errlog | cut -c 1-150 | more )
    echo ; echo "############# End Error Log"    
fi
