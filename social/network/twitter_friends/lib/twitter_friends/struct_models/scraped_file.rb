class ScrapedFile
  attr_accessor :size, :scraped_at
  def initialize scrape_request, size, scraped_at
    self.scrape_request = scrape_request
    self.size           = size
    self.scraped_at     = scraped_at
  end

  def self.new_from_ls_line line
    mode, hl, owner, group, size, dt, tm, filename = line.split(/\s+/)
    if !m then warn "Ill-formed 'ls' line #{line}"; return nil ; end
    scrape_request = ScrapeRequest.new_from_filename(filename) or return nil
    self.new scrape_request, size, scraped_at
  end

  def item_key
    [identifier, context, page].join('-')
  end
end
