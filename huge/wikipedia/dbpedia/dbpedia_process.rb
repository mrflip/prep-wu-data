sql_make_table = <<-EOF
CREATE TABLE  `infochimps_data`.`infoboxen` (
  `id`          bigint(20)      unsigned NOT NULL auto_increment,
  `thing`       varchar(255)    default NULL,
  `property`    varchar(255)    default NULL,
  `value`       text,
  `rel`         char(4)         default NULL character set latin1,
  PRIMARY KEY   (`id`),
  KEY           `thing_prop`  (`thing`(50),`property`(50)),
  KEY           `property`    (`property`)
) ENGINE=MyISAM 
  AUTO_INCREMENT=2 DEFAULT 
  CHARSET=utf8 
  COMMENT='Wikipedia Infoboxen from DBPedia';
EOF



def create_tasks(dsm)
  dsm.rip_url      = "http://downloads.dbpedia.org/3.0/en/"
  dsm.ripd_url_dir = dsm.rip_url.gsub(/^(https?|ftp):\/\//, '')
  rips = dsm.path_to(:ripd_root, dsm.ripd_url_dir, 'infobox*.bz2')
  dsm.log(rips)
  FileList[rips].each do |src|
    dest = dsm.path_to(:rawd_root, :to_coll, File.basename(src, '.bz2'))
    task :rawd => dest
    file dest => src do |t|
      sh(%{bunzip2 --keep --stdout %s > %s} % [src, dest])
    end
  end
end

#
#
#
def process_dataset(munger, dataset)        
  
  dataset_files =
  {
    "articlecategories_en"      => "",
    "articles_label_en"         => "",
    "categories_label_en"       => "",
    "cwccclasses_en"            => "",
    "cwccclassesinstances_en"   => "",
    "disambiguation_en"         => "",
    "externallinks_en"          => "",
    "flickr_en"                 => "",
    "geo_en"                    => "",
    "homepage_en"               => "",
    "image_en"                  => "",
    "infobox_en"                => "",
    "infoboxproperties_en"      => "",
    "links_bookmashup_en"       => "",
    "links_cyc_en"              => "",
    "links_dblp_en"             => "",
    "links_eurostat_en"         => "",
    "links_factbook_en"         => "",
    "links_geonames_en"         => "",
    "links_gutenberg_en"        => "",
    "links_musicbrainz_en"      => "",
    "links_quotationsbook_en"   => "",
    "links_revyu_en"            => "",
    "links_uscensus_en"         => "",
    "longabstract_en"           => "",
    "pagelinks_en"              => "",
    "redirect_en"               => "",
    "shortabstract_en"          => "",
    "skoscategories_en"         => "",
    "wikicompany_links_en"      => "",
    "wikipage_en"               => "",
    "wordnetlink_en"            => "",
    }
  # copy_with_rename(dsm.path_to(:ripd_root, ripd_url_dir), a, b)
end

# #
# #
# #
# def process_dataset_schema(munger, dataset) 
#   true 
# end
# 
# #
# #
# #
# def process_dataset_files(munger, dataset)  
#   true 
# end


                   
