
class TwitterScrapeStore
  attr_accessor :ripd_base
  def initialize ripd_base
    self.ripd_base  = ripd_base
  end

  #
  # apply block to each scrape session directory
  #
  def each_scrape_session &block
    cd(path_to(:ripd_root)) do
      Dir[path_to(self.ripd_base, "*")].sort.each(&block)
    end
  end
end
