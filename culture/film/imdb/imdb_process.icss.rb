#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'
require 'rake'

#
# Process IMDB files into raw packages
#
task :default => "imw:imdb"

def pkgd_fmt_bz2(ds, fmt)
  "#{ds[:pkgd_dir]}/#{ds[:ds]}-#{fmt}.tar.bz2"
end

# Construct the rawd/ tree from the ripd/ tree

# We expect a link named "ripd/ftp.imdb.com" that points to the corresponding
# dir of whatever mirror we obtained this from....


# Copy the FAQ and the README over


# Copy the package file over


# Stuff in the schema info, copy that over


#
# List of all IMDB datasets
#
$imdb_tables = %w{
    actors.list.gz
    actresses.list.gz
    aka-names.list.gz
    aka-titles.list.gz
    alternate-versions.list.gz
    biographies.list.gz
    business.list.gz
    certificates.list.gz
    cinematographers.list.gz
    color-info.list.gz
    complete-cast.list.gz
    complete-crew.list.gz
    composers.list.gz
    costume-designers.list.gz
    countries.list.gz
    crazy-credits.list.gz
    directors.list.gz
    distributors.list.gz
    editors.list.gz
    genres.list.gz
    german-aka-titles.list.gz
    goofs.list.gz
    hungarian-aka-titles.list.gz
    iso-aka-titles.list.gz
    italian-aka-titles.list.gz
    keywords.list.gz
    language.list.gz
    laserdisc.list.gz
    literature.list.gz
    locations.list.gz
    miscellaneous-companies.list.gz
    miscellaneous.list.gz
    movie-database-faq.gz
    movie-links.list.gz
    movies.list.gz
    mpaa-ratings-reasons.list.gz
    norwegian-aka-titles.list.gz
    plot.list.gz
    producers.list.gz
    production-companies.list.gz
    production-designers.list.gz
    quotes.list.gz
    ratings.list.gz
    release-dates.list.gz
    running-times.list.gz
    sound-mix.list.gz
    soundtracks.list.gz
    special-effects-companies.list.gz
    taglines.list.gz
    technical.list.gz
    trivia.list.gz
    writers.list.gz
  }


#
# work with gunzips
#
def gunzip(src, dest)
  cp(src, dest)
  sh %{ gunzip --decompress #{dest} }
end

#
# Re-encode as UTF8
#
def imdb_transcode()
end

# Get the schema, set up file structure paths
fixd_schema_file = ENV['icss']           or raise "Need to call as \"rake ... icss='path/to/my_schema.icss.yaml'\""
ds = ICSTree.grok_path(fixd_schema_file) or raise "Can't grok file #{fixd_schema_file}"
ds[:schemafile] = ds[:rest]
ds[:ds]         = ds[:schemafile].gsub(/\.icss\.yaml/,'')
ds[:coll_path]  = "#{ds[:cat]}/#{ds[:subcat]}/#{ds[:coll]}"
ds[:dset_path]  = "#{ds[:coll_path]}/#{ds[:ds]}"
ds[:fixd_dir]   = "#{ICSTree.dirs[:fixd]}/#{ds[:coll_path]}"
ds[:pkgd_dir]   = "#{ICSTree.dirs[:pkgd]}/#{ds[:dset_path]}"
ds[:pkgd_icss]  = "#{ds[:pkgd_dir]}/#{ds[:schemafile]}"
# puts ds.to_yaml

namespace :imw do
  YAML::load_documents( File.open( fixd_schema_file ) ) do |schemadoc|
    schemadoc.each do |sc_h|
      # look for the schema part of this. 
      schema = sc_h['infochimps_schema'] or next
      
      # Make sure there's a place to put it
      desc "Dir:     #{ds[:ds]}"
      directory ds[:pkgd_dir]
      
      # Make an archive for each format
      schema['formats'].each do |fmt_name, fmt|
        ds_fmt       = "#{ds[:ds]}-#{fmt_name}"        
        desc "Archive: #{ds_fmt}"
        file pkgd_fmt_bz2(ds,fmt_name) => [fixd_schema_file, ds[:pkgd_dir]] do         
          cd ds[:fixd_dir]
          sh %{ tar cvfj #{pkgd_fmt_bz2(ds,fmt_name)} #{ds[:ds]}-#{fmt_name} }
          fmt['num_files'] = FileList[ds[:fixd_dir]+"/#{ds[:ds]}-#{fmt_name}/**"].length-1
        end
        file ds[:pkgd_icss] => [pkgd_fmt_bz2(ds,fmt_name)]
        task :packages      => [pkgd_fmt_bz2(ds,fmt_name)]
      end # format

      # Add file information and dump out the schema
      desc "Schema: #{ds[:ds]}"
      file ds[:pkgd_icss] do       
        schema['formats'].each do |fmt_name, fmt|
          bz2_name = pkgd_fmt_bz2(ds, fmt_name)
          fmt['modified']  = File.mtime(bz2_name)
          fmt['filesize']  = File.size(bz2_name)
          fmt['filename']  = File.basename(bz2_name)
          puts fmt.to_yaml
        end
        schema['fileinfo'] = ds.slice(:dset_path, :cat, :subcat, :coll, :ds)
        schema['fileinfo'][:dataset_modified] = File.mtime("%s/%s.icss.yaml"%[ds[:fixd_dir],ds[:ds]])
        schema_obj = [{ 'infochimps_schema' => schema }]
        File.open(ds[:pkgd_icss], "w") do |f|
          f << (YAML::dump(schema_obj)).slice(4..-1)
        end
          
        
      end
      task :packages      => [ds[:pkgd_icss]]
      
      # the virtual dependency for this dataset
      desc "Package: #{ds[:ds]}"
      task :packages do
        true
      end 
    end #       
  end

end   

task :clean do
  sh %{ rm -f #{ds[:pkgd_dir]}/*.tar.* }
  sh %{ rm -f #{ds[:pkgd_dir]}/*.icss.yaml }
  sh %{ rmdir #{ds[:pkgd_dir]} }
end    
