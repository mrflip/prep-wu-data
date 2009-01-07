require 'fileutils'; include FileUtils


class TarScrapeStore
  attr_accessor :tar_filename
  def initialize tar_filename
    self.tar_filename = tar_filename
  end

  # Base path for temporary extraction
  LOCAL_EXTRACT_DIR = '/tmp/ripd'
  #
  # Where to extract files temporarily
  #
  def extract_dir
    LOCAL_EXTRACT_DIR + '/' + tar_filename.gsub(/\..*$/, '')
    mkdir_p extract_root
  end

  def listing
    `hdp-cat #{tar_filename} | tar tjvf - | egrep '\.json$'`.split("\n")
  end

end
