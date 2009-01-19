#!/usr/bin/env ruby
require 'rubygems'
require 'json' ; require 'yaml'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
as_dset __FILE__
$: << File.dirname(__FILE__)+'/../twitter_friends/lib'
require 'hadoop'
require 'panel_models'

class SxswPanelHTMLParser < HTMLParser
  def self.parser_spec
    {
      :title         => 'dd/h2',
      :level         => 'dd.level',
      :type          => 'dd.type',
      :category      => 'dd.category',
      :name          => 'dd.presenter/a',
      :org           => one('dd.presenter', %r{</a>, (.*)</dd>}),
      :url           => href('dd.presenter/a'),
      :text          => 'dd.description',
      :comments      => [ 'div#comments-container/form/div', {
          :id         => attr('', 'id', %r{comment-(\d+)}),
          :name       => 'div.author/a,span',
          :url        => href('div.author/a'),
          :created_at => one('div.created', %r{on (.*)</div>}),
          :text       => 'div.comment-text',
        }
      ],
    }
  end

  def sanitize_whitespace(hsh)
    hsh.each do |k,v|
      next unless v && v.is_a?(String)
      v.strip!
      v.gsub!(/[\r\n\t]+/,' ')
    end
  end

  def sanitize_date date_str, strategy
    return '' if date_str.blank?
    case strategy
    when :european then dt = Date.strptime(date_str, "%d/%m/%y")
    else                dt = Date.parse(date_str)
    end
    dt.strftime(DATEFORMAT)
  end

  def extract_idea raw_idea
    sanitize_whitespace(raw_idea)
    Hadoop.encode_components(raw_idea, :name, :org, :text)
    panel_idea = SxswPanelIdea.from_hash(raw_idea, true)
    panel_idea
  end

  def extract_comments raw_idea
    return if raw_idea[:comments].blank?
    raw_idea[:comments].map do |raw_comment|
      next if raw_comment[:id].blank?
      sanitize_whitespace(raw_comment)
      Hadoop.encode_components(raw_comment, :name, :text)
      panel_comment            = SxswPanelComment.from_hash(raw_comment, true)
      panel_comment.created_at = sanitize_date(panel_comment.created_at, :european)
      panel_comment
    end.compact
  end

  def parse_panel_idea panel_idea_filename
    return unless File.exist?(panel_idea_filename)
    File.open(panel_idea_filename) do |panel_idea_file|
      #
      # Parse HTML
      #
      begin   doc = Hpricot(panel_idea_file)
      rescue; return;   end
      raw_idea = parse(doc)
      #
      # Extract idea
      #
      panel_idea = extract_idea(raw_idea)
      panel_idea.scraped_at = File.mtime(panel_idea_file).strftime(DATEFORMAT)
      panel_idea.id         = File.basename(panel_idea_filename, '.html')
      puts [:panel_idea, panel_idea.to_a].flatten.join("\t")
      #
      # Extract comments
      #
      panel_comments = extract_comments(raw_idea)
      panel_comments.each do |panel_comment|
        panel_comment.idea_id    = panel_idea.id
        # puts("%7d\t%7d\t%-31s\t%-39s\t%-15s\t%s" % panel_comment.to_a)
        puts [:panel_comment, panel_comment.to_a].flatten.join("\t")
      end
    end
    return true
  end

end

parser = SxswPanelHTMLParser.new
Dir['rawd/ideas/*'].each do |panel_idea_filename|
  parser.parse_panel_idea panel_idea_filename
end
