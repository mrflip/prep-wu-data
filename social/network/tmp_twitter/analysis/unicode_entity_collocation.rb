#!/usr/bin/env ruby
require 'wukong'
require 'wukong/encoding'
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model

#
# See bundle.sh for running pattern
#

class ExtractEntityPairsMapper < Wukong::Streamer::StructStreamer
  def decimalize_entities text
    text = Wukong.decode_str(text)
    Wukong.html_encoder.encode(text, :decimal)
  end

  def extract_entities text
    # Strip out the boring, numerous punctuation entities
    text.gsub!(/&(#10|#13|#9|apos|quot|amp|hellip|[lr]dquo|[rl]aquo|[nm]dash|[gl]t);/, '')
    # Make all entities decimal-encoded
    text     = decimalize_entities(text)
    entities = text.scan(/&#(\d+);/).flatten
  end

  #
  # for each entity:
  # * emit (entity1, entity2) for each unique pair of entities appearing in this tweet
  #
  # We *want* to repeat multiple entities and self-collocations:
  #   &foo;&bar;&foo;
  # should emit (&foo, &bar), (&foo, &foo), (&bar, foo)
  #
  def emit_entity_collocs entities
    tail = entities.sort.uniq
    (tail.length - 1).times do
      # pull off each entity
      entity1 = tail.shift
      # and emit a pair for all entities occurring after it in the string
      tail.each do |entity2|
        yield [entity1, entity2]
      end
    end
  end

  #
  #
  def process tweet, *_, &block
    next unless tweet.is_a? Tweet
    emit_entity_collocs(extract_entities(tweet.text), &block)
  end
end

class Uniqer < Wukong::Streamer::Base
  def stream
    %x{/usr/bin/uniq -c}.each do |line|
      freq, rest = line.chomp.strip.split(/\s+/, 2)
      freq = freq.to_i
      puts [rest, freq].join("\t") if freq > 3
    end
  end
end

#
# Executes the script
#
Wukong::Script.new(
  ExtractEntityPairsMapper,
  Uniqer,
  :sort_fields => 2,
  :partition_fields => 2
  ).run
